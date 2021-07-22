import Flutter
import UIKit

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
        let toolbar = HStack(
            alignment: .center,
            spacing: 20,
            content: {
                Button {
                    Text("Undo")
                }
                Button {
                    Text("Undo")
                }
                Button {
                    Text("Bold")
                }
            }
        )
        // .frame(height: 100, maxWidth: .infinity)
        _view.addSubview(toolbar)
    }

}
