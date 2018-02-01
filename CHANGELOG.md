# Changelog

## Unreleased
* Device.swift is now usable from Objective-C and recognizes iPhone 8 and X platform identifier. [#224](https://github.com/matomo-org/matomo-sdk-ios/pull/224) (by @manuroe)

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
