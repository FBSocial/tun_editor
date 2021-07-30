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
    
    private var methodChannel: FlutterMethodChannel
    
    private var currentTextType: String = TextType.normal.rawValue
    private var currentTextStyleList: [String] =  [String]()

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        methodChannel = FlutterMethodChannel(name: "tun/editor/toolbar/\(viewId)}", binaryMessenger: messenger)
        super.init()
        
        createNativeView(view: _view)
        methodChannel.setMethodCallHandler(handle)
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView) {
        _view.backgroundColor = UIColor.white
        
        
        let stack = UIStackView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillProportionally
                
        // Toolbar.
        let toolbarStack = UIStackView(frame: CGRect(x: 0, y: 0, width: stack.bounds.width, height: 48))
        toolbarStack.axis = .horizontal
        toolbarStack.alignment = .leading
        toolbarStack.spacing = 8
        toolbarStack.backgroundColor = .lightGray
        toolbarStack.distribution = .equalCentering
        toolbarStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let ibTextType = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        ibTextType.setTitle("T", for: .normal)
        ibTextType.setTitleColor(.black, for: .normal)
        ibTextType.addTarget(self, action: #selector(toggleTextType), for: .touchUpInside)
        ibTextType.backgroundColor = .green
        ibTextType.layer.cornerRadius = 10
        
        let ibTextStyle = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        ibTextStyle.setTitle("A", for: .normal)
        ibTextStyle.setTitleColor(.black, for: .normal)
        ibTextStyle.addTarget(self, action: #selector(toggleTextStyle), for: .touchUpInside)
        ibTextStyle.backgroundColor = .green
        ibTextStyle.layer.cornerRadius = 10
        toolbarStack.addArrangedSubview(ibTextType)
        toolbarStack.addArrangedSubview(ibTextStyle)
        
        // Sub toolbar.
        let subToolbarStack = UIStackView(frame: CGRect(x: 0, y: 0, width: stack.bounds.width, height: 48))
        subToolbarStack.backgroundColor = .cyan
        subToolbarStack.axis = .horizontal
        subToolbarStack.spacing = 8
        subToolbarStack.distribution = .equalSpacing
        subToolbarStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        // Bold button
        let ibBold = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        ibBold.setTitle("B", for: .normal)
        ibBold.setTitleColor(.black, for: .normal)
        ibBold.addTarget(self, action: #selector(setBold), for: .touchUpInside)
        ibBold.backgroundColor = .green
        ibBold.layer.cornerRadius = 10
        
        let ibItalic = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        ibItalic.setTitle("I", for: .normal)
        ibItalic.setTitleColor(.black, for: .normal)
        ibItalic.addTarget(self, action: #selector(setBold), for: .touchUpInside)
        ibItalic.backgroundColor = .green
        ibItalic.layer.cornerRadius = 10
        
        let ibUnderline = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        ibUnderline.setTitle("U", for: .normal)
        ibUnderline.setTitleColor(.black, for: .normal)
        ibUnderline.addTarget(self, action: #selector(setBold), for: .touchUpInside)
        ibUnderline.backgroundColor = .green
        ibUnderline.layer.cornerRadius = 10
        
        let ibStrikeThrough = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        ibStrikeThrough.setTitle("S", for: .normal)
        ibStrikeThrough.setTitleColor(.black, for: .normal)
        ibStrikeThrough.addTarget(self, action: #selector(setBold), for: .touchUpInside)
        ibStrikeThrough.backgroundColor = .green
        ibStrikeThrough.layer.cornerRadius = 10

        subToolbarStack.addArrangedSubview(ibBold)
        subToolbarStack.addArrangedSubview(ibItalic)
        subToolbarStack.addArrangedSubview(ibUnderline)
        subToolbarStack.addArrangedSubview(ibStrikeThrough)

        stack.addArrangedSubview(subToolbarStack)
        stack.addArrangedSubview(toolbarStack)

        _view.addSubview(stack)
    }
    
    @objc func setBold() {
        print("setBold")
        debugPrint("set bold in debug")
        let styleList = ["bold"]
        methodChannel.invokeMethod("setTextStyle", arguments: styleList)
    }
    
    @objc func toggleTextType(_ textType: String) {
        if (textType == currentTextType) {
            // Remove text type.
            currentTextType = TextType.normal.rawValue
        } else {
            // Set new text type.
            currentTextType = textType
        }
        refreshTextTypeView()
        methodChannel.invokeMethod("setTextType", arguments: currentTextType)
    }
    
    @objc func toggleTextStyle(_ textStyle: String) {
        if let index = (currentTextStyleList.firstIndex(of: textStyle)) {
            currentTextStyleList.remove(at: index)
        } else {
            currentTextStyleList.append(textStyle)
        }
        refreshTextStyleView()
        methodChannel.invokeMethod("setTextStyle", arguments: currentTextStyleList)
    }
    
    @objc func refreshTextTypeView() {
        // Disable all text type.
        
        // Enable current text type.
        switch currentTextType {
        case TextType.headline1.rawValue:
            // TODO hightlight button
            print("headline1")
        default:
            print("missing text type")
        }
    }
    
    @objc func refreshTextStyleView() {
        // Disable all text style.
        
        // Enable actived text style.
        switch currentTextType {
        case TextStyle.bold.rawValue:
            // TODO hightlight button
            print("bold")
        default:
            print("missing text style")
        }

    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "onSelectionChanged":
            print("on selection changed")
            break
        default:
            print("missing channel method: \(call.method)")
        }
    }


}
