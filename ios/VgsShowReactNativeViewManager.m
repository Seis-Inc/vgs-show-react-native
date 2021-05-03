#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(VgsShowReactNativeViewManager, RCTViewManager)

// Styling
RCT_EXPORT_VIEW_PROPERTY(textColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(placeholderColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(bgColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(borderColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(fontFamily, NSString)
RCT_EXPORT_VIEW_PROPERTY(borderRadius, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(characterSpacing, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(placeholder, NSString)
RCT_EXPORT_VIEW_PROPERTY(contentPath, NSString)

// Functionality
RCT_EXPORT_VIEW_PROPERTY(initParams, NSDictionary)

RCT_EXTERN_METHOD(revealData:(nonnull NSNumber *)node path:(nonnull NSString *)path method:(NSString *)method payload:(NSDictionary *)payload
          resolver:(RCTPromiseResolveBlock)resolve
          rejecter:(RCTPromiseRejectBlock)reject)

@end
