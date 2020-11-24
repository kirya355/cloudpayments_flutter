#import "CloudpaymentsFlutterPlugin.h"
#if __has_include(<cloudpayments_flutter/cloudpayments_flutter-Swift.h>)
#import <cloudpayments_flutter/cloudpayments_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "cloudpayments_flutter-Swift.h"
#endif

@implementation CloudpaymentsFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCloudpaymentsFlutterPlugin registerWithRegistrar:registrar];
}
@end
