import Flutter
import UIKit
import SwiftUI
import RichEditorView

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

    private var _view: UIView
    private var _editor: RichEditorView
    
    private var methodChannel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        _editor = RichEditorView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
        methodChannel = FlutterMethodChannel(name: "tun/editor/\(viewId)", binaryMessenger: messenger)

        super.init()
        createNativeView(view: _view)
        
        methodChannel.setMethodCallHandler(handle)
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView) {
        _editor.html = "<h1>My Awesome Editor</h1>Now I am editing in <em>style.</em>"
        _view.addSubview(_editor)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        debugPrint("handle method in tun editor: \(call.method)")
        switch call.method {
        case "undo":
            if (_editor.undoManager?.canUndo == true) {
                _editor.undoManager?.undo()
            }
        case "redo":
            if (_editor.undoManager?.canRedo == true) {
                _editor.undoManager?.redo()
            }
        case "clearTextType":
            _editor.removeFormat()
        case "clearTextStyle":
            _editor.removeFormat()
        case "setTextType":
            // Remove format first.
            _editor.removeFormat()
            let textType: String = call.arguments is String
                ? call.arguments as! String
                : TextType.normal.rawValue
            switch textType {
            case TextType.headline1.rawValue:
                _editor.header(1)
            case TextType.headline2.rawValue:
                _editor.header(2)
            case TextType.headline3.rawValue:
                _editor.header(3)
            case TextType.listBullet.rawValue:
                _editor.unorderedList()
            case TextType.listOrdered.rawValue:
                _editor.orderedList()
            case TextType.quote.rawValue:
                _editor.blockquote()
            default:
                print("missing text type")
            }
        case "setTextStyle":
            _editor.removeFormat()
            if let styles = call.arguments as? [String] {
                if styles.contains(TextStyle.bold.rawValue) {
                    _editor.bold()
                }
                if styles.contains(TextStyle.italic.rawValue) {
                    _editor.italic()
                }
                if styles.contains(TextStyle.underline.rawValue) {
                    _editor.underline()
                }
                if styles.contains(TextStyle.strikeThrough.rawValue) {
                    _editor.strikethrough()
                }
            }
//        case "updateSelection":
//        case "formatText":
//        case "replaceText":
//        case "insert":
//        case "insertDivider":
//        case "insertImage":
            
        default:
            print("missing tun editor method")
        }
    }

}
