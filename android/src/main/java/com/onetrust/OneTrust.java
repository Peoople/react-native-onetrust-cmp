package com.onetrust;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.LifecycleState;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.onetrust.otpublishers.headless.Public.DataModel.OTProfileSyncParams;
import com.onetrust.otpublishers.headless.Public.DataModel.OTSdkParams;
import com.onetrust.otpublishers.headless.Public.DataModel.OTUXParams;
import com.onetrust.otpublishers.headless.Public.Keys.OTBroadcastServiceKeys;
import com.onetrust.otpublishers.headless.Public.OTConsentInteractionType;
import com.onetrust.otpublishers.headless.Public.OTPublishersHeadlessSDK;
import com.onetrust.otpublishers.headless.Public.OTCallback;
import com.onetrust.otpublishers.headless.Public.Response.OTResponse;

import org.json.JSONException;
import org.json.JSONObject;

public class OneTrust extends ReactContextBaseJavaModule {
    OTPublishersHeadlessSDK ot;
    String LOG_TAG = "OTReactBridge";
    //constructor
    public OneTrust(ReactApplicationContext reactContext) {
        super(reactContext);
        ot = new OTPublishersHeadlessSDK(getReactApplicationContext());
    }

    //Mandatory function getName that specifies the module name
    @Override
    public String getName() {
        return "OneTrust";
    }

    @ReactMethod
    public void startSDK(String storageLocation, String domainIdentifier, String languageCode, ReadableMap params, final Boolean autoShowBanner, final Promise promise) {
        OTProfileSyncParams syncParams = null;
        OTUXParams uxParams = null;
        /*If profileSyncParams are included, we'll add those into the params object later on.
          This does require that the identifier and the JWT are both present, otherwise it will
          fail gracefully.*/
        if(params.hasKey("profileSyncParams")) {
            ReadableMap profileSyncParams = params.getMap("profileSyncParams");
            String identifier = getParamStringValue(profileSyncParams, "identifier");
            String jwt = getParamStringValue(profileSyncParams, "syncProfileAuth");
            if(!identifier.equals("") && !jwt.equals("")) {
                syncParams = OTProfileSyncParams.OTProfileSyncParamsBuilder.newInstance()
                        .setSyncProfileAuth(jwt)
                        .setIdentifier(identifier)
                        .build();
            }
        }

        if(params.hasKey("androidUXParams")){
            try {
                JSONObject json = new JSONObject(params.getString("androidUXParams"));
                uxParams = OTUXParams.OTUXParamsBuilder.newInstance()
                        .setUXParams(json)
                        .build();
            } catch (JSONException e) {
                Log.e(LOG_TAG, "Error parsing JSON from UXParamsJSON");
                e.printStackTrace();
            }
        }

        OTSdkParams.SdkParamsBuilder initParamsBuilder = OTSdkParams.SdkParamsBuilder.newInstance()
                .setAPIVersion(getParamStringValue(params, "sdkVersion"))
                .setOTCountryCode(getParamStringValue(params, "countryCode"))
                .setOTRegionCode(getParamStringValue(params, "regionCode"));

        if(syncParams != null){
            initParamsBuilder.setProfileSyncParams(syncParams);
        }

        if(uxParams != null){
            initParamsBuilder.setOTUXParams(uxParams);
        }

        OTSdkParams initParams = initParamsBuilder.build();

        ot.startSDK(storageLocation, domainIdentifier, languageCode, initParams, new OTCallback() {
            @Override
            public void onSuccess(@NonNull OTResponse otResponse) {
                Log.i(LOG_TAG,"Data Downloaded Successfully");

                if(autoShowBanner){
                    showBannerAutomatically();
                }

                WritableMap response = Arguments.createMap();
                response.putBoolean("status", true);
                response.putString("error", otResponse.getResponseMessage());
                response.putString("responseString", otResponse.getResponseData());
                promise.resolve(response);
            }

            @Override
            public void onFailure(@NonNull OTResponse otResponse) {
                Log.e(LOG_TAG,"Data Download Unsuccessful");
                promise.reject(otResponse.getResponseMessage()+" - Error Code: "+otResponse.getResponseCode(),"OT SDK Download Failed");
            }
        });
    }

    private void showBannerAutomatically(){
        //End function if shouldShowBanner comes back as false
        if(!ot.shouldShowBanner()){ return; };

        /*Check if the app is in resumed state.
          To hit this block, we'll need the app to be resumed AND internal shouldShowBanner
          call to be TRUE. If all of those conditions are met, we'll proceed to show the banner UI.
          There's also a check in showBannerUI to make sure the app is resumed to avoid a crash. */
        if(appIsActive()){
            showBannerUI();

        /*If we find that the we should be showing the banner, but the app is not
          active, we'll add a lifecycle callback that only runs once. It will load
          the banner the next time the user resumes the application.*/
        }else{
            Log.i(LOG_TAG, "Adding lifecycle callback to load banner the next time the app resumes.");

            getReactApplicationContext().addLifecycleEventListener(new LifecycleEventListener() {
                /*We already know that shouldShowBanner and autoShowBanner are true, so we
                can assume that the user isn't going to be able to give consent outside of
                the app before they put it back in the foreground, so we'll show
                the banner on resume*/
                @Override
                public void onHostResume() {
                        /*Null check to make sure the user didn't background the application and
                        then clear the cache. If they did, you would get an in-app warning
                        to download data.*/
                    if(ot.getBannerData()!= null){
                        showBannerUI();
                    }

                        /*Get rid of this listener so it doesn't run every time the app enters
                        the foreground*/
                    getReactApplicationContext().removeLifecycleEventListener(this);
                }

                @Override
                public void onHostPause() { }

                @Override
                public void onHostDestroy() { }
            });
        }
    }

    private String getParamStringValue(ReadableMap params, String key){
        String value = "";
        if(params.hasKey(key)){
            value = params.getString(key);
        }
        return value;
    }

    private Boolean appIsActive(){
        return getReactApplicationContext().getLifecycleState() == LifecycleState.RESUMED;
    }

    @ReactMethod
    public void showBannerUI(){
        if(getCurrentActivity()!=null && appIsActive()){
            ot.showBannerUI((AppCompatActivity) getCurrentActivity());
        }
    }

    @ReactMethod
    public void showPreferenceCenterUI(){
        if(getCurrentActivity()!=null && appIsActive()){
            ot.showPreferenceCenterUI((AppCompatActivity) getCurrentActivity());
        }
    }

    @ReactMethod
    public void setDataSubjectIdentifier(String identifier){
        ot.overrideDataSubjectIdentifier(identifier);
    }

    @ReactMethod
    public void getConsentStatusForCategory(String categoryId, Promise promise){
        Integer consentValue = ot.getConsentStatusForGroupId(categoryId);
        promise.resolve(consentValue);
    }

    @ReactMethod
    public void shouldShowBanner(Promise promise){
        promise.resolve(ot.shouldShowBanner());
    }

    @ReactMethod
    public void listenForConsentChanges(String category){
        getReactApplicationContext().registerReceiver(actionConsent, new IntentFilter(category));
    }

    @ReactMethod
    public void stopListeningForConsentChanges(){
        try{
            getReactApplicationContext().unregisterReceiver(actionConsent);
        } catch (Exception e) {
            Log.e(LOG_TAG, "Error when trying to unregister receiver. See StackTrace for more details.");
            e.printStackTrace();
        }
    }

    BroadcastReceiver actionConsent = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(intent.getAction(),intent.getIntExtra(OTBroadcastServiceKeys.EVENT_STATUS,-1));
        }
    };

    @ReactMethod
    public void getOTConsentJSForWebView(Promise promise){
        promise.resolve(ot.getOTConsentJSForWebView());
    }

    @ReactMethod
    public void showConsentPurposesUI(){
        if(getCurrentActivity()!=null && appIsActive()) {
            ot.showConsentPurposesUI((AppCompatActivity) getCurrentActivity());
        }
    }

    @ReactMethod
    public void getUCPurposeConsent(String purposeId, Promise promise){
        int consent = ot.getUCPurposeConsent(purposeId);
        promise.resolve(consent);
    }

    @ReactMethod
    public void getUCCustomPreferenceConsent(String customPreferenceOptionId, String customPreferenceId, String purposeId, Promise promise){
        int consent = ot.getUCPurposeConsent(customPreferenceOptionId, customPreferenceId, purposeId);
        promise.resolve(consent);
    }

    @ReactMethod
    public void getUCTopicConsent(String topicId, String purposeId, Promise promise){
        int consent = ot.getUCPurposeConsent(topicId, purposeId);
        promise.resolve(consent);
    }

    @ReactMethod
    public void updateUCPurposeConsent(String purposeId, Boolean consent){
        ot.updateUCPurposeConsent(purposeId, consent);
    }

    @ReactMethod
    public void updateUCCustomPreferenceConsent(String customPreferenceOptionId, String customPreferenceId, String purposeId, Boolean consent){
        ot.updateUCPurposeConsent(customPreferenceOptionId, customPreferenceId, purposeId, consent);
    }

    @ReactMethod
    public void updateUCTopicConsent(String topicOptionId, String purposeId, Boolean consent){
        ot.updateUCPurposeConsent(topicOptionId, purposeId, consent);
    }

    @ReactMethod
    public void saveUCConsent(){
        ot.saveConsent(OTConsentInteractionType.UC_PC_CONFIRM);
    }
}