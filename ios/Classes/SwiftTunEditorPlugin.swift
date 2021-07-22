import Flutter
import UIKit

public class SwiftTunEditorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tun_editor", binaryMessenger: registrar.messenger())
    let instance = SwiftTunEditorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let factory = TunEditorViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "tun_editor")
    registrar.register(factory, withId: "tun_editor_toolbar")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
