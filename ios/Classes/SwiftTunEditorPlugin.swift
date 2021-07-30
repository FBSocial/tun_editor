import Flutter
import UIKit

public class SwiftTunEditorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let channel = FlutterMethodChannel(name: "tun_editor", binaryMessenger: messenger)
    let instance = SwiftTunEditorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let tunEditorViewFactory = TunEditorViewFactory(messenger: messenger)
//    let tunEditorToolbarViewFactory = TunEditorToolbarViewFactory(messenger: messenger)
    registrar.register(tunEditorViewFactory, withId: "tun_editor")
    registrar.register(tunEditorViewFactory, withId: "tun_editor_toolbar")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
