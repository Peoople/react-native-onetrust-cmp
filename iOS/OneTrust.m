//
//  OneTrust.m
//  NativeUIReact
//
//  Created by Oliver Spirito on 8/11/20.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(OneTrust, NSObject)
+ (BOOL)requiresMainQueueSetup{
  return YES;
}
RCT_EXTERN_METHOD(startSDK:
                  (NSString *)storageLocation
                  domainIdentifier:(NSString *)domainIdentifier
                   languageCode:(NSString *)languageCode
                   params:(NSDictionary *)params
                   autoShowBanner:(BOOL *)autoShowBanner
                   resolve:(RCTPromiseResolveBlock)resolve
                   rejecter:(RCTPromiseRejectBlock)reject
                  )

RCT_EXTERN_METHOD(getOTConsentJSForWebView:
                  (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )

RCT_EXTERN_METHOD(shouldShowBanner:
                  (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )

RCT_EXTERN_METHOD(getConsentStatusForCategory:
                  (NSString*)categoryId
                  resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(showBannerUI)

RCT_EXTERN_METHOD(showPreferenceCenterUI)

RCT_EXTERN_METHOD(showConsentUI:
                  (int*)permissionType
                  resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getATTStatus:
                  (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )

//Universal Consent Methods
RCT_EXTERN_METHOD(showConsentPurposesUI)

RCT_EXTERN_METHOD(getUCPurposeConsent:
                  (NSString *)purposeId
                  resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )

RCT_EXTERN_METHOD(getUCCustomPreferenceConsent:
                  (NSString *)customPreferenceOptionId
                  customPreferenceId:(NSString *)customPreferenceId
                  purposeId:(NSString *)purposeId
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject
                  )

RCT_EXTERN_METHOD(getUCTopicConsent:
                  (NSString *)topicOption
                  purposeId:(NSString *)purposeId
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject
                  )

RCT_EXTERN_METHOD(updateUCPurposeConsent:
                  (NSString *)purposeId
                  consent:(BOOL *)consent
                  )

RCT_EXTERN_METHOD(updateUCCustomPreferenceConsent:
                  (NSString *)customPrefOptionId
                  customPrefId:(NSString *)customPrefId
                  purposeId:(NSString *)purposeId
                  consent:(BOOL *)consent
                  )

RCT_EXTERN_METHOD(updateUCTopicConsent:
                  (NSString *)topicOptionId
                  purposeId:(NSString *)purposeId
                  consent:(BOOL *)consent
                  )

RCT_EXTERN_METHOD(saveUCConsent)
@end