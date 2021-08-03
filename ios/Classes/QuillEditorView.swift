//
//  QuillEditorView.swift
//  tun_editor
//
//  Created by Jeffrey Wu on 2021/8/2.
//

import UIKit
import WebKit

class QuillEditorView: WKWebView, WKNavigationDelegate {
    
    var placeholder: String = ""
    var padding: [Int] = [12, 15, 12, 15]
    var readOnly: Bool = false
    var autoFocus: Bool = false
    var delta: [Any] = []
        
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
    
    func replaceText(index: Int, length: Int, data: Any) {
        if data is String {
            exec("replaceText(\(index), \(length), \"\(data)\")")
        } else {
            exec("replaceText(\(index), \(length), \(data))")
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
    
    func insertDivider() {
        exec("insertDivider()")
    }
    
    func insertImage(_ url: String) {
        exec("insertImage(\"\(url)\")")
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
        exec("setContents(\(delta))")
    }
    
    private func setup() {
        self.backgroundColor = .white
        self.navigationDelegate = self
        
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
