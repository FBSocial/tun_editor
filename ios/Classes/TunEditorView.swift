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
        _editor = QuillEditorView(frame: frame, configuration: configuration)
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
//        case "undo":
//            if (_editor.undoManager?.canUndo == true) {
//                _editor.undoManager?.undo()
//            }
//        case "redo":
//            if (_editor.undoManager?.canRedo == true) {
//                _editor.undoManager?.redo()
//            }
//        case "clearTextType":
//            _editor.removeFormat()
//        case "clearTextStyle":
//            _editor.removeFormat()
//        case "setTextType":
            // Remove format first.
//            _editor.removeFormat()
//            let textType: String = call.arguments is String
//                ? call.arguments as! String
//                : TextType.normal.rawValue
//            switch textType {
//            case TextType.headline1.rawValue:
//                _editor.header(1)
//            case TextType.headline2.rawValue:
//                _editor.header(2)
//            case TextType.headline3.rawValue:
//                _editor.header(3)
//            case TextType.listBullet.rawValue:
//                _editor.unorderedList()
//            case TextType.listOrdered.rawValue:
//                _editor.orderedList()
//            case TextType.quote.rawValue:
//                _editor.blockquote()
//            default:
//                print("missing text type")
//            }
//        case "setTextStyle":
//            _editor.removeFormat()
//            if let styles = call.arguments as? [String] {
//                if styles.contains(TextStyle.bold.rawValue) {
//                    _editor.bold()
//                }
//                if styles.contains(TextStyle.italic.rawValue) {
//                    _editor.italic()
//                }
//                if styles.contains(TextStyle.underline.rawValue) {
//                    _editor.underline()
//                }
//                if styles.contains(TextStyle.strikeThrough.rawValue) {
//                    _editor.strikethrough()
//                }
//            }
//        case "updateSelection":
//        case "formatText":
//        case "replaceText":
//        case "insert":
        case "insertDivider":
            _editor.insertDivider()
//        case "insertImage":
            
        default:
            print("missing tun editor method")
        }
    }

}
