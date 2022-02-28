//
//  ConsentBroadcast.m
//  NativeUIReact
//
//  Created by Oliver Spirito on 10/19/20.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(OneTrustConsentBroadcast, RCTEventEmitter)
RCT_EXTERN_METHOD(setAllowedCategories:(NSArray*)allowedEvents)
RCT_EXTERN_METHOD(listenForConsentChanges:(NSString*)category)
RCT_EXTERN_METHOD(stopListeningForConsentChanges)

+ (BOOL)requiresMainQueueSetup{
  return YES;
}

@end
