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
    var padding: [Int] = [12, 15, 12, 15]
    var readOnly: Bool = false
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
        padding: [Int],
        readOnly: Bool,
        autoFocus: Bool,
        delta: [Any]
    ) {
        self.placeholder = placeholder
        self.padding = padding
        self.readOnly = readOnly
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
        setPadding(padding)
        setReadOnly(readOnly)
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
        default:
            debugPrint("missing message handler in quill editor \(message.name)")
        }
    }
    
    func replaceText(index: Int, length: Int, data: Any) {
        if data is String {
            exec("replaceText(\(index), \(length), \"\(data)\")")
        } else {
            exec("replaceText(\(index), \(length), \(data))")
        }
    }
    
    func insertMention(id: String, text: String) {
        exec("insertMention(\"\(id)\", \"\(text)\")")
    }
    
    func insertDivider() {
        exec("insertDivider()")
    }
    
    func insertImage(_ url: String) {
        exec("insertImage(\"\(url)\")")
    }
    
    func insertLink(_ text: String, _ url: String) {
        exec("insertLink(\"\(text)\", \"\(url)\")")
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
        exec("setSelection(\(index), \(length)")
    }
    
    func focus() {
        exec("focus()")
    }
    
    func blur() {
        exec("blur()")
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
    
    private func setPlaceholder(_ placeholder: String) {
        exec("setPlaceholder(\"\(placeholder)\")")
    }
    
    private func setPadding(_ padding: [Int]) {
        if padding.count < 4 {
            return
        } else {
            exec("setPadding(\(padding[0]), \(padding[1]), \(padding[2]), \(padding[3]))")
        }
    }
    
    private func setReadOnly(_ readOnly: Bool) {
        exec("setReadOnly(\(readOnly))")
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
