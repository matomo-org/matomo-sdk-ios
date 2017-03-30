# PiwikTracker iOS SDK

The PiwikTracker is an iOS SDK for sending app analytics to a Piwik server.

**This is not the final and stable version but a prerelease of the Swift rewrite. Please check the ToDo section to see what is left.**

[![Build Status](https://travis-ci.org/piwik/piwik-sdk-ios.svg?branch=swift3)](https://travis-ci.org/piwik/piwik-sdk-ios)

## Installation
### [CocoaPods](https://cocoapods.org)

Use the following in your Podfile.

```
pod 'PiwikTracker', branch: 'swift3'
```

Then run `pod install`. In every file you want to use the PiwikTracker, don't forget to import the framwork with `import PiwikTracker`.

## Usage
### Configuration

Befor the first usage, the PiwikTracker has to be configured. This is best to be done in the `application(_:, didFinishLaunchingWithOptions:)` method in the `AppDelegate`.

```
Tracker.configureSharedInstance(withSiteID: "5", baseURL: URL(string: "http://your.server.org/path-to-piwik/piwik.php")!)
```

The `siteId` is the id that you can get if you [add a website](https://piwik.org/docs/manage-websites/#add-a-website) within the Piwik web interface. The `baseURL` it the URL to your Piwik web instance and has to include the "piwik.php" string.

### Tracking Page Views

The PiwikTracker can track hierarchical screen names, e.g. screen/settings/register. Use this to create a hierarchical and logical grouping of screen views in the Piwik web interface.

```
Tracker.shared?.track(view: ["path","to","your","page"])
```

### Tracking Events

Events can be used to track user interactions such as taps on a button. An event consists of four parts:

- Category
- Action
- Name (optional, recommended)
- Value (optional)

```
Tracker.shared?.track(eventWithCategory: "player", action: "slide", name: "volume", value: 35.1)
```

This will log that the user slided the volume slider on the player to 35.1%.

### Advanced

The PiwikTracker will dispatch events every 30 seconds automatically. If you want to dispatch events manually, you can use the `dispatch()` function.

```
Tracker.shared?.dispatch()
```


## ToDo
### These features aren't implemented yet

- Basic functionality
  - Sessions (Right now there is no way to start a new session manually)
  - OptOut
  - Persisting non dispatched events, for when the application terminates
  - [Custom Variables](https://piwik.org/docs/custom-variables/) / [Custom Dimensions](https://piwik.org/docs/custom-dimensions/)
    - Should we go for Custom Dimensions right away? https://piwik.org/faq/general/faq_21117/
- Tracking of more things
  - Exceptions
  - Social Interactions
  - Search
  - Goals and Conversions
  - Outlinks
  - Downloads
  - Ecommerce Transactions
  - Campaigns
  - Conten Impressions / Content Interactions
- Customizing the tracker
  - Custom User Agent
  - userID
  - add prefixing? (The objc-SDK had a prefixing functionality ![Example screenshot](http://piwik.github.io/piwik-sdk-ios/piwik_prefixing.png))
  - set the dispatch interval
  - use different dispatchers (Alamofire)

### Things we can Improve

- Documentation
  - Write a migration guide for SDK 3.x users
- Test Coverage
- macOS, tvOS support

## License

PiwikTracker is available under the [MIT license](LICENSE.md).
