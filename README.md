#PiwikTracker iOS SDK

The PiwikTracker is an Objective-C framework (for iOS and OSX) designed to send app usage data to a Piwik analytics server.
 
[Piwik](http://piwik.org) server is a downloadable, Free/Libre (GPLv3 licensed) real time analytics platform.

*Stating v2.5.2 the tracker support the new Piwik 2.0 bulk request format by default. Users still connecting to a Piwik 1.X server can enable to old format by following the [instructions below](#bulk-dispatching).*

##Getting started

The PiwikTracke is dead easy to use:
 
1. Create a new website in the Piwik web interface called "My App". Copy the Website ID and the [token_auth](http://piwik.org/faq/general/#faq_114)
2. Add the PiwikTracker to your project
3. Create and configure the PiwikTracker
4. Add code in your app to track screen views, events, exceptions, goals and more
5. Let the dispatch timer dispatch pending events to the Piwik server, or dispatch events manually

##I like it, how do I get it?


###CocoaPods

If your project is using CocoaPods, add PiwikTracker as a dependency in your pod file:

    pod PiwikTracker
    

###Source files

If your project is not using CocoaPods:  
 
1. Clone the repo to your local computer
2. Copy all files from the PiwikTracker folder to your Xcode project
3. Add the source files listed below to your build target
4. Add the frameworks and dependencies listed under Requirements to your project

```
PiwikTracker.h
PiwikTracker.m
PiwikTrackedViewController.h (should not be added for OSX)
PiwikTrackedViewController.m (should not be added for OSX)
PTLocationManagerWrapper.h
PTLocationManagerWrapper.m
PTEventEntity.h
PTEventEntity.m
piwiktracker.xcdatamodeld
PiwikTracker-Prefix.pch
```
###Requirements

The latest PiwikTracker version uses ARC and support iOS6+ and OSX10.7+. It has been testing with both Piwik 1.X and Piwik 2.0.

* iOS tracker depends on: Core Data, Core Location, Core Graphics, UIKit and AFNetworking
* OSX tracker depends on: Core Data, Core Graphics, Cocoa and AFNetworking


##Demo project

The workspace contains an iPhone demo app that uses and demonstrates the features available in the SDK.

![Example demo screen shoot](http://piwik.github.io/piwik-sdk-ios/demo_project.png)

If you like to run the demo project, start by cloning the repo and run:
    
    pod install
    
Open the `AppDelegate.m` file and change the Piwik server URL and site credentials:
    
```objective-c
static NSString * const PiwikServerURL = @"http://localhost/path/to/piwik/";
static NSString * const PiwikSiteID = @"2";
static NSString * const PiwikAuthenticationToken = @"5d8e854ebf1cc7959bb3b6d111cc5dd6";
```
    
If you do not have access to a Piwik server your may run the tracker in debug mode. Events will be printed to the console instead of sent to the Piwik server:
	
```objective-c
// Print events to the console
[PiwikTracker sharedInstance].debug = YES; 
```    

##API

The [tracker](http://piwik.github.io/piwik-sdk-ios/docs/html/index.html) is very easy to use:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {	
  // Create and configure the tracker in your app delegate
  // The website ID is available in Settings > Websites
  // The token_auth is available in Settings > Users
  [PiwikTracker sharedInstanceWithBaseURL:[NSURL URLWithString:PIWIK_URL] siteID:WEBSITE_ID_HERE authenticationToken:TOKEN_AUTH_HERE];	    
}
		
	
- (void)viewDidAppear:(BOOL)animated {
  // Track screen views in your view controllers
  // Recommendation: track the full hierarchy of the screen, e.g. screen/view1/view2/currentView
  [[PiwikTracker sharedInstance] sendViews:@"view1", @"view2", self.title];
}
	  

// Track custom events when users interacts with the app
[[PiwikTracker sharedInstance] sendEventWithCategory:@"Picture" action:@"view" label:@"my_cat.png"];
	
// Measure exceptions and errors after the app gone live
[[PiwikTracker sharedInstance] sendExceptionWithDescription:@"Ops, got and error" isFatal:NO];

// Track when users interact with various social networks.
[[PiwikTracker sharedInstance] sendSocialInteraction:@"Like" target:@"cat.png" forNetwork:@"Facebook"];
	
// Measure the most popular keywords used for different search operations in the app
[[PiwikTracker sharedInstance] sendSearchWithKeyword:@"Galaxy" category:@"Books" numberOfHits:17];

// Track goals and conversion rate
[[PiwikTracker sharedInstance] sendGoalWithID:@"1" revenue:100];
```
	  	
Check out the full [API documentation](http://piwik.github.io/piwik-sdk-ios/docs/html/index.html) for additional methods and details.

##More info

* All methods are asynchronous and will return immediately
* All events are persisted locally in Core Data until they are dispatched and successfully received by the Piwik server
* PiwikTracker is based on [AFNetworking](https://github.com/AFNetworking/AFNetworking) and AFHTTPClient. Developers can use and benefit from all AFNetworking features. Optionally you can subclass the PiwikTracker to further customise the behaviour, e.g. configure authentication method and credentials, tune request timeouts, etc

###Prefixing

By default all events will be prefixed with the name of the event type. This will allow Piwik to group and present events of the same type together in the web interface. 

![Example screenshot](http://piwik.github.io/piwik-sdk-ios/piwik_prefixing.png)

You may choose to disable Prefixing:

```objective-c
// Turn automatic prefixing off
[PiwikTracker sharedInstance].isPrefixingEnabled = NO;
```

###Sessions

A new user session (new visit) is automatically created when the app is launched.  If the app spends more then 120 seconds in the background, a new session will be created when the app enters the foreground. 

You can change the session timeout value by setting the sessionTimeout property. You can manually force a new session start when the next event is sent by setting the sessionStart property:

```objective-c
// Change the session timeout value to 5 minutes
[PiwikTracker sharedInstance].sessionTimeout = 60 * 5;
    
// Start a new session when the next event is sent
[PiwikTracker sharedInstance].sessionStart = YES;
```    

###Dispatch timer

The tracker will by default dispatch any pending events every 120 seconds.

Set the interval to 0 to dispatch events as soon as they are queued. If a negative value is used the dispatch timer will never run, a manual dispatch must be used:

```objective-c	
// Switch to manual dispatch
[PiwikTracker sharedInstance].dispatchInterval = -1;
	    
// Manual dispatch
[PiwikTracker sharedInstance] dispatch];
```

###Bulk dispatching

PiwikTracker supports the Piwik bulk tacking interface and can send several events in the same Piwik request, reducing the number of requests, increase speed and saving battery. The default value is set to 20 events per request.

The bulk request encoding changed in Piwik 2.0 and the tracker support the new encoding format by default. If your app is still connecting to a Piwik 1.X server you can enable 1.x bulk encoding by defining the macro `PIWIK1_X_BULK_ENCODING` in your apps .pch file:

```objective-c	
// Enable legacy Piwik 1.X bulk request encoding
#define PIWIK1_X_BULK_ENCODING
```

##Changelog

* Version 2.5.2 contains an important fix for supporting the Piwik 2.0 bulk request API. Users still using Piwik 1.X can enable the old bulk request format by following the [instructions above](#bulk-dispatching).
* Version 2.5 contains many new features, including tracking social interaction, exceptions and searches. All events are prefixed according to its type to provide grouping and structure in the Piwik web interface. This would be the preferred behaviour for most developers but it can be turned off if interfering with an existing structure.
* Version 2.0 is a complete rewrite of the PiwikTracker, now based on AFNetworking and supporting CocoaPods. The interface is not backwards compatible, however it should be a small task migrating existing apps.

##License

PiwikTracker is available under the [MIT license](LICENSE.md).
