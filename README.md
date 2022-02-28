# react-native-onetrust-cmp
## Getting Started

### Versioning
The SDK version used must match the version of the JSON published from your OneTrust instance. For example, if you've published version 6.10.0 of the JSON in your OneTrust environment, you must use npm package version 6.10.0 as well. It is recommended to specify a version to avoid automatic updates, as a OneTrust publish is required when you update your SDK version.

### Installation - Example with specified version
`$ npm install react-native-onetrust-cmp@6.16.0`

#### iOS Run Pod Install
`$ cd ios && pod install`

#### Android Prerequesites
Ensure that the application supports RTL. Simply add `android:supportsRtl="true"` to the `<application>` element in your Android Manifest.

## Usage
Import `OTPublishersNativeSDK`
```javascript
import OTPublishersNativeSDK from 'react-native-onetrust-cmp';
```
## Initialize SDK
Initialize the OneTrust SDK to download the data to populate your consent experience.

```javascript
OTPublishersNativeSDK.startSDK(
  'storageLocation',
  'domainIdentifier',
  'languageCode',
  {countryCode: 'us', regionCode:'ca'},
  true,
)
  .then((responseObject) => {
    console.info('Download status is ' + responseObject.status);
    // get full JSON object from responseObject.responseString
  })
  .catch((error) => {
    console.error(`OneTrust download failed with error ${error}`);
  });
```
### Arguments
|Argument|Type|Description|
|-|-|-|
|storageLocation|String|The CDN location for OneTrust to pull
|domainIdentifier|String|The App ID to load|
|languageCode|String|The ISO language code to load the data|
|params|Dictionary| Dictionary of parameters to override initialization settings. Parameters are optional, but you must have an non-null object defined, even if it is blank. (See below)
|autoShowBanner|Boolean|Automatically display the banner when download has completed successfully. This follows the shouldShowBanner() logic to ensure the user should be presented with a banner. Defaults to `false`

### Params
*All of the values are optional and are expected to be Strings.*
|Key|Value|Description|
|-|-|-|
|countryCode|ISO country code|Overrides the geolocation of the user|
|regionCode|ISO region code|Overrides the geolocation of the user, used in conjunction with `countryCode`|
|androidUXParams|JSON String|Sets UI/UX overrides for Android (see Custom Styling section below)|
|profileSyncParams|Object|Allows for cross-device syncing of consent preferences. See Cross-Device Consent below.|


### Profile Sync Params
Cross-Device Consent is an optional feature. The parameters below are not required for initializing the SDK. Each of the parameters are **required** to sync the user's consent.

|Key|Description|
|-|-|
|identifier|**String** The identifier associated with the user for setting or retrieving consent|
|setSyncProfileAuth|**String** A pre-signed JWT auth token required to perform cross-device consent. More information about JWT requirements can be found [here](https://my.onetrust.com/s/article/UUID-750c79df-692c-7418-a395-af2acaa45601).|

```javascript
  const syncParams = {
    identifier: 'example@onetrust.com',
    syncProfileAuth: 'eyJhbGci...',
  };

  const startSDKParams = {profileSyncParams:syncParams}
```

## Display the OneTrust UI
|Method|Result|
|-|-|
|`OTPublishersNativeSDK.showBannerUI()`|Banner UI is shown|
|`OTPublishersNativeSDK.showPreferenceCenterUI()`|Preference Center is Shown|

If there is a need to determine whether or not the banner should be shown, use the `OTPublishersNativeSDK.shouldShowBanner()` method, which returns a `Boolean`
```javascript
OTPublishersNativeSDK.shouldShowBanner().then((result) =>
  console.log('Should the banner be shown? ', result),
);
```

## Android - Custom styling with UXParams JSON
OneTrust allows you to add custom styling to your preference center by passing in style JSON in a certain format. Build out your JSON by following the guide in the [OneTrust Developer Portal](https://developer.onetrust.com/sdk/mobile-apps/android/customize-ui).

Simply pass in the JSON **as a string** as a parameter in the initialization.
```javascript
const uxParamsJSON = JSON.stringify(require('./assets/AndroidUXParams.json'));

OTPublishersNativeSDK.startSDK(
  'cdn.cookielaw.org',
  '162cfe19-aff6-4d60-b10e-6e7b6fdcfb8b-test',
  'th',
  {androidUXParams: uxParamsJSON},
  true,
)

```

## iOS - Custom Styling with UXParams Plist
Custom styling can be added to your iOS React Native application by using a .plist file in the iOS platform code. In addition to adding the .plist file (which can be obtained from the OneTrust Demo Application) to your bundle, there are a few changes that need to be made in the platform code, outlined below. Review the guide in the [OneTrust Developer Portal](https://developer.onetrust.com/sdk/mobile-apps/ios/customize-ui).

In `appDelegate.h`, import OTPublishersHeadlessSDK and make sure that AppDelegate conforms to the OTUIConfigurator protocol.

```obj-c
#import <React/RCTBridgeDelegate.h>
#import <UIKit/UIKit.h>
#import <OTPublishersHeadlessSDK/OTPublishersHeadlessSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, RCTBridgeDelegate, OTUIConfigurator>


@end
```

In `appDelegate.m`, set the UIConfigurator to self. Then conform to the `shouldUseCustomUIConfig` and `customUIConfigFilePath` protocol methods.

```obj-c

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [OTPublishersHeadlessSDK.shared setUiConfigurator:self]; //set UIConfigurator to Self
    ...
    return ...
}


- (BOOL)shouldUseCustomUIConfig { //conform to shouldUseCustomUIConfig
    return true;
}

- (NSString *)customUIConfigFilePath{ //conform to filepath protocol method
    NSString * configFile = [[NSBundle mainBundle] pathForResource:@"OTSDK-UIConfig-iOS" ofType:@"plist"]; //find path for config file
    return configFile;
}

@end
```

## When Consent Changes
OneTrust universally uses the following values for consent status:
|Status|Explanation|
|-|-|
|1|Consent Given|
|0|Consent Not Given|
|-1|Consent not yet gathered, or SDK not initialized|

### Querying for Consent
To obtain the current consent status, use the `getConsentStatusForCategory()` method, which returns an `Int`:
```javascript
OTPublishersNativeSDK.getConsentStatusForCategory('C0002').then((result) =>
  console.log('Consent Status for C0002 = ' + result),
);
```

### Listening for Consent Changes
The OneTrust SDK emits events as consent statuses change.

On iOS, you must tell the bridge which consent values are permitted:
```javascript
  OTPublishersNativeSDK.setBroadcastAllowedValues(['C0002','C0003']);
```
The parameters passed are what events the iOS platform will be allowed to emit. This method has a conditional built in so that it will not execute on Android devices.

To start listening for consent changes, call the `listenForConsentChanges` method, which accepts a Category ID as a string, and a callback function.

```javascript
OTPublishersNativeSDK.listenForConsentChanges('C0002', (cat, status) =>
  console.log('Consent status for ', cat, ' has been updated to ', status),
);
```
The callback will be executed every time the consent status is updated.

To stop listening for changes (for example, when your component is unmounted,) simply call
```javascript
OTPublishersNativeSDK.stopListeningForConsentChanges();
```
This will cancel all listeners.

## Special Configurations
### Passing consent to WebViews
If your application uses WebViews to present content and the pages rendered are running the OneTrust Cookies CMP, you can inject a JavaScript variable, provided by OneTrust, to pass consent from the native application to your WebView.

The JavaScript must be evaluated before the Cookies CMP loads in the webview, therefore, it is recommended to evaluate the JS early on in the WebView load cycle.

```javascript
var jsToPass = await OTPublishersNativeSDK.getOTConsentJSForWebView()
//WebView JS Evaluation logic here
```

If your application is using `react-native-webview`, any injected JavaScript is wrapped in a self-invoking function, meaning that any variables set are not in the global scope. For the OneTrust Cookie Compliance module to pick up the required changes, the variable must be at a global scope. To accomplish this, a substring can be used to place the payload in the `window` scope.

```javascript
var jsToPass = await OTPublishersNativeSDK.getOTConsentJSForWebview()
jsToPass = `window.OTExternalConsent${jsToPass.substring(21)}`
//WebView JS Evaluation logic here
```

### App Tracking Transparency
If enabled in your template, OneTrust can render a pre-prompt and then show the App Tracking Transparency prompt immediately after. OneTrust also exposes a method to access the status of the user's App Tracking Transparency selection.

To surface the pre-prompt:
```javascript
//be sure to import {OTDevicePermission} from 'react-native-onetrust-cmp'

OTPublishersNativeSDK.showConsentUI(OTDevicePermission.IDFA).then(()=>{
  console.log("ATT Prompt Complete")
})
```

To get the status of the user's ATT selection:
```javascript
var status = await OTPublishersNativeSDK.getATTStatus()
console.log(`ATT Status is ${status}`)
```
Status will return 'authorized', 'denied', 'notDetermined', or 'restricted'. The definitions of each are consistent with [Apple's definitions](https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/authorizationstatus).

## Universal Consent
Universal consent allows your application to collect consent for off-device processing. For example, your application might need to request permission to send a user promotional SMS messages. In OneTrust, after a Universal Consent transaction is committed, integration workflows can be triggered in the OneTrust tool.

Universal Consent requires a user identifier to work properly. In order to set a data subject and keep their consent in sync with other collection methods, **utilize the guidance for cross-device consent above.**


### Display Universal Consent Preference Center
To load the Universal Consent preference center over the current screen, simply call
```javascript
OTPublishersNativeSDK.showConsentPurposesUI()
```

### Query for Universal Consent Values
This plugin exposes async methods to retrieve the current state of the users' consent.

|Status|Explanation|
|-|-|
|1|Consent Given|
|0|Consent Not Given|
|-1|Consent not yet gathered, or SDK not initialized|

To query for the top-level purpose's consent:
```javascript
var consent = await OTPublishersNativeSDK.getUCPurposeConsent('purposeId')
```

|Argument|Type|Description|
|-|-|-|
|purposeId|String|The GUID of the purpose to retrieve.

To query for a custom preference nested under a purpose:
```javascript
var consent = await OTPublishersNativeSDK.getUCCustomPreferenceConsent('customPreferenceOptionId',
 'customPreferenceId','purposeId')
```

|Argument|Type|Description|
|-|-|-|
|customPreferenceOptionId|String|The GUID of the custom preference option|
|customPreferenceId|String|The GUID of the custom preference group|
|purposeId|String|The GUID of the purpose under which the custom preference is nested.|

To query for a topic nested under a purpose:
```javascript
var consent = await OTPublishersNativeSDK.getUCTopicConsent('topicOptionId', 'purposeId')
```

|Argument|Type|Description|
|-|-|-|
|topicOptionId|String|The GUID of the topic option|
|purposeId|String|The GUID of the purpose under which the custom preference is nested.|

### Programatically Set Universal Consent Values
The package exposes methods to programatically set the users' consent values. A common use case is when a sign-up form has a checkbox at the bottom to allow the user to opt into emails. In this case, the application would set the value of the associated purpose, and the user could change his or her decision later in the preference center.

**After making consent updates, the application must call the `saveUCConsent()` function to commit the changes.**

To update the top-level purpose's consent:
```javascript
var consent = await OTPublishersNativeSDK.updateUCPurposeConsent('purposeId', true)
```

|Argument|Type|Description|
|-|-|-|
|purposeId|String|The GUID of the purpose to update|
|consent|Boolean|Whether or not consent has been granted for the specified item|

To update a custom preference nested under a purpose:
```javascript
var consent = await OTPublishersNativeSDK.updateUCCustomPreferenceConsent('customPreferenceOptionId',
 'customPreferenceId','purposeId', true)
```

|Argument|Type|Description|
|-|-|-|
|customPreferenceOptionId|String|The GUID of the custom preference option|
|customPreferenceId|String|The GUID of the custom preference group|
|purposeId|String|The GUID of the purpose under which the custom preference is nested.|
|consent|Boolean|Whether or not consent has been granted for the specified item|

To update a topic nested under a purpose:
```javascript
var consent = await OTPublishersNativeSDK.updateUCTopicConsent('topicOptionId', 'purposeId', true)
```

|Argument|Type|Description|
|-|-|-|
|topicOptionId|String|The GUID of the topic option|
|purposeId|String|The GUID of the purpose under which the custom preference is nested.|
|consent|Boolean|Whether or not consent has been granted for the specified item|

### Save Consent
After making updates to the consent values, the application must call the following method to commit the changes:

```javascript
  OTPublishersNativeSDK.saveUCConsent()
```
