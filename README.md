#PiwikTracker

A PiwikTracker framework in Objective-C for sending analytic events to a Piwik server.
 
Piwik server is downloadable, Free/Libre (GPLv3 licensed) real time web analytics software, [http://piwik.org](http://piwik.org).
 
###How does it work
 
1. Request the shared tracker 
2. Start the tracking
3. Track events and goals
4. Dispatch all events in the queue to the Piwik server
5. Stop the tracker when the app terminates
 
Events and goals are stored in a locally persisted queue until they are dispatched to the Piwik server. Events in the queue will survive application restarts.

All methods are asynchroneously and will return immediately. A completion block will be run with the outcome of the operation.
 
###Notifications

Notification will be used to inform about the progress. 
 
- `PTEventQueuedSuccessNotification` - The event was successfully queued
- `PTEventQueuedFailedNotification` - The event failed to be queued
- `PTDispatchSuccessNotification` - All queued events was dispatched to the piwik server
- `PTDispatchFailedNotification` - Dispatch failed
 
###Dispatch strategies
 
Three ready-made dispatch strategies class are provided and can be useded as is or be further customized.
 
- `PTTimerDispatchStrategy` - Automatically initiate a dispatch after a certain time interval
- `PTRetryDispatchStrategy` - Automatically perform repeated dispatch retries (until a specified limit) if a dispatch fails
- `PTCounterDispatchStrategy` - automatically initiate a dispatch when there are more cached events then a certain trigger value 

##Interface
The interface for sending events is simple to use:

	// Get a shared tracker
	+ (PiwikTracker*)sharedTracker;

	// Start the tracker
	- (BOOL)startTrackerWithPiwikURL:(NSString*)piwikURL 
                          	  siteID:(NSString*)siteID 
                 authenticationToken:(NSString*)authenticationToken
                           withError:(NSError**)error;
                           
    //  Cache an event
	- (void)trackPageview:(NSString*)pageName completionBlock:(void(^)(NSError* error))block;
    
    // Dispatch all cached events to the Piwik server
	- (void)dispatchWithCompletionBlock:(void(^)(NSError* error))block;

	// Stop the tracker
	- (BOOL)stopTracker;

Please read the interface documentation for additional methods and details.

##Requirements

The latest PiwikTracker version uses ARC.   
Versions 1.0.1 and older use manual reference counting.

Piwik tracker has a dependecy to CoreData for caching events.

##License

PiwikTracker is available under the MIT license. See the LICENSE.md file for more info.




