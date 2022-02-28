import {
  NativeModules,
  Platform,
  NativeEventEmitter,
  DeviceEventEmitter,
} from 'react-native';

const OneTrust = NativeModules.OneTrust;
const iOSBroadcast = NativeModules.OneTrustConsentBroadcast;

export default class OTPublishersNativeSDK{
  /**
   * @param {string} storageLocation  Usually cdn.cookielaw.org - this value comes from your Admin Console
   * @param {string} domainIdentifier Also called App ID, this comes from your Admin Console and is a GUID. It may have -test on the end if it's the test version.
   * @param {string} languageCode  The 2-digit ISO Language code
   * @param {object} params  Currently accepts countryCode, regionCode, and profileSyncParams
   * @param {string} params.countryCode  Two-digit ISO country code for the user
   * @param {string} params.regionCode  Two-digit ISO region code for the user
   * @param {string} params.androidUXParams Stringified JSON object containing the UXParams object to override 
   * @param {[key:string]:string} params.profileSyncParams JSON Object containing 'identifier' and 'profileSyncAuth' values
   * @param {boolean} autoShowBanner Should the banner be shown automatically when download is complete? Takes the shouldShowBanner logic into account
   * @returns {Promise} Promise object contains status of download, error (if download fails), and responseString, which is a JSON string representing the data downloaded from the OneTrust server.
   */
   static async startSDK(storageLocation:string, domainIdentifier:string, languageCode:string, params:{[key:string]:string|{[key:string]:string}},autoShowBanner:boolean):Promise<object>{
    return OneTrust.startSDK(storageLocation,domainIdentifier,languageCode, params, autoShowBanner)
  }

  /**
   * Force load the banner
   */
  static showBannerUI():void {
    OneTrust.showBannerUI();
  } 

  /**
   * Load the OneTrust Preference Center, usually placed behind a button
   */
  static showPreferenceCenterUI():void {
    OneTrust.showPreferenceCenterUI();
  }

  /**
   * Determine whether or not the banner should be shown
   * @returns {promise} Promise object is a boolean indicating whether or not the banner should be shown
   */
  static shouldShowBanner():Promise<boolean> {
    return OneTrust.shouldShowBanner();
  }

  /**
   * Get the current consent status for the given category
   * @param {string} categoryId String of the category ID for which you'd like to retrieve consent
   * @returns {number} 1 = consent given; 0 = consent not given; -1 = category does not exist or SDK not initialized
   */
  static getConsentStatusForCategory(categoryId:string):Promise<number> {
    return OneTrust.getConsentStatusForCategory(categoryId);
  }

  /**
   * Sets the values that can be observed. Required for iOS.
   * @param {array} categories Array of strings indicating which categories will have listeners activated in subsequent calls.
   */
  static setBroadcastAllowedValues(categories:string[]) {
    if (Platform.OS !== 'android') {
      iOSBroadcast.setAllowedCategories(categories);
    }
  }

  /**
   * Listen for consent changes to a particular category
   * @param {string} category String of the category ID to listen for
   * @callback 
   * @param {string} category Category that was changed. Matches the category in listener registration
   * @param {number} consent Consent value (1 = consent given, 0 = consent not given)
   * @returns {object} Returns an event emitter that can be unsubscribed from when your component dismounts
   */
  static listenForConsentChanges(category:string, callback = function (category:string,consent:number) {}) {
    if (Platform.OS === 'android') {
      OneTrust.listenForConsentChanges(category);
      DeviceEventEmitter.addListener(category, (consent:number) =>
        callback(category, consent),
      );
    } else {
      iOSBroadcast.listenForConsentChanges(category);
      const consentListener = new NativeEventEmitter(iOSBroadcast);
      consentListener.addListener(category, (consent:number) =>
        callback(category, consent),
      );
    }
  }

  /**
   * Stop the platform code from emitting events
   */
  static stopListeningForConsentChanges() {
    if(Platform.OS === 'android'){
      OneTrust.stopListeningForConsentChanges();
    }else{
      iOSBroadcast.stopListeningForConsentChanges();
    }
  }

  /**
   * @returns Promise object is a string of the JS to inject in your webview
   */
  static getOTConsentJSForWebView():Promise<string>{
    return OneTrust.getOTConsentJSForWebView();
  }

  /**
   * [iOS Only] Show consent for device-level permission.
   * Promise resolved immediately on Android
   */
  static showConsentUI(permissionType:OTDevicePermission):Promise<void>{
    if(Platform.OS == 'ios'){
      return OneTrust.showConsentUI(permissionType)
    }else{
      return Promise.resolve()
    }
  }

  /**
   * [iOS Only] Get status of iOS App Tracking Transparency
   * Only valid for iOS 14+
   * @returns String: 'authorized', 'denied','notDetermined',or 'restricted'. Returns "n/a" on Android.
   */
  static getATTStatus():Promise<String>{
    if(Platform.OS == 'ios'){
      return OneTrust.getATTStatus()
    }
    else{
      return Promise.resolve("n/a")
    } 
  }
 /**
  * Display the Universal Consent preference center
  */
  static showConsentPurposesUI():void{
    OneTrust.showConsentPurposesUI()
  }

  /**
   * Retrieves the status of the specified universal consent purpose
   * @param {string} purposeId The id of the purpose to query against
   * @returns {number} 1 if consent is granted, 0 if consent is not granted
   */
  static getUCPurposeConsent(purposeId:string):Promise<Boolean>{
    return OneTrust.getUCPurposeConsent(purposeId)
  }

  /**
   * Retrieves an array of key/value pairs representing the custom preferences' statuses
   * @param {string} customPreferenceOptionId The id of the option selected
   * @param {string} customPreferenceId The id of the custom preferences
   * @param {string} purposeId The id of the purpose under which the custom preference is nested
   * @returns {number} 1 if consent is granted, 0 if consent is not granted
   */
  static getUCCustomPreferenceConsent(customPreferenceOptionId:string, customPreferenceId:string, purposeId:string):Promise<number>{
    return OneTrust.getUCCustomPreferenceConsent(customPreferenceOptionId,customPreferenceId,purposeId)
  }
  
  /**
   * Retrieves the consent status of the specified topic
   * @param {string} topicOption the GUID of the topic option to retrieve
   * @param {string} purposeId the GUID of the purpose under which the topic is nested
   * @returns {number} 1 if consent is granted, 0 if consent is not granted
   */
  static getUCTopicConsent(topicOption:string, purposeId:string):Promise<number>{
    return OneTrust.getUCTopicConsent(topicOption, purposeId)
  }

  /**
   * Updates the top-level purpose consent for UC purposes. Must call saveUCConsent() to commit changes.
   * @param {string} purposeId the GUID of the purpose
   * @param {boolean} consent the value of whether or not consent has been granted
   */

  static updateUCPurposeConsent(purposeId:string, consent:boolean):void{
    OneTrust.updateUCPurposeConsent(purposeId, consent)
  }
  /**
   * Updates a custom preference nested under a purpose
   * @param {string} customPreferenceOptionId GUID representing the selected option
   * @param {string} customPreferenceId GUID representing the custom preference group
   * @param {string} purposeId the GUID of the purpose under which the custom preferences are nested
   * @param {boolean} consent the value of whether or not consent has been granted
   */
  static updateUCCustomPreferenceConsent(customPreferenceOptionId:string, customPreferenceId:string, purposeId:string, consent:boolean):void{
    OneTrust.updateUCCustomPreferenceConsent(customPreferenceOptionId, customPreferenceId, purposeId, consent)
  }

  /**
   * Update a topic nested under a purpose
   * @param {string} topicOptionId GUID represending the selected topic
   * @param {string} purposeId GUID representing the purpose under which the topic is present
   * @param {boolean} consent the value of whether or not consent has been granted
   */
  static updateUCTopicConsent(topicOptionId:string, purposeId:string, consent:boolean):void{
    OneTrust.updateUCTopicConsent(topicOptionId, purposeId, consent)
  }

  /**
   * Commits the consent changes and submits receipt
   */
  static saveUCConsent():void{
    OneTrust.saveUCConsent();
  }
}

export enum OTDevicePermission{
  /**
   * Select for the IDFA/App Tracking Transparency prompt
   */
  IDFA = 0
}