//
//  QuillEditorView.swift
//  tun_editor
//
//  Created by Jeffrey Wu on 2021/8/2.
//

import UIKit
import WebKit
import Foundation

typealias OlderClosureType =  @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Any?) -> Void
typealias NewClosureType =  @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void


class QuillEditorView: WKWebView, WKNavigationDelegate, WKScriptMessageHandler {
    
    weak var scriptDelegate: WKScriptMessageHandler?
    
    var accessoryView: UIView?
    
    var placeholder: String = ""
    var readOnly: Bool = false
    var scrollable: Bool = true
    var padding: [Int] = [12, 15, 12, 15]
    var autoFocus: Bool = false
    var delta: [Any] = []
    var fileBasePath: String = ""
    var imageStyle: [String: Any] = [:]
    var videoStyle: [String: Any] = [:]
    var placeholderStyle: [String: Any] = [:]
    
    var viewId: Int = 0
    
    var onSelectionChangeHandler: (([String: AnyObject]) -> Void)? = nil
    var onTextChangeHandler: (([String: AnyObject]) -> Void)? = nil
    var onMentionClickHandler: (([String: AnyObject]) -> Void)? = nil
    var onLinkClickHandler: (([String: AnyObject]) -> Void)? = nil
    var onFocusChangeHandler: (([String: AnyObject]) -> Void)? = nil
        
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        if #available(iOS 10.0, *) {
            configuration.dataDetectorTypes = WKDataDetectorTypes()
        }
        super.init(frame: frame, configuration: configuration)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        onTextChangeHandler = nil
        onSelectionChangeHandler = nil
        onMentionClickHandler = nil
        onLinkClickHandler = nil
        onFocusChangeHandler = nil
    }
    
    func configureEditor(
        frame: CGRect,
        placeholder: String,
        readOnly: Bool,
        scrollable: Bool,
        padding: [Int],
        autoFocus: Bool,
        delta: [Any],
        fileBasePath: String,
        imageStyle: [String: Any],
        videoStyle: [String: Any],
        placeholderStyle: [String: Any]
    ) {
        self.frame = frame
        self.autoFocus = autoFocus
        self.fileBasePath = fileBasePath
        
        setPlaceholder(placeholder)
        setReadOnly(readOnly)
        setScrollable(scrollable)
        setPadding(padding)
        setImageStyle(imageStyle)
        setVideoStyle(videoStyle)
        setPlaceholderStyle(placeholderStyle)
        setContents(delta)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        setPlaceholder(placeholder)
//        setReadOnly(readOnly)
//        setScrollable(scrollable)
//        setPadding(padding)
//        setImageStyle(imageStyle)
//        setVideoStyle(videoStyle)
//        setPlaceholderStyle(placeholderStyle)
//        setContents(delta)
        setKeyboardRequiresUserInteraction(false)
    }
    
    override var inputAccessoryView: UIView? {
        return accessoryView
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("receive message: \(message.name) \(message.body)")
        switch message.name {
        case "onTextChange":
//            onTextChangeHandler?(message.body)
            if let args = message.body as? [String: AnyObject] {
                onTextChangeHandler?(args)
            }
        case "onSelectionChange":
            if var args = message.body as? [String: AnyObject] {
                if let index = args["index"] as? Int {
                    args["index"] = index as AnyObject
                }
                if let length = args["length"] as? Int {
                    args["length"] = length as AnyObject
                }
                onSelectionChangeHandler?(args)
            }
        case "onMentionClick":
            if let args = message.body as? [String: AnyObject] {
                onMentionClickHandler?(args)
            }
        case "onLinkClick":
            if let args = message.body as? [String: AnyObject] {
                onLinkClickHandler?(args)
            }
        case "onFocusChange":
            if let args = message.body as? [String: AnyObject] {
                onFocusChangeHandler?(args)
            }
        case "loadImage":
            if let filename = message.body as? String {
                refreshImage(filename)
            }
        case "loadVideoThumb":
            if let filename = message.body as? String {
                refreshVideoThumb(filename)
            }
        default:
            debugPrint("missing message handler in quill editor \(message.name)")
        }
    }
    
    func replaceText(index: Int, length: Int, data: Any, attributes: [String: Any], newLineAfterImage: Bool) {
        do {
            let attributesJson = try JSONSerialization.data(withJSONObject: attributes, options: JSONSerialization.WritingOptions(rawValue: 0))
            let attributesJsonStr = String(data: attributesJson, encoding: .utf8)
            if attributesJsonStr == nil {
                return
            }
         
            if data is String {
                exec("replaceText(\(index), \(length), \"\(data)\", \(attributesJsonStr!), \(newLineAfterImage), false)")
            } else {
                let dataJson = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions(rawValue: 0))
                let dataJsonStr = String(data: dataJson, encoding: .utf8)
                if dataJsonStr == nil {
                    return
                }
                exec("replaceText(\(index), \(length), \(dataJsonStr!), \(attributesJsonStr!), \(newLineAfterImage), true)")
            }
        } catch {
            print("replace text failed: \(error)")
        }
    }
    
    func updateContents(delta: [Any], source: String) {
        do {
            let deltaJson = try JSONSerialization.data(withJSONObject: delta, options: JSONSerialization.WritingOptions(rawValue: 0))
            if let deltaJsonStr = String(data: deltaJson, encoding: .utf8) {
               exec("updateContents(\(deltaJsonStr), \"\(source)\")")
            }
        } catch {
            print("update contents failed: \(error)")
        }
    }
    
    func format(name: String, value: Any) {
        if (value is String) {
            exec("format(\"\(name)\", \"\(value)\")")
        } else {
            exec("format(\"\(name)\", \(value))")
        }
    }
    
    func formatText(index: Int, length: Int, name: String, value: Any) {
        if (value is String) {
            exec("formatText(\(index), \(length), \"\(name)\", \"\(value)\")")
        } else {
            exec("formatText(\(index), \(length), \"\(name)\", \(value))")
        }
    }
    
    func setSelection(index: Int, length: Int) {
        exec("setSelection(\(index), \(length))")
    }
    
    func focus() {
        exec("focus()")
    }
    
    func blur() {
        exec("blur()")
    }
    
    func setPlaceholder(_ placeholder: String) {
        self.placeholder = placeholder
        exec("setPlaceholder(\"\(placeholder)\")")
    }
    
    func setReadOnly(_ readOnly: Bool) {
        self.readOnly = readOnly
        exec("setReadOnly(\(readOnly))")
    }
    
    func setScrollable(_ scrollable: Bool) {
        self.scrollable = scrollable
        self.scrollView.isScrollEnabled = scrollable
    }
    
    func setPadding(_ padding: [Int]) {
        if padding.count < 4 {
            return
        } else {
            self.padding = padding
            exec("setPadding(\(padding[0]), \(padding[1]), \(padding[2]), \(padding[3]))")
        }
    }
    
    func setFileBasePath(_ fileBasePath: String) {
        self.fileBasePath = fileBasePath
    }
    
    func setImageStyle(_ style: [String: Any]) {
        self.imageStyle = style
        
        do {
            let styleJson = try JSONSerialization.data(withJSONObject: style, options: JSONSerialization.WritingOptions(rawValue: 0))
            let styleJsonStr = String(data: styleJson, encoding: .utf8)
            if styleJsonStr == nil {
                return
            }
            exec("setImageStyle(\(styleJsonStr!))")
        } catch {
            print("serial image style failed: \(error)")
        }
    }
    
    func setVideoStyle(_ style: [String: Any]) {
        self.videoStyle = style
        
        do {
            let styleJson = try JSONSerialization.data(withJSONObject: style, options: JSONSerialization.WritingOptions(rawValue: 0))
            let styleJsonStr = String(data: styleJson, encoding: .utf8)
            if styleJsonStr == nil {
                return
            }
            exec("setVideoStyle(\(styleJsonStr!))")
        } catch {
            print("serial image style failed: \(error)")
        }
    }
    
    func setPlaceholderStyle(_ style: [String: Any]) {
        self.placeholderStyle = style
        
        do {
            let styleJson = try JSONSerialization.data(withJSONObject: style, options: JSONSerialization.WritingOptions(rawValue: 0))
            let styleJsonStr = String(data: styleJson, encoding: .utf8)
            if styleJsonStr == nil {
                return
            }
            exec("setPlaceholderStyle(\(styleJsonStr!))")
        } catch {
            print("serial placeholder style failed: \(error)")
        }
    }
    
    func setOnTextChangeListener(_ handler: @escaping (([String: AnyObject]) -> Void)) {
        self.onTextChangeHandler = handler
    }
    
    func setOnSelectionChangeListener(_ handler: @escaping (([String: AnyObject]) -> Void)) {
        self.onSelectionChangeHandler = handler
    }
    
    func setOnMentionClickListener(_ handler: @escaping (([String: AnyObject]) -> Void)) {
        self.onMentionClickHandler = handler
    }
    
    func setOnLinkClickListener(_ handler: @escaping (([String: AnyObject]) -> Void)) {
        self.onLinkClickHandler = handler
    }
    
    func setOnFocusChangeListener(_ handler: @escaping (([String: AnyObject]) -> Void)) {
        self.onFocusChangeHandler = handler
    }
    
    private func setContents(_ delta: [Any]) {
        do {
            let deltaJson = try JSONSerialization.data(withJSONObject: delta, options: JSONSerialization.WritingOptions(rawValue: 0))
            if let deltaJsonStr = String(data: deltaJson, encoding: .utf8) {
               exec("setContents(\(deltaJsonStr))")
            }
        } catch {
            print("set contents failed: \(error)")
        }
    }
    
    private func refreshImage(_ filename: String) {
        var url = URL(fileURLWithPath: fileBasePath)
        url.appendPathComponent(filename)
        
        do {
            let fileData = try Data.init(contentsOf: url).base64EncodedString()
            exec("refreshImage(\"\(filename)\", \"data:image/png;base64,\(fileData)\")")
        }
        catch {
            print("read image file failed \(error)")
        }
    }
    
    private func refreshVideoThumb(_ filename: String) {
        var url = URL(fileURLWithPath: fileBasePath)
        url.appendPathComponent(filename)
        
        do {
            let fileData = try Data.init(contentsOf: url).base64EncodedString()
            exec("refreshVideoThumb(\"\(filename)\", \"data:image/png;base64,\(fileData)\")")
        }
        catch {
            print("read video thumb file failed \(error)")
        }
    }
    
    private func setup() {
        self.backgroundColor = .white
        self.navigationDelegate = self
        
        self.configuration.userContentController.add(self, name: "onTextChange")
        self.configuration.userContentController.add(self, name: "onSelectionChange")
        self.configuration.userContentController.add(self, name: "onMentionClick")
        self.configuration.userContentController.add(self, name: "onLinkClick")
        self.configuration.userContentController.add(self, name: "onFocusChange")
        self.configuration.userContentController.add(self, name: "loadImage")
        self.configuration.userContentController.add(self, name: "loadVideoThumb")

        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            self.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
    
    private func exec(_ command: String) {
        self.evaluateJavaScript(command) { (result, error) in
            if (error != nil) {
                debugPrint("exec command \(command), error: \(String(describing: error.debugDescription))")
            }
        }
    }

    func setKeyboardRequiresUserInteraction( _ value: Bool) {

        guard
            let WKContentViewClass: AnyClass = NSClassFromString("WKContentView") else {
                print("Cannot find the WKContentView class")
                return
        }

        let olderSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:")
        let newSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        let newerSelector: Selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        let ios13Selector: Selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:")

        if let method = class_getInstanceMethod(WKContentViewClass, olderSelector) {
            let originalImp: IMP = method_getImplementation(method)
            let original: OlderClosureType = unsafeBitCast(originalImp, to: OlderClosureType.self)
            let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Any?) -> Void = { (me, arg0, arg1, arg2, arg3) in
                original(me, olderSelector, arg0, !value, arg2, arg3)
            }
            let imp: IMP = imp_implementationWithBlock(block)
            method_setImplementation(method, imp)
        }

        if let method = class_getInstanceMethod(WKContentViewClass, newSelector) {
            self.swizzleAutofocusMethod(method, newSelector, value)
        }

        if let method = class_getInstanceMethod(WKContentViewClass, newerSelector) {
            self.swizzleAutofocusMethod(method, newerSelector, value)
        }

        if let method = class_getInstanceMethod(WKContentViewClass, ios13Selector) {
            self.swizzleAutofocusMethod(method, ios13Selector, value)
        }
    }

    func swizzleAutofocusMethod(_ method: Method, _ selector: Selector, _ value: Bool) {
        let originalImp: IMP = method_getImplementation(method)
        let original: NewClosureType = unsafeBitCast(originalImp, to: NewClosureType.self)
        let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void = { (me, arg0, arg1, arg2, arg3, arg4) in
            original(me, selector, arg0, !value, arg2, arg3, arg4)
        }
        let imp: IMP = imp_implementationWithBlock(block)
        method_setImplementation(method, imp)
   }

    
}
