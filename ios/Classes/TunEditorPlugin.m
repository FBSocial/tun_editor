#import "TunEditorPlugin.h"
#if __has_include(<tun_editor/tun_editor-Swift.h>)
#import <tun_editor/tun_editor-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tun_editor-Swift.h"
#endif

@implementation TunEditorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTunEditorPlugin registerWithRegistrar:registrar];
}
@end
