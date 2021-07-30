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
        _editor = RichEditorView(frame: UIScreen.main.bounds)
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
        switch call.method {
        case "undo":
            if (_editor.undoManager?.canUndo == true) {
                _editor.undoManager?.undo()
            }
        case "redo":
            if (_editor.undoManager?.canRedo == true) {
                _editor.undoManager?.redo()
            }
        default:
            print("missing tun editor method")
        }
    }

}
