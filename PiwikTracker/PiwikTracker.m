//
//  PiwikTracker.m
//  PiwikTracker
//
//  Created by Mattias Levin on 11/19/11.
//  Copyright 2011 Mattias Levin. All rights reserved.
//


/*
 -Better userId generation, unique
 
 -Support running on OSX
 
 -Support custom variables
 -Support campaign
 -Support outlink and download link
 -Set IP and timestamp
 */


#import "PiwikTracker.h"
#import "PTEvent.h"
#import "PTUserAgentReader.h"
#import <UIKit/UIScreen.h>
#import <UIKit/UIDevice.h>
#import <UIKit/UIWebView.h>
#import <CoreData/CoreData.h>
#import <CoreGraphics/CGGeometry.h>


#pragma mark - Defines and macros

// Uncomment the line below to get debug statements
#define PRINT_DEBUG

// Debug macros
#ifdef PRINT_DEBUG
//#  define DLOG(fmt, ...) NSLog( (@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#  define DLOG(fmt, ...) NSLog( (@"" fmt), ##__VA_ARGS__);
#else
#  define DLOG(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALOG(fmt, ...) NSLog( (@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

// Piwik http parmeter names
#define SITE_ID @"idsite"
#define AUTH_TOKEN @"token_auth"
#define RECORD @"rec"
#define API_VERSION @"apiv"
#define SCREEN_RESOLUTION @"res"
#define HOURS @"h"
#define MINUTES @"m"
#define SECONDS @"s"
#define ACTION_NAME @"action_name"
#define URL_ @"url"
#define VISITOR_ID @"_id"
#define VISIT_SCOPE_CUSTOM_VARIABLES @"_cvar"
#define RANDOM_NUMBER @"r"
#define FIRST_VISIT_TIMESTAMP @"_idts"
#define LAST_VISIT_TIMESTAMP @"_viewts"
#define TOTAL_NUMNER_OF_VISIT @"_idvc"
#define GOAL_ID @"idgoal"
#define REVENUE @"revenue"

// Piwik parmeter values
#define RECORD_VALUE @"1"
#define API_VERSION_VALUE @"1"

// Fallback user-agent string set to iPhone iOS 5. Must set a valid user-agent or the piwik server will not accept the request
#define USER_AGENT @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"

// Piwik http request parameters
#define MAX_CACHED_EVENTS 100
#define REQUEST_TIMEOUT 20
#define RETRY_TIMER 60
#define RETRY_COUNTER @"retryCounter"
#define MAX_NUMBER_OF_RETRIES 10

// Custom variables
#define MAX_CUSTOM_VARIABLES 5
#define MAX_LENGTH_CUSTOM_NAME 20
#define MAX_LENGTH_CUSTOM_VALUE 100

// Notification names
#define QUEUED_NOTIFICATION @"PTEventQueuedSuccessNotification"
#define QUEUED_FAILED_NOTIFICATION @"PTEventQueuedFailedNotification"
#define DISPATCH_NOTIFICATION @"PTDispatchSuccessNotification"
#define DISPATCH_FAILED_NOTIFICATION @"PTDispatchFailedNotification"

#define NUMER_OF_EVENTS @"NumberOfCachedEvents"

// User default keys
#define USER_DEFAULTS_OPT_OUT  @"optin"
#define USER_DEFAULTS_VISITOR_ID @"piwiki.visitorID"
#define USER_DEFAULTS_NUMBER_OF_VISITS @"piwiki.totalNumberOfVisits"
#define USER_DEFAULTS_LAST_VISIT @"piwiki.lastVisitTimestamp"
#define USER_DEFAULTS_FIRST_VISIT @"piwiki.firstVisitTimestamp"


#pragma mark - Private interface

// Private methods
@interface PiwikTracker ()

// The scope of Customer variables
//typedef enum {
//  kVisitorScope = 1U,
//  kSessionScope = 2U,  // Not supported yet
//  kPageScope = 3U      // Not supported yet
//} CustomVariableScope;

- (void)cacheEvent:(NSMutableDictionary*)params completionBlock:(void(^)(NSError* error))block;
- (BOOL)addVisitorScopeCustomVariableWithName:(NSString*)name value:(NSString*)value withError:(NSError**)error;
- (BOOL)addPageScopeCustomVariableWithName:(NSString*)name value:(NSString*)value withError:(NSError**)error;
- (BOOL)addCustomVariableWithName:(NSString*)name value:(NSString*)value
                 toScopeVariables:(NSMutableArray*)customVariables withError:(NSError**)error;
- (NSString*)toStringFromDict:(NSDictionary*)dict;
- (NSString*)urlEncode:(NSString*)unencodedString;
- (NSError*)parsingErrorWithDescription:(NSString*)format, ...;
// Core data methods
- (NSURL*)applicationDocumentsDirectory;
- (BOOL)saveContext:(NSError**)error;

@property (nonatomic, strong) NSURL *piwikURL;
@property (nonatomic, strong) NSString *siteID;
@property (nonatomic, strong) NSString *authenticationToken;
@property (nonatomic) BOOL tracking;
@property (nonatomic, strong) NSString *commonParameters;
@property (nonatomic, strong) NSMutableArray *visitorCustomVariables;
@property (nonatomic) NSInteger totalNumberOfVisits;
@property (nonatomic) double lastVisitTimestamp;
@property (nonatomic) double firstVisitTimestamp;
@property (nonatomic) dispatch_queue_t queue;
// Core data properties
@property (readonly) NSManagedObjectContext *managedObjectContext;
@property (readonly) NSManagedObjectModel *managedObjectModel;
@property (readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


// Implementation of the PiwikTracker
@implementation PiwikTracker

// Need to @synthesize get an instance variable since we provide getter and setter
@synthesize visitorID = _visitorID;
@synthesize totalNumberOfVisits = _totalNumberOfVisits;
@synthesize firstVisitTimestamp = _firstVisitTimestamp;
@synthesize lastVisitTimestamp = _lastVisitTimestamp;


#pragma mark - init and dealloc

// Init
- (id)init {
  self = [super init];
  if (self) {
    // Initialise instance variables
    self.queue = dispatch_queue_create("com.levin.mattias", NULL);
    self.visitorCustomVariables = [NSMutableArray array];
    self.maximumNumberOfCachedEvents = MAX_CACHED_EVENTS;
    
    // Set default user defatult values
    NSDictionary *defaultValues = @{
      USER_DEFAULTS_OPT_OUT : @NO
    };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
  }
  
  return self;
}


# pragma mark - Start and stop tracker

// Returns the shared tracker
+ (PiwikTracker*)sharedTracker {
  static PiwikTracker *_sharedInstance;
  
  DLOG(@"Return shared tracker instance");
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[PiwikTracker alloc] init];
  });
  
  return _sharedInstance;
}


// Start tracking
- (BOOL)startTrackerWithPiwikURL:(NSString*)piwikURL
                          siteID:(NSString*)siteID
             authenticationToken:(NSString*)authenticationToken
                       withError:(NSError**)error {
  DLOG(@"Start tracking");
  
  // Create the base url for the the tracker REST API
  NSURL *url = [NSURL URLWithString:piwikURL];
  if (!url) {
    *error = [self parsingErrorWithDescription:@"URL is invalid format %@", piwikURL];
    return NO;
  }
  
  if ([piwikURL hasSuffix:@"/piwik.php"] == NO && [piwikURL hasSuffix:@"/piwik-proxy.php"] == NO) {
    url = [url URLByAppendingPathComponent:@"piwik.php"];
  }
  self.piwikURL = url;
  
  // Site id
  self.siteID = siteID;
  
  // Authenticaion token
  self.authenticationToken = authenticationToken;
  
  // Turn tracking status on
  self.tracking = YES;
  
  // Set the sameple rate view to default value 100
  self.sampleRate = 100;
  
  // No dry run
  self.dryRun = NO;
  
  // No opt out
  self.optOut = NO;
  
  // Reset common parameters
  self.commonParameters = nil;
  
  // Count each time tracking is started.
  // Each start of the tracker will be counted and reported as a unique visit to the Piwik server
  self.totalNumberOfVisits = self.totalNumberOfVisits + 1;
  
  // Store the first time ever that tracker was started
  // This will be reported to the Piwik server
  self.firstVisitTimestamp = [[NSDate date] timeIntervalSince1970];
  
  // Cache the user agent (do not use the value yet)
  NSString *ua = self.userAgent;
#pragma unused(ua) // Supress unused compiler warning
  
  return YES;
}


// Turn off the tracker
- (BOOL)stopTracker {
  DLOG(@"Stop tacking");
  
  // Turn tracking status off
  self.tracking = NO;
  
  // Save the timestamp the tracking is stopped
  // This timestamp will be reported as last visited to the Piwik server
  self.lastVisitTimestamp = [[NSDate date] timeIntervalSince1970];
  
  return YES;
}


#pragma mark - Track actions

// Track a page view
- (void)trackPageview:(NSString*)pageName completionBlock:(void(^)(NSError* error))block {
  DLOG(@"Track page view for %@", pageName);
  
  // Create an event record
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  // Set action name
  [params setValue:pageName forKey:ACTION_NAME];
  
  // Setting the url is mandatory but not fully applicable in an application context
  // Set url by combining the app name and the action name
  NSString *appDisplayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
  [params setValue:[NSString stringWithFormat:@"http://%@/%@", appDisplayName, pageName] forKey:URL_];
  
  // Add common parameters and cache the event
  [self cacheEvent:params completionBlock:block];
}


// Track a goal conversion
- (void)trackGoal:(NSInteger)goal completionBlock:(void(^)(NSError* error))block {
  [self trackGoal:goal withRevenue:-1 completionBlock:block];
}


// Track a goal conversion with a specific revenue
- (void)trackGoal:(NSInteger)goal withRevenue:(double)revenue completionBlock:(void(^)(NSError* error))block {
  
  // Create a event record
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  // Set goal id
  [params setValue:[NSString stringWithFormat:@"%d", goal] forKey:GOAL_ID];
  
  if (revenue > 0)
    [params setValue:[NSString stringWithFormat:@"%f", revenue] forKey:REVENUE];
  
  // Setting the url is mandatory but not fully applicable in an application context
  // Set url by combining the app name and appending a speical path
  NSString *appDisplayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
  [params setValue:[NSString stringWithFormat:@"http://%@/goal", appDisplayName] forKey:URL_];
  
  // Add common parameters and cache the event
  [self cacheEvent:params completionBlock:block];
}


// Add common page parameters and cache the event
- (void)cacheEvent:(NSMutableDictionary*)params completionBlock:(void(^)(NSError* error))block {
  
  // Use a serial queue to store events
  dispatch_async(self.queue, ^ {
    
    if (!self.tracking) {
      // Tracking is currently turned off
      [[NSNotificationCenter defaultCenter] postNotificationName:QUEUED_FAILED_NOTIFICATION object:self];
      block([self parsingErrorWithDescription:@"Tracking is currently turned off"]);
      return;
    }
    
    // Use the sampling rate to decide if the event should be handled or not
    if (self.sampleRate != 100 && self.sampleRate < (arc4random_uniform(101))) {
      DLOG(@"Event will not be logged due to out sample");
      //[[NSNotificationCenter defaultCenter] postNotificationName:QUEUED_NOTIFICATION object:self];
      block(nil);
      return;
    }
    
    // Add local time
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    
    [params setValue:[NSString stringWithFormat:@"%d", [dateComponents hour]] forKey:HOURS];
    [params setValue:[NSString stringWithFormat:@"%d", [dateComponents minute]] forKey:MINUTES];
    [params setValue:[NSString stringWithFormat:@"%d", [dateComponents second]] forKey:SECONDS];
    
    // Set first and last visit timestamp
    [params setValue:[NSString stringWithFormat:@"%.0f", self.lastVisitTimestamp] forKey:LAST_VISIT_TIMESTAMP];
    [params setValue:[NSString stringWithFormat:@"%d", self.totalNumberOfVisits] forKey:TOTAL_NUMNER_OF_VISIT];
    
    // Check if we reached the limit of the number cached events
    NSError *error =  nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PTEvent"
                                        inManagedObjectContext:self.managedObjectContext]];
    NSUInteger numberOfEvents = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    if (numberOfEvents ==  NSNotFound) {
      // Check that the featch count was ok
      error = [self parsingErrorWithDescription:@"Counting the number of cached events failed: %@", [error description]];
    } else if (numberOfEvents >= self.maximumNumberOfCachedEvents) {
      // Make sure we do no cache more events the allowed
      error = [self parsingErrorWithDescription:@"Maximium number of allowed cached events reached: %d", self.maximumNumberOfCachedEvents];
    }
    
    if (error != nil) {
      // Report error
      [[NSNotificationCenter defaultCenter] postNotificationName:QUEUED_FAILED_NOTIFICATION object:self];
      block(error);
      return;
    } else {
      // Store the event in core data
      PTEvent *entity = (PTEvent*)[NSEntityDescription insertNewObjectForEntityForName:@"PTEvent"
                                                                inManagedObjectContext:self.managedObjectContext];
      entity.eventData = [self toStringFromDict:params];
      if (![self saveContext:&error]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:QUEUED_FAILED_NOTIFICATION object:self];
        block(error);
      } else {
        // The event was stored
        [[NSNotificationCenter defaultCenter]
         postNotificationName:QUEUED_NOTIFICATION
         object:self
         userInfo:@{NUMER_OF_EVENTS : [NSNumber numberWithInteger:numberOfEvents]}];
        block(nil);
      }
    }
  });
}


#pragma mark - Dispatch events

// Dispatch all cached events to the piwik server
- (void)dispatchWithCompletionBlock:(void (^)(NSError* error))block {
  DLOG(@"Dispatch cached events");
  
  // Check if the user opted out
  if (self.optOut) {
    // Do not track anything
    return;
  }
  
  // Create a tasks that sends the first cached event to the Piwik server
  dispatch_async(self.queue, ^ {
    
    // Get the events in Core Data with oldest time stamp
    NSError *error = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PTEvent"
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchLimit:2];
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Check that the featch was ok
    if (fetchResults == nil) {
      [[NSNotificationCenter defaultCenter] postNotificationName:DISPATCH_FAILED_NOTIFICATION object:self];
      block([self parsingErrorWithDescription:@"Featching cached events failed: %@", [error description]]);
      return;
    }
    
    // Protect against empty cache, nothing to send
    if ([fetchResults count] == 0) {
      DLOG(@"Event cache is empty");
      [[NSNotificationCenter defaultCenter] postNotificationName:DISPATCH_NOTIFICATION object:self];
      block(nil);
      return;
    }
    
    // Take the first event from the cache
    PTEvent *event = [fetchResults objectAtIndex:0];
    
    // Add random number
    int randomNumber = arc4random_uniform(50000);
    NSDictionary *params = @{RANDOM_NUMBER : [NSString stringWithFormat:@"%d", randomNumber]};
    
    // Create the full URL - Piwik server url + cached + additional parameters
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@&%@&%@",
                                       self.piwikURL,
                                       event.eventData,
                                       self.commonParameters,
                                       [self toStringFromDict:params]]];
    
    if (self.dryRun) {
      // Dry run, print the url to the console only
      // Format the URL for easy reading
      NSMutableString *prettyURL = [NSMutableString stringWithString:[url description]];
      [prettyURL replaceOccurrencesOfString:@"?" withString:@"\n  " options:NSLiteralSearch
                                      range:NSMakeRange(0, [prettyURL length])];
      [prettyURL replaceOccurrencesOfString:@"&" withString:@"\n  " options:NSLiteralSearch
                                      range:NSMakeRange(0, [prettyURL length])];
      ALOG(@"Dry run request:\n%@", prettyURL);
    } else {
      // Make a HTTP get request to the Piwik server
      NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:url];
      [httpRequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
      [httpRequest setTimeoutInterval:REQUEST_TIMEOUT];
      
      // Set User-Agent header
      [httpRequest setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
      
      // Set Accept-Language header
      [httpRequest setValue:self.acceptLanguage forHTTPHeaderField:@"Accept-Language"];
      
      NSURLResponse *response = nil;
      DLOG(@"Sending synchonous request to the piwik server %@", httpRequest);
      [NSURLConnection sendSynchronousRequest:httpRequest returningResponse:&response error:&error];
      
      // Check the http repsonse code
      if (error != nil || [(NSHTTPURLResponse*)response statusCode] != 200) {
        // Piwik server did not return 200
        [[NSNotificationCenter defaultCenter] postNotificationName:DISPATCH_FAILED_NOTIFICATION object:self];
        block([self parsingErrorWithDescription:@"Request to Piwik server failed with http repose code: %d and error: %@",
               [(NSHTTPURLResponse*)response statusCode], [error description]]);
        return;
      }
    }
    
    // Event has been successfully received by Piwik server, remove it from the cache
    [self.managedObjectContext deleteObject:event];
    if (![self saveContext:&error]) {
      [[NSNotificationCenter defaultCenter] postNotificationName:DISPATCH_FAILED_NOTIFICATION object:self];
      block(error);
    } else {
      // Send any remaining cached events
      if ([fetchResults count] > 1)
        [self dispatchWithCompletionBlock:block];
      else {
        // No more events in the cache, report success
        [[NSNotificationCenter defaultCenter] postNotificationName:DISPATCH_NOTIFICATION object:self];
        block(nil);
      }
    }
  });
}


// Method for deleting all cached events
- (void)emptyQueueWithCompletionBlock:(void (^)(NSError* error))block {
  DLOG(@"Delete all cached events");
  
  // Delete all events
  dispatch_async(self.queue, ^ {
    // Get all events from core data and delete them on by one
    NSError *error = nil;
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PTEvent" inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setIncludesPropertyValues:NO]; // only fetch the managedObjectID
    
    NSArray *events = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (events != nil && error == nil) {
      DLOG(@"Number of cached events to delete: %d", [events count]);
      for (PTEvent *event in events) {
        [self.managedObjectContext deleteObject:event];
      }
      
      if (![self saveContext:&error])
        block(error);
      else
        block(nil);
      
    } else {
      block([self parsingErrorWithDescription:@"Failed to delete cached events %@", [error description]]);
    }
  });
  
}


#pragma mark - Properties getters and setters

// Getter for if the tracker is currently tracking or not
- (BOOL)isTracking {
  return self.tracking;
}


// Create common static parameters that does not change
- (NSString*)commonParameters {
  // Check if common parameters already been set
  if (!_commonParameters) {
    NSMutableDictionary *commonParams = [NSMutableDictionary dictionary];
    
    // Force recording
    [commonParams setValue:RECORD_VALUE forKey:RECORD];
    
    // API version
    [commonParams setValue:API_VERSION_VALUE forKey:API_VERSION];
    
    // siteId
    [commonParams setValue:self.siteID forKey:SITE_ID];
    
    // Authentication token
    if (self.authenticationToken) {
      [commonParams setValue:self.authenticationToken forKey:AUTH_TOKEN];
    }
    
    // Set resolution
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    
    [commonParams setValue:[NSString stringWithFormat:@"%.0fx%.0f", screenSize.width, screenSize.height]
                    forKey:SCREEN_RESOLUTION];
    
    // Vistior ID
    [commonParams setObject:self.visitorID forKey:VISITOR_ID];
    
    // First visit timestamp
    [commonParams setObject:[NSString stringWithFormat:@"%.0f", self.firstVisitTimestamp] forKey:FIRST_VISIT_TIMESTAMP];
    
    // Set custom variables - platform, OS version and application version
    UIDevice *device = [UIDevice currentDevice];
    [self addVisitorScopeCustomVariableWithName:@"Platform" value:[device model] withError:NULL];
    [self addVisitorScopeCustomVariableWithName:@"OS version" value:[device systemVersion] withError:NULL];
    
    NSString* versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [self addVisitorScopeCustomVariableWithName:@"App version" value:versionNumber withError:NULL];
    
    NSString *cvString = [NSString stringWithFormat:@"{%@}", [self.visitorCustomVariables componentsJoinedByString:@","]];
    [commonParams setObject:cvString forKey:VISIT_SCOPE_CUSTOM_VARIABLES];
    
    _commonParameters = [self toStringFromDict:commonParams];
  }
  
  return _commonParameters;
}


// Get a unique visitor id
- (NSString*)visitorID {
  
  if (!_visitorID) {
    
    // Check the user defaults for a visitor id
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _visitorID = [userDefaults stringForKey:USER_DEFAULTS_VISITOR_ID];
    
    if (!_visitorID) {
      // No value, create one and store in user defaults
      DLOG(@"User defaults does not contain a visitor id, create a new");
      
      NSArray *hexValues = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
                             @"a", @"b", @"c", @"d", @"e", @"f"];
      
      NSMutableString *randomHexString = [NSMutableString stringWithCapacity:16];
      for (int i = 0; i < 16; i++) {
        int index = arc4random_uniform(16);
        [randomHexString appendString:[hexValues objectAtIndex:index]];
      }
      _visitorID = randomHexString;
      
      // Store is in user defaults
      [userDefaults setObject:_visitorID forKey:USER_DEFAULTS_VISITOR_ID];
      [userDefaults synchronize];
    }
    
  }
  
  return _visitorID;
}


// Set a custom visitor id
- (void)setVisitorID:(NSString*)visitorID {
  
  if ([visitorID length] != 16) {
    _visitorID = [visitorID stringByPaddingToLength:16 withString:@"0" startingAtIndex:0];
  } else {
    _visitorID = visitorID;
  }
  
  // Invalidate common paramters
  self.commonParameters = nil;
}


// Get the user agent
- (NSString*)userAgent {
  static PTUserAgentReader *userAgentReader = nil;
  
  if (!_userAgent) {
    // Try and get the user agent
    if (!userAgentReader) {
      userAgentReader = [[PTUserAgentReader alloc] init];
    }
    
    [userAgentReader userAgentStringWithCallbackBlock:^(NSString *userAgent) {
      self.userAgent = userAgent;
    }];
    
    // Use a fallback UA while we wait for the real value
    return USER_AGENT;
  }
  
  return _userAgent;
}


// Get the accept language
- (NSString*)acceptLanguage {
  if (!_acceptLanguage) {
    // If not set use the current locale language code
    NSLocale *currentLocale = [NSLocale currentLocale];
    _acceptLanguage = [currentLocale objectForKey:NSLocaleLanguageCode];
  }
  return _acceptLanguage;
}


// Set the total number of visits
- (void)setTotalNumberOfVisits:(NSInteger)totalNumberOfVisits {
  if (totalNumberOfVisits >= 0) {
    _totalNumberOfVisits = totalNumberOfVisits;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:totalNumberOfVisits forKey:USER_DEFAULTS_NUMBER_OF_VISITS];
    [userDefaults synchronize];
  }
}


// Get the total number of visits (application starts)
- (NSInteger)totalNumberOfVisits {
  if (_totalNumberOfVisits <= 0) {
    // Read value from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _totalNumberOfVisits = [userDefaults integerForKey:USER_DEFAULTS_NUMBER_OF_VISITS];
  }
  return _totalNumberOfVisits;
}


// Set last visit timestamp
- (void)setLastVisitTimestamp:(double)lastVisitTimestamp {
  if (lastVisitTimestamp >= 0.0f) {
    _lastVisitTimestamp = lastVisitTimestamp;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:_lastVisitTimestamp forKey:USER_DEFAULTS_LAST_VISIT];
    [userDefaults synchronize];
  }
}


// Get last visit timestamp
- (double)lastVisitTimestamp {
  if (_lastVisitTimestamp <= 0.0f) {
    // Read value from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _lastVisitTimestamp = [userDefaults doubleForKey:USER_DEFAULTS_LAST_VISIT];
  }
  return _lastVisitTimestamp;
}


// Set first visit timestamp
- (void)setFirstVisitTimestamp:(double)firstVisitTimestamp {
  if (firstVisitTimestamp >= 0.0f && self.firstVisitTimestamp <= 0.0f) {
    _firstVisitTimestamp = firstVisitTimestamp;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:firstVisitTimestamp forKey:USER_DEFAULTS_FIRST_VISIT];
    [userDefaults synchronize];
  }
}


// Get first visit timestamp
- (double)firstVisitTimestamp {
  if (_firstVisitTimestamp <= 0.0f) {
    // Read value from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _firstVisitTimestamp = [userDefaults doubleForKey:USER_DEFAULTS_FIRST_VISIT];
  }
  return _firstVisitTimestamp;
}


// Set opt out
- (void)setOptOut:(BOOL)optOut {  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setBool:optOut forKey:USER_DEFAULTS_OPT_OUT];
  [userDefaults synchronize];  
}


// Get opt out
- (BOOL)optOut {
  return [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_OPT_OUT];
}


#pragma mark - Help methods

// Add a visitor scope custom variable
- (BOOL)addVisitorScopeCustomVariableWithName:(NSString*)name value:(NSString*)value withError:(NSError**)error {
  // Get the visitor scope variable and pass on
  // Visitor custom variable should not change unless the vistior change
  return [self addCustomVariableWithName:name value:value toScopeVariables:self.visitorCustomVariables withError:error];
}


// Add a page scope custom variable
- (BOOL)addPageScopeCustomVariableWithName:(NSString*)name value:(NSString*)value withError:(NSError**)error {
  // TODO Add implementation
  return NO;
}


// Add custom variable at a specific index
- (BOOL)addCustomVariableWithName:(NSString*)name value:(NSString*)value
                 toScopeVariables:(NSMutableArray*)customVariables withError:(NSError**)error {
  
  // Piwik only support 5 customer variables
  if ([customVariables count] > MAX_CUSTOM_VARIABLES) {
    *error = [self parsingErrorWithDescription:@"Maximum 5 custom variables are allowed"];
    return NO;
  }
  
  // Do not allow nil
  if (!name) {
    *error = [self parsingErrorWithDescription:@"Name can not be empty or nil"];
    return NO;
  }
  
  if (!value) {
    *error = [self parsingErrorWithDescription:@"Value can not be empty or nil"];
    return NO;
  }
  
  // Check the length of the name and value
  if ([name length] > MAX_LENGTH_CUSTOM_NAME)
    name = [name substringToIndex:MAX_LENGTH_CUSTOM_NAME - 1];
  
  if ([value length] > MAX_LENGTH_CUSTOM_VALUE)
    value = [value substringToIndex:MAX_LENGTH_CUSTOM_VALUE - 1];
  
  [customVariables addObject:[NSString stringWithFormat:@"\"%d\":[\"%@\",\"%@\"]", [customVariables count] + 1, name, value]];
  
  return YES;
}


// Create a parameter string from a NSDictionary
- (NSString*)toStringFromDict:(NSDictionary*)dict {
  // Create the parameter list
  NSMutableArray *params = [NSMutableArray array];
  [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    // Need to do URL encoding of the value
    [params addObject:[NSString stringWithFormat:@"%@=%@", key, [self urlEncode:(NSString*)obj]]];
  }];
  
  return [params componentsJoinedByString:@"&"];
}


// Url encoding a string
- (NSString*)urlEncode:(NSString*)unencodedString {
  return (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                     (CFStringRef)unencodedString,
                                                                     NULL,
                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                     kCFStringEncodingUTF8);
}


// Format an error message and raise and expection
- (NSError*)parsingErrorWithDescription:(NSString*)format, ... {
  // Create a formatted string from input parameters
  va_list varArgsList;
  va_start(varArgsList, format);
  NSString *formatString = [[NSString alloc] initWithFormat:format arguments:varArgsList];
  va_end(varArgsList);
  
  ALOG(@"Error with message: %@", formatString);
  
  // Create the error and store the state
  NSDictionary *errorInfo = @{NSLocalizedDescriptionKey : formatString};
  return [NSError errorWithDomain:@"levin.mattias.PwikTracker.ErrorDomain" code:1 userInfo:errorInfo];
}


#pragma mark - Core data methods

// Save core data context
- (BOOL)saveContext:(NSError**)error {
  
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext == nil) {
    *error = [self parsingErrorWithDescription:@"Not possile to save to core data, management object context is nil"];
    return NO;
  }
  
  // Check if there are any changes to save
  if ([managedObjectContext hasChanges])
    // Save
    if (![managedObjectContext save:error]) {
      // Not possible to save the context
      ALOG(@"Unresolved error saving core data context %@ %@", *error, [*error userInfo]);
      return NO;
    }
  
  return YES;
}


// Returns the managed object context for the application.
- (NSManagedObjectContext*)managedObjectContext {
  static NSManagedObjectContext *managedObjectContext = nil;
  
  if (managedObjectContext != nil){
    return managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
  if (coordinator != nil) {
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  return managedObjectContext;
}


// Returns the persistent store coordinator for the application.
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
  static NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
  
  if (persistentStoreCoordinator != nil)
  {
    return persistentStoreCoordinator;
  }
  
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PiwikTracker.sqlite"];
  
  NSError *error = nil;
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                configuration:nil
                                                          URL:storeURL
                                                      options:nil
                                                        error:&error]) {
    // Failed to set open the core data storage file.
    DLOG(@"Unable to configure core data storage, try again: %@", error);
    
    // Delete the storage file and try and set up the stack again
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:nil
                                                          error:&error]) {
      ALOG(@"Unable to configure core data storage %@, %@", error, [error userInfo]);
      return nil;
    }
    
  }
  
  return persistentStoreCoordinator;
}


// Returns the URL to the application's Documents directory.
- (NSURL*)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


// Returns the managed object model for the application.
- (NSManagedObjectModel*)managedObjectModel {
  static NSManagedObjectModel *managedObjectModel = nil;
  
  if (managedObjectModel != nil)
  {
    return managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PiwikTracker" withExtension:@"momd"];
  managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  return managedObjectModel;
}


@end
