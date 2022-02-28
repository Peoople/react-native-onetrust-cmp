//
//  EventEmitter.swift
//  NativeUIReact
//
//  Created by Oliver Spirito on 10/19/20.
//

import Foundation
import OTPublishersHeadlessSDK

@objc(OneTrustConsentBroadcast)
class OneTrustConsentBroadcast:RCTEventEmitter{
  var allowedEvents = [String]()
  
  @objc func setAllowedCategories(_ eventsList:[String]){
    self.allowedEvents = eventsList
  }
  
  override func supportedEvents() -> [String]! {
    return self.allowedEvents
  }
  
  @objc(listenForConsentChanges:)
  func listenForConsentChanges(_ category:String!){
    if(!allowedEvents.contains(category)){
      print("‼️ \(category!) has not been added to Allow Events. Call OTPublishersNativeSDK.setBroadcastAllowedValues(['\(category!)'] before adding a listener.")
      return
    }
      NotificationCenter.default.addObserver(self, selector: #selector(consentChanged(_:)), name: NSNotification.Name(category), object: nil)
  }
  @objc(stopListeningForConsentChanges)
  func stopListeningForConsentChanges(){
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func consentChanged(_ notification:Notification){
    print("Consent Changed!")
    let consentCategory = notification.name.rawValue
    let consentStatus = notification.object as! Int
    sendEvent(withName: consentCategory, body: consentStatus)
  }
}
