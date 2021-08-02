//
//  QuillEditorView.swift
//  tun_editor
//
//  Created by Jeffrey Wu on 2021/8/2.
//

import UIKit
import WebKit

class QuillEditorView: WKWebView {
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func insertDivider() {
        debugPrint("insert divider")
        exec("insertDivider()")
    }
    
    private func setup() {
        self.backgroundColor = .red
        
        if let filePath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: filePath, isDirectory: false)
            let request = URLRequest(url: url)
            self.load(request)
        }
    }
    
    private func exec(_ command: String) {
        self.evaluateJavaScript(command) { (result, error) in
            debugPrint("exec command \(command), result: \(result), error: \(error)")
        }
    }
    
}
    
