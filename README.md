#PiwikTracker 2.5

_Version 2.5 contains many new features, including tracking social interaction, exceptions and searches. All events are prefixed according to its type to provide grouping and structure in the Piwik web interface. This would be the preferred behaviour for most developers but it can be turned off if interfering with an existing structure._

_Version 2.0 is a complete rewrite of the PiwikTracker, now based on AFNetworking and supporting CocoaPods. The interface is not backwards compatible, however it should be a relative small task to migrate existing apps._

The PiwikTracker is an Objective-C framework (iOS and OSX) for sending analytics to a Piwik server.
 
Piwik server is a downloadable, Free/Libre (GPLv3 licensed) real time web analytics software, [http://piwik.org](http://piwik.org).
This framework implements the Piwik tracking REST API [http://piwik.org/docs/tracking-api/reference.](http://piwik.org/docs/tracking-api/reference/)
 
###How does it work
 
1. Create a new site for tracking in the Piwik web interface
2. Add the PiwikTracker to your project
3. Create and configure the tracker
4. Track screen views, events, exceptions, goals and more
5. Let the dispatch timer dispatch pending events to the Piwik server or start the dispatch manually

All methods are asynchronous and will return immediately.

All events are persisted locally in Core Data until they are dispatched and successfully received by the Piwik server.   

The tracker support the new Piwik bulk tacking interface and can send several events in the same Piwik request, reducing the number of requests and saving battery.

The PiwikTracker is based on [AFNetworking](https://github.com/AFNetworking/AFNetworking) and AFHTTPClient. Developers can use and benefit from all AFNetworking features and optionally subclass the PiwikTracker to further customise the behaviour, e.g. configure authentication method and credentials, tune request timeouts etc.

###Prefixing
By default all events will be prefixed depending on the type of event. This will allow Piwik to group and present events of the same type together in the web interface. 

![Example screenshoot](http://piwik.github.io/piwik-sdk-ios/piwik_prefixing.png)

This would be the preferred behaviour for most developers but it can be turned off if it interferes with an existing structure or if a custom prefixing scheme is needed.

    // Turn automatic prefixing off
    [PiwikTracker sharedInstance].isPrefixingEnabled = NO;

###Sessions
A new session is automatically started when the app is launched. If the app spend more then 120 seconds in the background a new session will be created when the app enters the foreground. You can change the session timeout value by setting the sessionTimeout property.

You can manually force a new session start when the next event is sent by setting the sessionStart property.

    // Change the session timeout value to 5 minutes
    [PiwikTracker sharedInstance].sessionTimeout = 60 * 5;
    
    // Start a new session when the next event is sent
    [PiwikTracker sharedInstance].sessionStart = YES;

###Dispatching events
The tracker will automatically dispatch any pending events every 120 seconds. You can change the interval of the dispatch timer. Setting the interval to 0 with dispatch events as soon as they are queued. If a negative value is used the dispatch timer will never run and a manual dispatch must be used.

    // Switch to manual dispatch
    [PiwikTracker sharedInstance].dispatchInterval = -1;
    
    // Manual dispatch
    [PiwikTracker sharedInstance] dispatch];
 
##API
The tracker is very simple simple to use.


	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {	
	    // Create and configure the tracker in your app delegate
	    // The site id and authentication token is generated when you create the site in the Piwik server.
	    [PiwikTracker sharedInstanceWithBaseURL:[NSURL URLWithString:PIWIK_URL] siteID:SITE_ID_TEST authenticationToken:AUTH_TOKEN];	    
	}
		
	
	- (void)viewDidAppear:(BOOL)animated {
	    // Tracker screen views in your controllers
	    // The recommendation is to track the full hierarchy of the screen, e.g. screen/view1/view2/currentView"
  	    [[PiwikTracker sharedInstance] sendViews:@"view1", @"view2", self.title];
	}
	  
	…

	// Track custom events when users interacts with the app
	[[PiwikTracker sharedInstance] sendEventWithCategory:@"Picture" action:@"view" label:@"my_cat.png"];
	
	// Measure exceptions and errors after the app gone live
	[[PiwikTracker sharedInstance] sendExceptionWithDescription:@"Ops, got and error" isFatal:NO];

	// Track when users interact with various social networks
	[[PiwikTracker sharedInstance] sendSocialInteraction:@"Like" target:@"cat.png" forNetwork:@"Facebook"];
	
	// Measure the most popular keywords used for different search operations in the app
	[[PiwikTracker sharedInstance] sendSearchWithKeyword:@"Galaxy" category:@"Books" numberOfHits:17];

	// Track goals and conversion rate
	[[PiwikTracker sharedInstance] sendGoalWithID:@"1" revenue:100];
	  	
Please read the [API documentation](http://piwik.github.io/piwik-sdk-ios/docs/html/index.html) for additional methods and details.

##Requirements

The latest PiwikTracker version uses ARC and support iOS6+ and OSX 10.7+.

Piwik tracker has a dependency to Core Data, Core Location, Core Graphics, UIKit and AFNetworking.

##Installation

If your project is using CocoaPods simply add PiwikTracker as a dependency in your pod file.

    pod PiwikTracker
    
Otherwise clone the repo to your local comp. Copy all files from the PiwikTracker folder to your Xcode project and make sure you add them to your build target. Add the frameworks and dependencies listed under Requirements to your project.

    PTEventEntity.h
    PTEventEntity.m
    PiwikTrackedViewController.h
    PiwikTrackedViewController.m
    PiwikTracker.h
    PiwikTracker.m
    piwiktracker.xcdatamodeld

If you like to run the demo included in the PiwikTracker repo, clone the project and run the pod file.
    
    pod install

##License

PiwikTracker is available under the MIT license. See the LICENSE.md file for more info.




