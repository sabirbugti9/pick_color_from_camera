#import "ColorPickerCameraPlugin.h"
#if __has_include(<pick_color_from_camera/pick_color_from_camera-Swift.h>)
#import <pick_color_from_camera/pick_color_from_camera-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pick_color_from_camera-Swift.h"
#endif

@implementation ColorPickerCameraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftColorPickerCameraPlugin registerWithRegistrar:registrar];
}
@end
