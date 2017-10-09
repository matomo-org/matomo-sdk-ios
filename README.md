# PiwikTracker iOS SDK

The PiwikTracker is an iOS, tvOS and macOS SDK for sending app analytics to a Piwik server. PiwikTracker can be used from Swift and [Objective-C](#objective-c-compatibility).

**Fancy help improving this SDK? Check [this list](https://github.com/piwik/piwik-sdk-ios/issues?utf8=✓&q=is%3Aopen%20is%3Aissue%20label%3Adiscussion%20label%3Aswift3) to see what is left and can be improved.**

[![Build Status](https://travis-ci.org/piwik/piwik-sdk-ios.svg?branch=develop)](https://travis-ci.org/piwik/piwik-sdk-ios)

## Installation
### [CocoaPods](https://cocoapods.org)

Use the following in your Podfile.

```
pod 'PiwikTracker', '~> 4.3'
```

Then run `pod install`. In every file you want to use the PiwikTracker, don't forget to import the framwork with `import PiwikTracker`.

## Usage
### Configuration

Befor the first usage, the PiwikTracker has to be configured. This is best to be done in the `application(_:, didFinishLaunchingWithOptions:)` method in the `AppDelegate`.

```
PiwikTracker.configureSharedInstance(withSiteID: "5", baseURL: URL(string: "http://your.server.org/path-to-piwik/piwik.php")!)
```

The `siteId` is the id that you can get if you [add a website](https://piwik.org/docs/manage-websites/#add-a-website) within the Piwik web interface. The `baseURL` it the URL to your Piwik web instance and has to include the "piwik.php" string.

#### OptOut

The PiwikTracker SDK supports opting out of tracking. Please use the `isOptedOut` property of the PiwikTracker to define if the user opted out of tracking.

```
PiwikTracker.shared?.isOptedOut = true
```

### Tracking Page Views

The PiwikTracker can track hierarchical screen names, e.g. screen/settings/register. Use this to create a hierarchical and logical grouping of screen views in the Piwik web interface.

```
PiwikTracker.shared?.track(view: ["path","to","your","page"])
```

You can also set the url of the page.
```
let url = URL(string: "https://piwik.org/get-involved/")
PiwikTracker.shared?.track(view: ["community","get-involved"], url: url)
```

### Tracking Events

Events can be used to track user interactions such as taps on a button. An event consists of four parts:

- Category
- Action
- Name (optional, recommended)
- Value (optional)

```
PiwikTracker.shared?.track(eventWithCategory: "player", action: "slide", name: "volume", value: 35.1)
```

This will log that the user slided the volume slider on the player to 35.1%.

### Custom Dimension

The Piwik SDK currently supports Custom Dimensions for the Visit Scope. Using Custom Dimensions you can add properties to the whole visit, such as "Did the user finish the tutorial?", "Is the user a paying user?" or "Which version of the Application is being used?" and such. Before sending custom dimensions please make sure Custom Dimensions are [properly installed and configured](https://piwik.org/docs/custom-dimensions/). You will need the `ID` of your configured Dimension.

After that you can set a new Dimension,

```
PiwikTracker.shared?.set(value: "1.0.0-beta2", forIndex: 1)
```

or remove an already set dimension.

```
PiwikTracker.shared?.remove(dimensionAtIndex: 1)
```

Dimensions in the Visit Scope will be sent along every Page View or Event. Custom Dimensions are not persisted by the SDK and have to be re-configured upon application startup.

### Custom User ID

To add a [custom User ID](https://piwik.org/docs/user-id/), simply set the value you'd like to use on the `visitorId` field of the shared tracker:

```
PiwikTracker.shared?.visitorId = "coolUsername123"
```

All future events being tracked by the SDK will be associated with this userID, as opposed to the default UUID created for each Visitor.

## Advanced Usage
### Manual dispatching

The PiwikTracker will dispatch events every 30 seconds automatically. If you want to dispatch events manually, you can use the `dispatch()` function. You can, for example, dispatch whenever the application enter the background.

```
func applicationDidEnterBackground(_ application: UIApplication) {
  PiwikTracker.shared?.dispatch()
}
```

### Session Management

The PiwikTracker starts a new session whenever the application starts. If you want to start a new session manually, you can use the `startNewSession()` function. You can, for example, start a new session whenever the user enters the application.

```
func applicationWillEnterForeground(_ application: UIApplication) {
  PiwikTracker.shared?.startNewSession()
}
```

### Logging

The PiwikTracker per default loggs `warning` and `error` messages to the console. You can change the `LogLevel`.

```
PiwikTracker.shared?.logger = DefaultLogger(minLevel: .verbose)
PiwikTracker.shared?.logger = DefaultLogger(minLevel: .debug)
PiwikTracker.shared?.logger = DefaultLogger(minLevel: .info)
PiwikTracker.shared?.logger = DefaultLogger(minLevel: .warning)
PiwikTracker.shared?.logger = DefaultLogger(minLevel: .error)
```

You can also write your own `Logger` and send the logs whereever you want. Just write a new class/struct an let it conform to the `Logger` protocol.

### Custom User Agent
The `PiwikTracker` will create a default user agent derived from the WKWebView user agent. This is why you should always instantiate and configure the `PiwikTracker` on the main thread.
You can instantiate the `PiwikTracker` using your own user agent.

```
PiwikTracker.configureSharedInstance(withSiteID: "5", baseURL: URL(string: "http://your.server.org/path-to-piwik/piwik.php")!, userAgent: "Your custom user agent")
```

### Objective-C compatibility

Version 4 of this SDK is written in Swift, but you can use it in your Objective-C project as well. If you don't want to update you can still use the unsupported older [version 3](https://github.com/piwik/piwik-sdk-ios/tree/version-3). Using the Swift SDK from Objective-C should be pretty straight forward.

```
[PiwikTracker configureSharedInstanceWithSiteID:@"5" baseURL:[NSURL URLWithString:@"http://your.server.org/path-to-piwik/piwik.php"] userAgent:nil];
[PiwikTracker shared] trackWithView:@[@"example"] url:nil];
[[PiwikTracker shared] trackWithEventWithCategory:@"category" action:@"action" name:nil number:nil];
[[PiwikTracker shared] dispatch];
```

### Sending custom events

Instead of using the convenience functions for events and sreenviews for example you can create your event manually and even send custom tracking parameters. This feature isn't usable from Objective-C.

```
func sendCustomEvent() {
  guard let piwikTracker = PiwikTracker.shared else { return }
  let downloadURL = URL(string: "https://builds.piwik.org/piwik.zip")!
  let event = Event(tracker: piwikTracker, action: ["menu", "custom tracking parameters"], url: downloadURL, customTrackingParameters: ["download": downloadURL.absoluteString])
  PiwikTracker.shared?.track(event)
}
```

All custom events will be url encoded and dispatched along with the default Event parameters. Please read the [Tracking API Documentation](https://developer.piwik.org/api-reference/tracking-api) for more information on which parameters can be used.

Also: You cannot override Custom Parameter keys that are allready defined by the Event itself. If you set those keys in the `customTrackingParameters` they will be discarded.

## Contributing
Please read [CONTRIBUTING.md](https://github.com/piwik/piwik-sdk-ios/blob/swift3/CONTRIBUTING.md) for details.

## ToDo
### These features aren't implemented yet

- Basic functionality
  - [Persisting non dispatched events](https://github.com/piwik/piwik-sdk-ios/issues/137)
  - [Custom Dimensions](https://github.com/piwik/piwik-sdk-ios/issues/111) (Action Scope is not implemented yet)
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
  - add prefixing? (The objc-SDK had a prefixing functionality ![Example screenshot](http://piwik.github.io/piwik-sdk-ios/piwik_prefixing.png))
  - set the dispatch interval
  - use different dispatchers (Alamofire)

## License

PiwikTracker is available under the [MIT license](LICENSE.md).
