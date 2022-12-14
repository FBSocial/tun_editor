import Flutter
import UIKit
import SwiftUI
import WebKit

class TunEditorViewFactory: NSObject, FlutterPlatformViewFactory {

    private var messenger: FlutterBinaryMessenger
    private var nextEditor: QuillEditorView

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        
        let configuration = WKWebViewConfiguration()
        self.nextEditor = QuillEditorView(frame: CGRect.zero, configuration: configuration)
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let tunEditrView = TunEditorView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger,
            editorView: nextEditor
        )
        
        let configuration = WKWebViewConfiguration()
        self.nextEditor = QuillEditorView(frame: CGRect.zero, configuration: configuration)
        return tunEditrView
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

}

class TunEditorView: NSObject, FlutterPlatformView {

    private var _editor: QuillEditorView
    
    private var methodChannel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger,
        editorView: QuillEditorView
    ) {
        _editor = editorView
        
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
        var enableMarkdownSyntax: Bool = true
        
        if let argsMap = args as? [String: Any] {
            if let optPlaceholder = argsMap["placeholder"] as? String {
                placeholder = optPlaceholder
            }
            if let optReadOnly = argsMap["readOnly"] as? Bool {
                readOnly = optReadOnly
            }
            if let optScrollable = argsMap["scrollable"] as? Bool {
                scrollable = optScrollable
            }
            if let optPadding = argsMap["padding"] as? [Int] {
                padding = optPadding
            }
            if let optAutoFocus = argsMap["autoFocus"] as? Bool {
                autoFocus = optAutoFocus
            }
            if let optDelta = argsMap["delta"] as? [Any] {
                delta = optDelta
            }
            if let optFileBasePath = argsMap["fileBasePath"] as? String {
                fileBasePath = optFileBasePath
            }
            if let optImageStyle = argsMap["imageStyle"] as? [String: Any] {
                imageStyle = optImageStyle
            }
            if let optVideoStyle = argsMap["videoStyle"] as? [String: Any] {
                videoStyle = optVideoStyle
            }
            if let optPlaceholderStyle = argsMap["placeholderStyle"] as? [String: Any] {
                placeholderStyle = optPlaceholderStyle
            }
            if let optEnableMarkdownSyntax = argsMap["enableMarkdownSyntax"] as? Bool {
                enableMarkdownSyntax = optEnableMarkdownSyntax
            }
        }
        _editor.configureEditor(
            frame: frame,
            placeholder: placeholder,
            readOnly: readOnly,
            scrollable: scrollable,
            padding: padding,
            autoFocus: autoFocus,
            delta: delta,
            fileBasePath: fileBasePath,
            imageStyle: imageStyle,
            videoStyle: videoStyle,
            placeholderStyle: placeholderStyle,
            enableMarkdownSyntax: enableMarkdownSyntax
        )
        methodChannel = FlutterMethodChannel(name: "tun/editor/\(viewId)", binaryMessenger: messenger)
        super.init()

        _editor.setOnTextChangeListener { args in
            self.methodChannel.invokeMethod("onTextChange", arguments: args)
        }
        _editor.setOnSelectionChangeListener { args in
            self.methodChannel.invokeMethod("onSelectionChange", arguments: args)
        }
        _editor.setOnMentionClickListener { args in
            self.methodChannel.invokeMethod("onMentionClick", arguments: args)
        }
        _editor.setOnLinkClickListener { args in
            if let url = args["url"] as? String {
                self.methodChannel.invokeMethod("onLinkClick", arguments: url)
            }
        }
        _editor.setOnFocusChangeListener { args in
            if let hasFocus = args["hasFocus"] as? Bool {
                self.methodChannel.invokeMethod("onFocusChange", arguments: hasFocus)
            }
        }
        methodChannel.setMethodCallHandler(handle)
        
        methodChannel.invokeMethod("onPageLoaded", arguments: nil)
    }

    func view() -> UIView {
        return _editor
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        debugPrint("handle method in tun editor: \(call.method)")
        switch call.method {
        // Content related.
        case "replaceText":
            if let args = call.arguments as? [String: Any] {
                let index = args["index"] as? Int
                let length = args["len"] as? Int
                let data = args["data"]
                let attributes = args["attributes"] as? [String: Any]
                let newLineAfterImage = args["newLineAfterImage"] as? Bool
                let ignoreFocus = args["ignoreFocus"] as? Bool
                let selection = args["selection"] as? [String: Any]
                if index == nil || length == nil || data == nil || newLineAfterImage == nil || attributes == nil
                    || ignoreFocus == nil || selection == nil{
                    return
                }
                _editor.replaceText(index: index!, length: length!, data: data!,
                    attributes: attributes!, newLineAfterImage: newLineAfterImage!,
                    ignoreFocus: ignoreFocus!, selection: selection!)
            }
        case "updateContents":
            if let args = call.arguments as? [String: Any] {
                let delta = args["delta"] as? [Any]
                let source = args["source"] as? String
                let ignoreFocus = args["ignoreFocus"] as? Bool
                let selection = args["selection"] as? [String: Any]
                if delta == nil || source == nil || ignoreFocus == nil || selection == nil {
                    return
                }
                _editor.updateContents(delta: delta!, source: source!, ignoreFocus: ignoreFocus!, selection: selection!)
            }

        // Format related.
        case "setTextType":
            let textType: String = call.arguments is String
                ? call.arguments as! String
                : TextType.normal.rawValue
            switch textType {
            case TextType.normal.rawValue:
                _editor.format(name: "header", value: false)
                _editor.format(name: "list", value: false)
                _editor.format(name: "blockquote", value: false)
                _editor.format(name: "code-block", value: false)
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
        case "format":
            if let args = call.arguments as? [String: Any] {
                let name = args["name"] as? String
                let value = args["value"]
                if name == nil || value == nil {
                    return
                }
                _editor.format(name: name!, value: value!)
            }
        case "formatText":
            if let args = call.arguments as? Dictionary<String, Any> {
                let index = args["index"] as? Int
                let length = args["len"] as? Int
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
                let selStart = args["selStart"] as? Int
                let selEnd = args["selEnd"] as? Int
                let ignoreFocus = args["ignoreFocus"] as? Bool
                if selStart == nil || selEnd == nil || ignoreFocus == nil {
                    return
                }
                if selEnd! > selStart! {
                    _editor.setSelection(index: selStart!, length: selEnd! - selStart!, ignoreFocus: ignoreFocus!)
                } else {
                    _editor.setSelection(index: selEnd!, length: selStart! - selEnd!, ignoreFocus: ignoreFocus!)
                }
            }

        // Editor related.
        case "focus":
            _editor.focus()
        case "blur":
            _editor.blur()
        case "scrollTo":
            if let offset = call.arguments as? Int {
                _editor.scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        case "scrollToTop":
            _editor.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        case "scrollToBottom":
            let offset = CGPoint(x: 0, y: _editor.scrollView.contentSize.height - _editor.frame.size.height)
            _editor.scrollView.setContentOffset(offset, animated: true)
        case "setPlaceholder":
            if let placeholder = call.arguments as? String {
                _editor.setPlaceholder(placeholder)
            }
        case "setReadOnly":
            if let readOnly = call.arguments as? Bool {
                _editor.setReadOnly(readOnly)
            }
        case "setScrollable":
            if let scrollable = call.arguments as? Bool {
                _editor.setScrollable(scrollable)
            }
        case "setPadding":
            if let padding = call.arguments as? [Int] {
                _editor.setPadding(padding)
            }
        case "setFileBasePath":
            if let fileBasePath = call.arguments as? String {
                _editor.setFileBasePath(fileBasePath)
            }
        case "setImageStyle":
            if let style = call.arguments as? [String: Any] {
                _editor.setImageStyle(style)
            }
        case "setVideoStyle":
            if let style = call.arguments as? [String: Any] {
                _editor.setVideoStyle(style)
            }
        case "setPlaceholderStyle":
            if let style = call.arguments as? [String: Any] {
                _editor.setPlaceholderStyle(style)
            }
            
        default:
            print("missing tun editor method")
        }
    }

}
