//
//  QuillEditorView.swift
//  tun_editor
//
//  Created by Jeffrey Wu on 2021/8/2.
//

import UIKit
import WebKit

class QuillEditorView: WKWebView, WKNavigationDelegate, WKScriptMessageHandler {
    
    weak var scriptDelegate: WKScriptMessageHandler?
    
    var placeholder: String = ""
    var readOnly: Bool = false
    var scrollable: Bool = true
    var padding: [Int] = [12, 15, 12, 15]
    var autoFocus: Bool = false
    var delta: [Any] = []
    
    var onSelectionChangeHandler: (([String: AnyObject]) -> Void)? = nil
    var onTextChangeHandler: (([String: AnyObject]) -> Void)? = nil
    var onMentionClickHandler: (([String: AnyObject]) -> Void)? = nil
    var onLinkClickHandler: (([String: AnyObject]) -> Void)? = nil
    var onFocusChangeHandler: (([String: AnyObject]) -> Void)? = nil
        
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public init(
        frame: CGRect,
        configuration: WKWebViewConfiguration,
        placeholder: String,
        readOnly: Bool,
        scrollable: Bool,
        padding: [Int],
        autoFocus: Bool,
        delta: [Any]
    ) {
        self.placeholder = placeholder
        self.readOnly = readOnly
        self.scrollable = scrollable
        self.padding = padding
        self.autoFocus = autoFocus
        self.delta = delta
        
        super.init(frame: frame, configuration: configuration)
        setup()
    }
    
    deinit {
        onTextChangeHandler = nil
        onSelectionChangeHandler = nil
        onMentionClickHandler = nil
        onLinkClickHandler = nil
        onFocusChangeHandler = nil
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setPlaceholder(placeholder)
        setReadOnly(readOnly)
        setScrollable(scrollable)
        setPadding(padding)
        setContents(delta)

        if (autoFocus) {
            focus()
        } else {
            blur()
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("receive message: \(message.name) \(message.body) \(message.body is [String: Any])")
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
            if let path = message.body as? String {
                print("load image \(path)")
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
                print("attributes json str is nil")
                return
            }
         
            if data is String {
                exec("replaceText(\(index), \(length), \"\(data)\", \(attributesJsonStr!), \(newLineAfterImage), false)")
            } else {
                let dataJson = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions(rawValue: 0))
                let dataJsonStr = String(data: dataJson, encoding: .utf8)
                if dataJsonStr == nil {
                    print("data json str is nil")
                    return
                }
                print("replaceText(\(index), \(length), \(dataJsonStr!), \(attributesJsonStr!), \(newLineAfterImage), true)")
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
        exec("setPlaceholder(\"\(placeholder)\")")
    }
    
    func setReadOnly(_ readOnly: Bool) {
        exec("setReadOnly(\(readOnly))")
    }
    
    func setScrollable(_ scrollable: Bool) {
        self.scrollView.isScrollEnabled = scrollable
    }
    
    func setPadding(_ padding: [Int]) {
        if padding.count < 4 {
            return
        } else {
            exec("setPadding(\(padding[0]), \(padding[1]), \(padding[2]), \(padding[3]))")
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
    
    private func setup() {
        self.backgroundColor = .white
        self.navigationDelegate = self
        self.configuration.userContentController.add(self, name: "onTextChange")
        self.configuration.userContentController.add(self, name: "onSelectionChange")
        self.configuration.userContentController.add(self, name: "onMentionClick")
        self.configuration.userContentController.add(self, name: "onLinkClick")
        self.configuration.userContentController.add(self, name: "onFocusChange")

        
        if let filePath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: filePath, isDirectory: false)
            let request = URLRequest(url: url)
            self.load(request)
        }
    }
    
    private func exec(_ command: String) {
        self.evaluateJavaScript(command) { (result, error) in
            if (error != nil) {
                debugPrint("exec command \(command), error: \(String(describing: error.debugDescription))")
            }
        }
    }
    
}
