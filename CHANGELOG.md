# 6.31.0
* Updates to OneTrust 6.31.0

# 6.30.0
* Updates to OneTrust 6.30.0
* **Note:** Dependency updates in Android require the application to target/compile to API 31

# 6.29.0
* Increases peer dependency support of React to accommodate versions >=16.8.1 <18.0.0
* Updates to OneTrust 6.29.0

# 6.28.0
* Updates to OneTrust 6.28.0

# 6.27.0
* Updates to OneTrust 6.27.0

# 6.26.0
* Updates to OneTrust 6.26.0
* Exposes Universal Consent interface and public methods

# 6.25.0
* Fixes type declaration issue for `profileSyncParams`
* Updates iOS to OneTrust 6.25.1, Android to OneTrust 6.25.0
* This release supports Xcode 13
* Drops minimum Cocoapods deployment target to iOS 10

# 6.24.0
* Updates to OneTrust 6.24.0

# 6.23.0
* Updates to OneTrust 6.23.0

# 6.22.0
* Updates to OneTrust 6.22.0
* **Deprecates** `initOTSDKData` in favor of `startSDK`

# 6.21.1
* Fixes Android issue where app could crash in background if `autoShowBanner` was set to TRUE and app was backgrounded before download was complete

# 6.21.0
* Updates to OneTrust 6.21.0
* Accepts `androidUXParams` as argument in startSDK params object
  * This is used for setting custom UI/UX behavior in Android
  * See ReadMe for setup instructions

# 6.20.0
* Updates to OneTrust 6.20.0
* See the native sections of the [developer portal]("https://developer.onetrust.com) for some key updates:
  * App Tracking Transparency Purpose Linking
  * Support for Universal Consent Purposes

# 6.19.0
* Updates to OneTrust 6.19.0

# 6.18.0
* Updated podspec and gradle to OneTrust version 6.18.0
* Exposed `showConsentUI` and `getATTStatus` methods to display ATT pre-prompt and check the status of the ATT
* Fixed issue where `stopListeningForConsentChanges()` could cause a crash if called when no receivers were registered

# 6.17.0
* Released to NPM directly
* Updated podspec and gradle to OneTrust 6.17.0

# 6.16.0
* Fixed issue where `stopListeningForConsentChanges()` was not calling the correct function in iOS
* Updated podspec and gradle to OneTrust version 6.16.0
* Readme updates to reflect auto-installation information via Yarn
* Added CHANGELOG file to package