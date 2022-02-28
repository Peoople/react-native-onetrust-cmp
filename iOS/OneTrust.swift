//
// OneTrust.swift
//  NativeUIReact
//
//  Created by Oliver Spirito on 8/11/20.
//

import Foundation
import OTPublishersHeadlessSDK
import AppTrackingTransparency

@objc(OneTrust) class OneTrust: NSObject{
    ///Initializer
    @objc(startSDK:domainIdentifier:languageCode:params:autoShowBanner:resolve:rejecter:)
    public func startSDK(_ storageLocation:String!,
                         domainIdentifier:String!,
                         languageCode:String!,
                         params:NSDictionary?,
                         autoShowBanner:Bool=false,
                         resolve:@escaping RCTPromiseResolveBlock,
                         rejecter reject: @escaping RCTPromiseRejectBlock) -> Void{
        
        let otParams = OTSdkParams(countryCode: params?["countryCode"] as? String, regionCode: params?["regionCode"] as? String)
        
        if let version = params?["sdkVersion"] as? String{
            otParams.setSDKVersion(version)
        }
        
        
        ///Check for profile sync params
        if let syncParams = params?["profileSyncParams"] as? NSDictionary,
           let identifier = syncParams["identifier"] as? String,
           let jwt = syncParams["syncProfileAuth"] as? String{
            let profileSyncParams = OTProfileSyncParams()
            profileSyncParams.setIdentifier(identifier)
            profileSyncParams.setSyncProfileAuth(jwt)
            profileSyncParams.setSyncProfile("true")
            
            otParams.setShouldCreateProfile("true") //force profile to sync
            otParams.setProfileSyncParams(profileSyncParams) //Add sync params to otParams object
        }
        
        ///Initialize SDK
        OTPublishersHeadlessSDK.shared.startSDK(storageLocation: storageLocation, domainIdentifier: domainIdentifier, languageCode: languageCode, params: otParams){(response) in
            if(response.status){
                DispatchQueue.main.async {
                    if let vc = UIApplication.shared.keyWindow?.rootViewController{
                        OTPublishersHeadlessSDK.shared.setupUI(vc)
                        if(autoShowBanner && OTPublishersHeadlessSDK.shared.shouldShowBanner()){
                            OTPublishersHeadlessSDK.shared.showBannerUI()
                        }
                    }
                }
                resolve(["status":response.status, "error":response.error.debugDescription, "responseString":response.responseString ?? ""])
            }else{
                reject("Error downloading OneTrust Data", response.error.debugDescription, response.error)
            }
        }
    }
    
    @objc(getOTConsentJSForWebView:rejecter:)
    public func getOTConsentJSForWebView(_ resolve:@escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock){
        let js = OTPublishersHeadlessSDK.shared.getOTConsentJSForWebView()
        resolve(js)
    }
    
    @objc(shouldShowBanner:rejecter:)
    public func shouldShowBanner(_ resolve:@escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void{
        let shouldShowBanner = OTPublishersHeadlessSDK.shared.shouldShowBanner()
        resolve(shouldShowBanner)
    }
    
    @objc(getConsentStatusForCategory:resolve:rejecter:)
    public func getConsentStatusForCategory(_ categoryId:NSString, resolve:@escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void{
        let consentStatus = OTPublishersHeadlessSDK.shared.getConsentStatus(forCategory: categoryId as String)
        resolve(consentStatus)
    }
    //MARK: Display CMP UI
    @objc(showBannerUI)
    public func showBannerUI(){
        OTPublishersHeadlessSDK.shared.showBannerUI()
    }
    
    @objc(showPreferenceCenterUI)
    public func showPreferenceCenterUI(){
        OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()
    }
    
    //MARK: App Tracking Transparency
    @objc(getATTStatus:rejecter:)
    public func getATTStatus(_ resolve:@escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock){
        resolve(getATTStatusAsString())
    }
    
    @objc(showConsentUI:resolve:rejecter:)
    public func showConsentUI(_ permissionType:Int, resolve:@escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock){
        guard #available(iOS 14, *) else { //version check, returns immediately if lower than iOS 14
            resolve(nil)
            return
        }
        var type:AppPermissionType? = nil
        
        switch permissionType{
        case 0:
            type = .idfa
        default:
            reject("Permission type not recognized", "Only pass in enum OTdevicePermission", nil)
            return
        }
        
        DispatchQueue.main.async{
            if let type = type,
               let vc = UIApplication.shared.keyWindow?.rootViewController{
                OTPublishersHeadlessSDK.shared.showConsentUI(for: type, from: vc, completion: {
                    resolve(nil)
                })
            }
        }
    }
    
    //MARK: Universal Consent
    @objc(showConsentPurposesUI)
    public func showConsentPurposesUI(){
        DispatchQueue.main.async{
            if let vc = UIApplication.shared.keyWindow?.rootViewController{
                OTPublishersHeadlessSDK.shared.showConsentPurposesUI(vc)
            }
        }
    }
    
    //Gets the consent value (int) for the UC Purpose passed in
    @objc(getUCPurposeConsent:resolve:rejecter:)
    public func getUCPurposeConsent(_ purposeId:String!,
                                    resolve:@escaping RCTPromiseResolveBlock,
                                    rejecter reject: @escaping RCTPromiseRejectBlock){
        let consent = OTPublishersHeadlessSDK.shared.getUCPurposeConsent(purposeId: purposeId) ? 1:0
        resolve(consent)
    }
    
    //Gets the consent value (int) for the custom pref passed in
    @objc(getUCCustomPreferenceConsent:customPreferenceId:purposeId:resolve:reject:)
    public func getUCCustomPreferenceConsent(_ customPreferenceOptionId:String!,
                                             customPreferenceId:String!,
                                             purposeId:String!,
                                             resolve:@escaping RCTPromiseResolveBlock,
                                             rejecter reject: @escaping RCTPromiseRejectBlock){
        let customPrefConsent = OTPublishersHeadlessSDK.shared.getUCPurposeConsent(cpId: customPreferenceId, purposeId: purposeId)
        let consent = customPrefConsent[customPreferenceOptionId]
        
        resolve(consent)
    }
    
    @objc(getUCTopicConsent:purposeId:resolve:reject:)
    public func getUCTopicConsent(_ topicOption:String!,
                                  purposeId:String!,
                                  resolve:@escaping RCTPromiseResolveBlock,
                                  rejecter reject: @escaping RCTPromiseRejectBlock){
        let consent = OTPublishersHeadlessSDK.shared.getUCPurposeConsent(topicOption: topicOption, purposeId: purposeId) ? 1:0
        resolve(consent)
    }
    @objc(updateUCCustomPreferenceConsent:customPrefId:purposeId:consent:)
    public func updateUCCustomPreferenceConsent(_ customPrefOptionId:String!,
                                                customPrefId:String,
                                                purposeId:String!,
                                                consent:Bool){
        
        OTPublishersHeadlessSDK.shared.updateUCPurposeConsent(cpOptionId: customPrefOptionId,
                                                              cpId: customPrefId,
                                                              purposeId: purposeId,
                                                              withConsent: consent)
    }
    
    @objc(updateUCPurposeConsent:consent:)
    public func updateUCPurposeConsent(_ purposeId:String!,
                                       consent:Bool){
        
        OTPublishersHeadlessSDK.shared.updateUCPurposeConsent(purposeId: purposeId,
                                                              withConsent: consent)
    }
    
    @objc(updateUCTopicConsent:purposeId:consent:)
    public func updateUCTopicConsent(_ topicOptionId:String!,
                                     purposeId:String!,
                                     consent:Bool){
        
        OTPublishersHeadlessSDK.shared.updateUCPurposeConsent(topicOptionId: topicOptionId,
                                                              purposeId: purposeId,
                                                              withConsent: consent)
    }
    
    @objc(saveUCConsent)
    public func saveUCConsent(){
        OTPublishersHeadlessSDK.shared.saveConsent(type: .consentPurposesClose)
    }
    
    private func getATTStatusAsString() -> String?{
        guard #available(iOS 14, *) else {return nil}
        let statusMap:[ATTrackingManager.AuthorizationStatus:String] = [.authorized:"authorized", .denied:"denied", .notDetermined:"notDetermined", .restricted:"restricted"]
        let status = statusMap[ATTrackingManager.trackingAuthorizationStatus]
        return status
    }
}
