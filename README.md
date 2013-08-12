#PiwikTracker

The PiwikTracker is an Objective-C framework for sending analytics to a Piwik server.
 
Piwik server is downloadable, Free/Libre (GPLv3 licensed) real time web analytics software, [http://piwik.org](http://piwik.org).
This framework implements the Piwik tracking REST API [http://piwik.org/docs/tracking-api/reference.](http://piwik.org/docs/tracking-api/reference/)
 
###How does it work
 
1. Create and configure the tracker
2. Track screen views, events and goals
3. Let the dispatch timer dispatch pending events to the Piwik server or start the dispatch manually

All events are persisted locally in Core Data until they are dispatched and successfully received by the Piwik server.   
All methods are asynchronous and will return immediately.

The PiwikTracker is based on [AFNetworking](https://github.com/AFNetworking/AFNetworking) and  AFHTTPClient. Developers can use and benefit from all the AFNetworking features and optionally subclass the PiwikTracker to further customise the behaviour.
 
##Interface
The interface for sending events is simple to use:

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	  // Create and configure the tracker in your app delegate
	  [PiwikTracker sharedInstanceWithBaseURL:[NSURL URLWithString:PIWIK_URL] siteID:SITE_ID_TEST authenticationToken:AUTH_TOKEN];
	}
	
	…
	
	- (void)viewDidAppear:(BOOL)animated {
	  // Tracker screen views in your controllers
  	  [[PiwikTracker sharedInstance] sendView:self.title];
	  
	  // Track goals
	  [[PiwikTracker sharedInstance] sendGoal:@"1" revenue:200];
	  
	  // Track events
	  [[PiwikTracker sharedInstance] sendEventWithCategory:@"Picture" action:@"view" label:@"my_cat.png"];
    }
    
    …
	
	// Let the dispatch timer send you events automatically or start the dispatch manually
	[[PiwikTracker sharedInstance] dispatch];
	

Please read the [interface documentation](http://mattiaslevin.github.io/PiwikTracker/docs/html/index.html) for additional methods and details.

##Requirements

The latest PiwikTracker version uses ARC.   

Piwik tracker has a dependency to Core Data, Core Location and UIKit.

##License

PiwikTracker is available under the MIT license. See the LICENSE.md file for more info.




