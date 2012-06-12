#PiwikTracker

A PiwikTracker framework in Objective-C for sending events to a Piwik server.
 
Piwik server is downloadable, Free/Libre (GPLv3 licensed) real time web analytics software, http://piwik.org/.
 
###How does it work
 
1. Request the shared tracker 
2. Start the tracking
3. Track events (events are stored in a locally persisted queue)
4. Dispatch all events in the queue to the Piwik server
5. An optional delegate is informed about the progress
 
If the request to the Piwik server fails the delegate is informed an appropriate action can be taken. Three different delegate implentations are provided implementing different strategies. They can be used as is or be further customised.
 
##Interface
The interface for sending events is simple to use:

	// Get a shared tracker
	+ (PiwikTracker*)sharedTracker;

	// Start the tracker
	- (BOOL)startTrackerWithPiwikURL:(NSString*)piwikURL 
                          	  siteID:(NSString*)siteID 
                 authenticationToken:(NSString*)authenticationToken
                            delegate:(id<PiwikTrackerDelegate>)delegate
                           withError:(NSError**)error;
                           
    //  Cache an event
    - (BOOL)trackPageview:(NSString*)pageName withError:(NSError**)error;
    
    // Dispatch all cached events to the Piwik server
    - (BOOL)dispatch;

	// Stop the tracker
	- (void)stopTracker;

Please read the interface documentation for additional methods and details.



