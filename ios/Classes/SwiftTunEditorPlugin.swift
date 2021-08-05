import Flutter
import UIKit

public class SwiftTunEditorPlugin: NSObject, FlutterPlugin {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    
    let tunEditorViewFactory = TunEditorViewFactory(messenger: messenger)
    registrar.register(tunEditorViewFactory, withId: "tun_editor")
  }
    
}
