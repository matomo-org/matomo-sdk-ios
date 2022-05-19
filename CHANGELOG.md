# Changelog

## Unreleased

## 7.5.1
* **bugfix** Fixed an issue where the latest version couldn't be installed via SPM. [#402](https://github.com/matomo-org/matomo-sdk-ios/issues/402)

## 7.5.0
* **improvement** Allow overriding any of the tracking parameters. [#360](https://github.com/matomo-org/matomo-sdk-ios/issues/360)
* **improvement** Fixed build warnings
* **improvement** Use the new XCode build system [#391](https://github.com/matomo-org/matomo-sdk-ios/pull/391)
* **bugfix** Fixed issue where only `UserDefaults.standard` is used despite specified another instance. [#384](https://github.com/matomo-org/matomo-sdk-ios/pull/384)

## 7.4.0
* **improvement** Escaped more symbols when sending events to the API. [#313](https://github.com/matomo-org/matomo-sdk-ios/issues/313)
* **improvement** Removed unused `humanReadablePlatformName` `Device` property. [#358](https://github.com/matomo-org/matomo-sdk-ios/pull/358)
* **improvement** Changed the cdt parameter to be accurate to milliseconds. [#360](https://github.com/matomo-org/matomo-sdk-ios/issues/360)
* **improvement** Changed sending the `ca` parameter only for events that are no further specified. [#363](https://github.com/matomo-org/matomo-sdk-ios/issues/363)
* **bugfix** Fixed macOS version recognition. [#361](https://github.com/matomo-org/matomo-sdk-ios/issues/361)

## 7.3.0
* **improvement** Support new `ca` tracking parameter for tracking requests that aren't page views. [#354](https://github.com/matomo-org/matomo-sdk-ios/issues/354)
* **improvement** Completely overhauled the UserAgent generation for automatic device and OS discovery. [#353](https://github.com/matomo-org/matomo-sdk-ios/pull/353)

## 7.2.2
* **bugfix** Fixed bug, where new session not started manually [#325](https://github.com/matomo-org/matomo-sdk-ios/issues/325)

## 7.2.1
* **improvement** Added back detailed phone model feature #253. [#330](https://github.com/matomo-org/matomo-sdk-ios/pull/330)
* **improvement** Set application extension API only to true #334. [#335](https://github.com/matomo-org/matomo-sdk-ios/pull/335)
* **bugfix** Fixed an issue where device information and operating system sometimes wasn't tracked. [#329](https://github.com/matomo-org/matomo-sdk-ios/issues/329)

## 7.2.0
* **feature** Added support for the Swift Package Manager. [#312](https://github.com/matomo-org/matomo-sdk-ios/pull/312)
* **improvement** Added new devices info [#321](https://github.com/matomo-org/matomo-sdk-ios/pull/321)
* **improvement** Added `timeout` property to URLSessionDispatcher initialization method
* **bugfix** Fixed an issue with `WKWebView` on iOS not returning a user agent string [#322](https://github.com/matomo-org/matomo-sdk-ios/issues/322)
* **bugfix** Fixed a retain cycle on `MatomoTracker`. [#316](https://github.com/matomo-org/matomo-sdk-ios/issues/316)

## 7.0.1
* **bugfix** Fixed an issue with a new `forcedVisitorId` value validation. [#315](https://github.com/matomo-org/matomo-sdk-ios/pull/315)

## 7.0.0
* **important** Dropped support for iOS 8 and 9. [#306](https://github.com/matomo-org/matomo-sdk-ios/pull/306)
* **improvement** Updated to Swift 5.0 and Xcode 10.3 tools version. [#306](https://github.com/matomo-org/matomo-sdk-ios/pull/306)
* **improvement** Added `cdt` query item in addition to `h`/`m`/`s` values [#301] (https://github.com/matomo-org/matomo-sdk-ios/pull/301)
* **improvement** Replaced UIWebView with WkWebView. [#308](https://github.com/matomo-org/matomo-sdk-ios/issues/308)

## 6.0.2
* **improvement** Allow to use the Queue's completions in asynchronous scope. [#304](https://github.com/matomo-org/matomo-sdk-ios/pull/304)

## 6.0.1
* **improvement** Made copyFromOldSharedInstance available from Objective-C. [#282] (https://github.com/matomo-org/matomo-sdk-ios/issues/282)
* **improvement** Accepting urls ending in `matomo.php` in addition to `piwik.php` when initializing a new instance. [#286] (https://github.com/matomo-org/matomo-sdk-ios/pull/286)
* **bugfix**  Specified Swift 4.2 in both `.podspec` files. [#297] (https://github.com/matomo-org/matomo-sdk-ios/pull/297)

## 6.0.0
* **feature** Added the possibility to implement custom queues. [#137](https://github.com/matomo-org/matomo-sdk-ios/issues/137)
* **improvement** Updated to Swift 4.2
* **bugfix** Added default values for items when tracking orders. [#276](https://github.com/matomo-org/matomo-sdk-ios/issues/276)

## 5.3.0
* **feature** Added a `forcedVisitorId` property. [#259](https://github.com/matomo-org/matomo-sdk-ios/issues/259)
* **feature** Added a method for goal tracking [#272](https://github.com/matomo-org/matomo-sdk-ios/issues/272)
* **feature** Added a function to track E-Commerce orders. [#110](https://github.com/matomo-org/matomo-sdk-ios/issues/110)
* **improvement** Added public init to `CustomVariable` [#269](https://github.com/matomo-org/matomo-sdk-ios/issues/269)
* **improvement** Renamed the `visitorId` property to `userId` to be more inline with the Documentation. [#258](https://github.com/matomo-org/matomo-sdk-ios/issues/258)
* **bugfix** Fixed an issue where `trackSearch` called from Objective-C would end in an infinite loop. [#263](https://github.com/matomo-org/matomo-sdk-ios/issues/263)
* **bugfix** Fixed an issue on Objective-C project where swift version was't set. [#260](https://github.com/matomo-org/matomo-sdk-ios/issues/260)

## 5.2.0
* **feature** Added a function to track content within the application. [#230](https://github.com/matomo-org/matomo-sdk-ios/pull/256) (by @wongnai)
* **improvement** Replaced generic phone model by device model. [#254](https://github.com/matomo-org/matomo-sdk-ios/pull/253)

## 5.1.1
* **bugfix** Fixed Xcode build settings for Carthage support. [#224](https://github.com/matomo-org/matomo-sdk-ios/pull/244) (by @phranck)

## 5.1.0
* **feature** Added a function to track searches within the application. [#230](https://github.com/matomo-org/matomo-sdk-ios/issues/230)
* **feature** Added campaign tracking. [#109](https://github.com/matomo-org/matomo-sdk-ios/issues/109)
* **improvement** Exposed the visitorId to Objective-C. [#228](https://github.com/matomo-org/matomo-sdk-ios/issues/228)

## 5.0.0
* **improvement** Device.swift is now usable from Objective-C and recognizes iPhone 8 and X platform identifier. [#224](https://github.com/matomo-org/matomo-sdk-ios/pull/224) (by @manuroe)

## 5.0.0-beta1
* **feature** It now is possible to use multiple PiwikTracker instances within one appliaction. Please check [this](https://github.com/matomo-org/matomo-sdk-ios/wiki/Migration#50) guide how to migrate from the shared instance in version 4. [#164](https://github.com/piwik/piwik-sdk-ios/pull/164)
* **feature** Added compatibility to custom variables. [#223](https://github.com/matomo-org/matomo-sdk-ios/pull/223) (by @manuroe and @zantoku)
* **improvement** Renamed Piwik to Matomo [#221](https://github.com/matomo-org/matomo-sdk-ios/pull/221)

## 4.4.2
* **bugfix** Fixed an issue where an ampersand lead to incomplete tracking information. [#217](https://github.com/matomo-org/piwik-sdk-ios/issues/217)

## 4.4.1
* **bugfix** Fixed a crash happening due to concurrent access of the MemoryQueue. [#216](https://github.com/matomo-org/matomo-sdk-ios/pull/216)

## 4.4.0
* **feature** Added a way to add custom dimension in the action scope. [#111](https://github.com/matomo-org/matomo-sdk-ios/issues/111)
* **feature** Added automatic generation of the url property. [#197](https://github.com/matomo-org/matomo-sdk-ios/issues/197)
* **improvement** The PiwikTracker is now save to create in a background thread. [#175](https://github.com/matomo-org/matomo-sdk-ios/pull/175)
* **improvement** The Logger is now objc compatible. [#185](https://github.com/matomo-org/matomo-sdk-ios/issues/185)
* **improvement** Default `example.com` urls aren't generated anymore. [#194](https://github.com/matomo-org/matomo-sdk-ios/pull/195)
* **improvement** The Device and Applications structs are now public. [#191](https://github.com/matomo-org/matomo-sdk-ios/issues/191)

## 4.3.0
* **feature** Added the ability to send custom events with custom tracking parameters. [#153](https://github.com/matomo-org/matomo-sdk-ios/issues/153)
* **bugfix** Fixed a crash when initializing a new tracker. [#162](https://github.com/matomo-org/matomo-sdk-ios/issues/162)
* **bugfix** Removed old, unused AFNetworking Submodule to fix Carthage usage. [#190](https://github.com/matomo-org/matomo-sdk-ios/issues/190)

## 4.2.0
* **feature** Added ability to customize user agent. [#168](https://github.com/matomo-org/matomo-sdk-ios/pull/168)
* **feature** Added ability to customize User ID.
[#180](https://github.com/matomo-org/matomo-sdk-ios/issues/180) (by @niksawtschuk)
* **feature** Added Carthage support [#74](https://github.com/matomo-org/matomo-sdk-ios/issues/74) (by @elitalon)
* **feature** Added a way to set a custom visitor ID [#180](https://github.com/matomo-org/matomo-sdk-ios/pull/181) (by @niksawtschuk)
* **improvement** Added Swift support

## 4.1.0
* **feature** Added Custom Dimension Tracking for the Visit Scope. [#111](https://github.com/matomo-org/matomo-sdk-ios/issues/111)
* **feature** Transmitting the Screen resolution to the Piwik Backend. [#149](https://github.com/matomo-org/matomo-sdk-ios/issues/149) (by @akshaykolte)
* **feature** Added a Logger that can log messages in different levels. [#147](https://github.com/matomo-org/matomo-sdk-ios/issues/147)
* **feature** Added macOS and tvOS compatibility. [#134](https://github.com/matomo-org/matomo-sdk-ios/issues/134)
* **bugfix** Fixed a bug, where the tracker would stop automatic dispatching. [#167](https://github.com/matomo-org/matomo-sdk-ios/issues/167)

## 4.0.0
* **feature** Renamed the Tracker to PiwikTracker. [#146](https://github.com/matomo-org/matomo-sdk-ios/issues/146)
* **feature** Added isOptedOut parameter to the PiwikTracker. [#124](https://github.com/matomo-org/matomo-sdk-ios/issues/124)

## 4.0.0-beta2
* **feature** Added the possibility to set the url for a screen view event. [#92](https://github.com/matomo-org/matomo-sdk-ios/issues/92)
* **feature** Added the functionality to start new sessions. [#136](https://github.com/matomo-org/matomo-sdk-ios/issues/136)
* **fixed** The value of an event got wrongly encoded when dispatching. [#140](https://github.com/matomo-org/matomo-sdk-ios/pull/140)
* **fixed** Fixed an issue where tracking an event wasn’t possible from Objective-C code. [#142](https://github.com/matomo-org/matomo-sdk-ios/issues/142)

## 4.0.0-beta1
* no changes

## 4.0.0-alpha1
* **feature** Started rewrite in Swift
* **feature** Tracking Screen Views
* **feature** Tracking Events
* **feature** URLSessionDispatcher
* **feature** Non persistent Event Queue
