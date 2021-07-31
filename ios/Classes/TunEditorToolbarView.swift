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

    private let _view = UIView()
    
    // Toolbar related.
    private let stackToolbar = UIStackView()
    private let btnAt = UIButton()
    private let btnImage = UIButton()
    private let btnEmoji = UIButton()
    private let btnTextType = UIButton()
    private let btnTextStyle = UIButton()
    
    // Text type related.
    private let stackTextType = UIStackView()
    private let btnHeadline1 = UIButton()
    private let btnHeadline2 = UIButton()
    private let btnHeadline3 = UIButton()
    private let btnListBullet = UIButton()
    private let btnListOrdered = UIButton()
    private let btnDivider = UIButton()
    private let btnQuote = UIButton()
    private let btnCodeBlock = UIButton()
    
    // Text style related.
    private let stackTextStyle = UIStackView()
    private let btnBold = UIButton()
    private let btnItalic = UIButton()
    private let btnUnderline = UIButton()
    private let btnStrikThrough = UIButton()
    
    private var methodChannel: FlutterMethodChannel
    
    private var currentTextType: String = TextType.normal.rawValue
    private var currentTextStyleList: [String] =  [String]()

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        methodChannel = FlutterMethodChannel(name: "tun/editor/toolbar/\(viewId)", binaryMessenger: messenger)
        super.init()
        
        initView(view: _view)
        methodChannel.setMethodCallHandler(handle)
    }

    func view() -> UIView {
        return _view
    }
    
    func initView(view _view: UIView) {
        _view.backgroundColor = UIColor.white
        _view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
                
        // Toolbar.
        stackToolbar.frame = CGRect(x: 0, y: 0, width: _view.bounds.width, height: 48)
        stackToolbar.axis = .horizontal
        stackToolbar.alignment = .leading
        stackToolbar.spacing = 8
        stackToolbar.backgroundColor = .lightGray
        stackToolbar.distribution = .equalCentering
        stackToolbar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        setupButton(btnAt, "toolbar_at", #selector(onAtClick))
        setupButton(btnImage, "toolbar_image", #selector(self.onImageClick))
        setupButton(btnEmoji, "toolbar_emoji", #selector(self.onEmojiClick))
        setupButton(btnTextType, "toolbar_font_type", #selector(self.toggleTextTypeToolbar))
        setupButton(btnTextStyle, "toolbar_font_style", #selector(self.toogleTextStyleToolbar))
        stackToolbar.addArrangedSubview(btnAt)
        stackToolbar.addArrangedSubview(btnImage)
        stackToolbar.addArrangedSubview(btnEmoji)
        stackToolbar.addArrangedSubview(btnTextType)
        stackToolbar.addArrangedSubview(btnTextStyle)
        
        // Text type toolbar.
        stackTextType.frame = CGRect(x: 0, y: 0, width: _view.bounds.width, height: 48)
        stackTextType.backgroundColor = .white
        stackTextType.axis = .horizontal
        stackTextType.spacing = 8
        stackTextType.distribution = .equalSpacing
        stackTextType.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        setupButton(btnHeadline1, "toolbar_h1", #selector(self.onTextTypeBtnClick), tag: TextType.headline1.viewTag())
        setupButton(btnHeadline2, "toolbar_h2", #selector(self.onTextTypeBtnClick), tag: TextType.headline2.viewTag())
        setupButton(btnHeadline3, "toolbar_h3", #selector(self.onTextTypeBtnClick), tag: TextType.headline3.viewTag())
        setupButton(btnListBullet, "toolbar_list", #selector(self.onTextTypeBtnClick), tag: TextType.listBullet.viewTag())
        setupButton(btnListOrdered, "toolbar_ordered_list", #selector(self.onTextTypeBtnClick), tag: TextType.listOrdered.viewTag())
        setupButton(btnDivider, "toolbar_divider", #selector(self.onTextTypeBtnClick), tag: TextType.divider.viewTag())
        setupButton(btnQuote, "toolbar_quote", #selector(self.onTextTypeBtnClick), tag: TextType.quote.viewTag())
        setupButton(btnCodeBlock, "toolbar_code_block", #selector(self.onTextTypeBtnClick), tag: TextType.codeBlock.viewTag())
        stackTextType.addArrangedSubview(btnHeadline1)
        stackTextType.addArrangedSubview(btnHeadline2)
        stackTextType.addArrangedSubview(btnHeadline3)
        stackTextType.addArrangedSubview(btnListBullet)
        stackTextType.addArrangedSubview(btnListOrdered)
        stackTextType.addArrangedSubview(btnDivider)
        stackTextType.addArrangedSubview(btnQuote)
        stackTextType.addArrangedSubview(btnCodeBlock)

        // Text style toolbar.
        setupButton(btnBold, "toolbar_bold", #selector(self.onTextStyleClick), tag: TextStyle.bold.viewTag())
        setupButton(btnItalic, "toolbar_italic", #selector(self.onTextStyleClick), tag: TextStyle.italic.viewTag())
        setupButton(btnUnderline, "toolbar_underline", #selector(self.onTextStyleClick), tag: TextStyle.underline.viewTag())
        setupButton(btnStrikThrough, "toolbar_strike_through", #selector(self.onTextStyleClick), tag: TextStyle.strikeThrough.viewTag())
        stackTextStyle.addArrangedSubview(btnBold)
        stackTextStyle.addArrangedSubview(btnItalic)
        stackTextStyle.addArrangedSubview(btnUnderline)
        stackTextStyle.addArrangedSubview(btnStrikThrough)
        
        _view.addSubview(stackToolbar)
        _view.addSubview(stackTextType)
        _view.addSubview(stackTextStyle)
    }
    
    @objc func onAtClick() {
        print("on at click")
        methodChannel.invokeMethod("onAtClick", arguments: nil)
    }
    
    @objc func onImageClick() {
        print("on image click")
        methodChannel.invokeMethod("onImageClick", arguments: nil)
    }
    
    @objc func onEmojiClick() {
        print("on emoji click")
        methodChannel.invokeMethod("onEmojiClick", arguments: nil)
    }
    
    @objc func onTextTypeBtnClick(_ sender: UIButton) {
        switch sender.tag {
        case TextType.headline1.viewTag():
            toggleTextType(TextType.headline1.rawValue)
        case TextType.headline2.viewTag():
            toggleTextType(TextType.headline2.rawValue)
        case TextType.headline3.viewTag():
            toggleTextType(TextType.headline3.rawValue)
        case TextType.listBullet.viewTag():
            toggleTextType(TextType.listBullet.rawValue)
        case TextType.listOrdered.viewTag():
            toggleTextType(TextType.listOrdered.rawValue)
        case TextType.divider.viewTag():
            methodChannel.invokeMethod("insertDivider", arguments: nil)
        case TextType.quote.viewTag():
            toggleTextType(TextType.quote.rawValue)
        case TextType.codeBlock.viewTag():
            toggleTextType(TextType.codeBlock.rawValue)
        default:
            print("missing tag on text type button click")
        }
    }
    
    @objc func onTextStyleClick(_ sender: UIButton) {
        switch sender.tag {
        case TextStyle.bold.viewTag():
            toggleTextStyle(TextStyle.bold.rawValue)
        case TextStyle.italic.viewTag():
            toggleTextStyle(TextStyle.italic.rawValue)
        case TextStyle.underline.viewTag():
            toggleTextStyle(TextStyle.underline.rawValue)
        case TextStyle.strikeThrough.viewTag():
            toggleTextStyle(TextStyle.strikeThrough.rawValue)
        default:
            print("missing tag on text style button click")
        }
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
            print("missing text type in current text type")
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
            print("missing text style in current text style")
        }
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "onSelectionChanged":
            print("on selection changed")
            break
        default:
            print("missing channel method: \(call.method)")
        }
    }
    
    @objc func toggleTextTypeToolbar() {
        print("toggle text type toolbar")
    }
    
    @objc func toogleTextStyleToolbar() {
        print("toggle text style toolbar")
    }
    
    func setupButton(_ btn: UIButton, _ imageName: String, _ selector: Selector, tag: Int = -1) {
        btn.setImage(UIImage(named: imageName, in: Bundle.main, compatibleWith: nil), for: .normal)
        btn.backgroundColor = UIColor(red: 238, green: 239, blue: 240, alpha: 1)
        btn.layer.cornerRadius = 4
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        btn.tag = tag
        btn.addTarget(self, action: selector, for: .touchUpInside)
    }

}
