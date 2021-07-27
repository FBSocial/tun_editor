import Flutter
import UIKit
import SwiftUI


class TunEditorToolbarViewFactory: NSObject, FlutterPlatformViewFactory {

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
        return TunEditorToolbarView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }

}

class TunEditorToolbarView: NSObject, FlutterPlatformView {

    private var _view: UIView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()
        createNativeView(view: _view)
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView) {
        let label = UILabel()
        label.text = "Undo"
        label.textColor = UIColor.systemPink
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: 180, height: 48)
        _view.addSubview(label)
    }
    
    @objc func undo() {
        print("undo")
    }
    
    func redo() {
        print("redo")
    }
    
    func setBold() {
        print("setBold")
    }



}
