# PiwikTracker iOS SDK

The PiwikTracker is an iOS SDK for sending app analytics to a Piwik server.

**This is not the final and stable version but a prerelease of the Swift rewrite. Please check [this list](https://github.com/piwik/piwik-sdk-ios/issues?utf8=✓&q=is%3Aopen%20is%3Aissue%20label%3Adiscussion%20label%3Aswift3) to see what is left and can be improved.**

[![Build Status](https://travis-ci.org/piwik/piwik-sdk-ios.svg?branch=swift3)](https://travis-ci.org/piwik/piwik-sdk-ios)

## Installation
### [CocoaPods](https://cocoapods.org)

Use the following in your Podfile.

```
pod 'PiwikTracker', '~> 4.0.0-beta'
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

You can also set the url of the page. 
```
let url = URL(string: "https://piwik.org/get-involved/")
Tracker.shared?.track(view: ["community","get-involved"], url: url)
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

## Contributing
Please read [CONTRIBUTING.md](https://github.com/piwik/piwik-sdk-ios/blob/swift3/CONTRIBUTING.md) for details.

## ToDo
### These features aren't implemented yet

- Basic functionality
  - [Sessions](https://github.com/piwik/piwik-sdk-ios/issues/136)
  - [OptOut](https://github.com/piwik/piwik-sdk-ios/issues/124)
  - [Persisting non dispatched events](https://github.com/piwik/piwik-sdk-ios/issues/137)
  - [Custom Dimensions](https://github.com/piwik/piwik-sdk-ios/issues/111)
- Tracking of more things
  - Exceptions
  - Social Interactions
  - Search
  - Goals and Conversions
  - Outlinks
  - Downloads
  - [Ecommerce Transactions](https://github.com/piwik/piwik-sdk-ios/issues/110)
  - [Campaigns](https://github.com/piwik/piwik-sdk-ios/issues/109)
  - Content Impressions / Content Interactions
- Customizing the tracker
  - Custom User Agent
  - userID
  - add prefixing? (The objc-SDK had a prefixing functionality ![Example screenshot](http://piwik.github.io/piwik-sdk-ios/piwik_prefixing.png))
  - set the dispatch interval
  - use different dispatchers (Alamofire)

## License

PiwikTracker is available under the [MIT license](LICENSE.md).
