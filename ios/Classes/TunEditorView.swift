import Flutter
import UIKit
import SwiftUI
import WebKit

class TunEditorViewFactory: NSObject, FlutterPlatformViewFactory {

    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return TunEditorView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }

}

class TunEditorView: NSObject, FlutterPlatformView {

    private var _editor: QuillEditorView
    
    private var methodChannel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        let configuration = WKWebViewConfiguration()
        
        var placeholder: String = ""
        var padding: [Int] = [12, 15, 12, 15]
        var readOnly: Bool = false
        var autoFocus: Bool = false
        var delta: [Any] = []
        
        if let argsMap = args as? Dictionary<String, Any> {
            if let optPlaceholder = argsMap["placeholder"] as? String {
                placeholder = optPlaceholder
            }
            if let optPadding = argsMap["padding"] as? [Int] {
                padding = optPadding
            }
            if let optReadOnly = argsMap["readOnly"] as? Bool {
                readOnly = optReadOnly
            }
            if let optAutoFocus = argsMap["autoFocus"] as? Bool {
                autoFocus = optAutoFocus
            }
            if let optDelta = argsMap["delta"] as? [Any] {
                delta = optDelta
            }
        } else {
            debugPrint("invalid args \(args == nil)")
        }
        _editor = QuillEditorView(
            frame: frame,
            configuration: configuration,
            placeholder: placeholder,
            padding: padding,
            readOnly: readOnly,
            autoFocus: autoFocus,
            delta: delta
        )
        methodChannel = FlutterMethodChannel(name: "tun/editor/\(viewId)", binaryMessenger: messenger)
        super.init()

        _editor.frame = frame
        methodChannel.setMethodCallHandler(handle)
    }

    func view() -> UIView {
        return _editor
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        debugPrint("handle method in tun editor: \(call.method)")
        switch call.method {
        // Content related.
        case "replaceText":
            if let args = call.arguments as? Dictionary<String, Any> {
                let index = args["index"] as? Int
                let length = args["length"] as? Int
                let data = args["data"]
                if index == nil || length == nil || data == nil {
                    return
                }
                _editor.replaceText(index: index!, length: length!, data: data!)
            }
        case "insertDivider":
            _editor.insertDivider()
        case "insertImage":
            if let url = call.arguments as? String {
                _editor.insertImage(url)
            }

        // Format related.
        case "setTextType":
            let textType: String = call.arguments is String
                ? call.arguments as! String
                : TextType.normal.rawValue
            switch textType {
            case TextType.headline1.rawValue:
                _editor.format(name: "header", value: 1)
            case TextType.headline2.rawValue:
                _editor.format(name: "header", value: 2)
            case TextType.headline3.rawValue:
                _editor.format(name: "header", value: 3)
            case TextType.listBullet.rawValue:
                _editor.format(name: "list", value: "bullet")
            case TextType.listOrdered.rawValue:
                _editor.format(name: "list", value: "ordered")
            case TextType.quote.rawValue:
                _editor.format(name: "blockquote", value: true)
            case TextType.codeBlock.rawValue:
                _editor.format(name: "code-block", value: true)
            default:
                print("missing text type")
            }
        case "setTextStyle":
            if let styles = call.arguments as? [String] {
                _editor.format(name: "bold", value: styles.contains(TextStyle.bold.rawValue))
                _editor.format(name: "italic", value: styles.contains(TextStyle.italic.rawValue))
                _editor.format(name: "underline", value: styles.contains(TextStyle.underline.rawValue))
                _editor.format(name: "strike", value: styles.contains(TextStyle.strikeThrough.rawValue))
            }
        case "formatText":
            if let args = call.arguments as? Dictionary<String, Any> {
                let index = args["index"] as? Int
                let length = args["length"] as? Int
                let name = args["name"] as? String
                let value = args["value"]
                if index == nil || length == nil || name == nil || value == nil {
                    return
                }
                _editor.formatText(index: index!, length: length!, name: name!, value: value!)
            }
            
        // Selection related.
        case "updateSelection":
            if let args = call.arguments as? Dictionary<String, Any> {
                let index = args["index"] as? Int
                let length = args["length"] as? Int
                if index == nil || length == nil {
                    return
                }
                _editor.setSelection(index: index!, length: length!)
            }

        // Editor related.
        case "focus":
            _editor.focus()
        case "blur":
            _editor.blur()
            
        default:
            print("missing tun editor method")
        }
    }

}
