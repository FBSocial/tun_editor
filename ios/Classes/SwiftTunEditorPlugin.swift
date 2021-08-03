import Flutter
import UIKit

public class SwiftTunEditorPlugin: NSObject, FlutterPlugin {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    
    let tunEditorViewFactory = TunEditorViewFactory(messenger: messenger)
    let tunEditorToolbarViewFactory = TunEditorToolbarViewFactory(messenger: messenger)
    registrar.register(tunEditorViewFactory, withId: "tun_editor")
    registrar.register(tunEditorToolbarViewFactory, withId: "tun_editor_toolbar")
  }
    
}
