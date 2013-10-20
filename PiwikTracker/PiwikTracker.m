//
//  PiwikTracker.m
//  PiwikTracker
//
//  Created by Mattias Levin on 3/12/13.
//  Copyright 2013 Mattias Levin. All rights reserved.
//

#import "PiwikTracker.h"
#import <CommonCrypto/CommonDigest.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "PTEventEntity.h"
#import "PTLocationManagerWrapper.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif


#ifndef DLog
#   ifdef DEBUG
#       define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#   else
#       define DLog(...)
#   endif
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

// User default keys
// The key withh include the site id in order to support multiple trackers per applicationz
static NSString * const PiwikUserDefaultTotalNumberOfVisitsKey = @"PiwikTotalNumberOfVistsKey";
static NSString * const PiwikUserDefaultCurrentVisitTimestampKey = @"PiwikCurrentVisitTimestampKey";
static NSString * const PiwikUserDefaultPreviousVistsTimestampKey = @"PiwikPreviousVistsTimestampKey";
static NSString * const PiwikUserDefaultFirstVistsTimestampKey = @"PiwikFirstVistsTimestampKey";
static NSString * const PiwikUserDefaultVisitorIDKey = @"PiwikVisitorIDKey";
static NSString * const PiwikUserDefaultOptOutKey = @"PiwikOptOutKey";

// Piwik query parameter names
static NSString * const PiwikParameterSiteID = @"idsite";
static NSString * const PiwikParameterAuthenticationToken = @"token_auth";
static NSString * const PiwikParameterRecord = @"rec";
static NSString * const PiwikParameterAPIVersion = @"apiv";
static NSString * const PiwikParameterScreenReseloution = @"res";
static NSString * const PiwikParameterHours = @"h";
static NSString * const PiwikParameterMinutes = @"m";
static NSString * const PiwikParameterSeconds = @"s";
static NSString * const PiwikParameterActionName = @"action_name";
static NSString * const PiwikParameterURL = @"url";
static NSString * const PiwikParameterVisitorID = @"_id";
static NSString * const PiwikParameterVisitScopeCustomVariables = @"_cvar";
static NSString * const PiwikParameterRandomNumber = @"r";
static NSString * const PiwikParameterFirstVisitTimestamp = @"_idts";
static NSString * const PiwikParameterPreviousVisitTimestamp = @"_viewts";
static NSString * const PiwikParameterTotalNumberOfVisits = @"_idvc";
static NSString * const PiwikParameterGoalID = @"idgoal";
static NSString * const PiwikParameterRevenue = @"revenue";
static NSString * const PiwikParameterSessionStart = @"new_visit";
static NSString * const PiwikParameterLanguage = @"lang";
static NSString * const PiwikParameterLatitude = @"lat";
static NSString * const PiwikParameterLongitude = @"long";
static NSString * const PiwikParameterSearchKeyword = @"search";
static NSString * const PiwikParameterSearchCategory = @"search_cat";
static NSString * const PiwikParameterSearchNumberOfHits = @"search_count";

// Piwik default parmeter values
static NSString * const PiwikDefaultRecordValue = @"1";
static NSString * const PiwikDefaultAPIVersionValue = @"1";

// Custom variables
static NSUInteger const PiwikCustomVariablesMaxNumber = 5;
static NSUInteger const PiwikCustomVariablesMaxNameLength = 20;
static NSUInteger const PiwikCustomVariablesMaxValueLengt = 100;

// Default values
static NSUInteger const PiwikDefaultSessionTimeout = 120;
static NSUInteger const PiwikDefaultDispatchTimer = 120;
static NSUInteger const PiwikDefaultMaxNumberOfStoredEvents = 500;
static NSUInteger const PiwikDefaultSampleRate = 100;
static NSUInteger const PiwikDefaultNumberOfEventsPerRequest = 20;

static NSUInteger const PiwikHTTPRequestTimeout = 5;

static NSUInteger const PiwikExceptionDescriptionMaximumLength = 50;

// Page view prefix values
static NSString * const PiwikPrefixView = @"screen";
static NSString * const PiwikPrefixEvent = @"event";
static NSString * const PiwikPrefixException = @"exception";
static NSString * const PiwikPrefixExceptionFatal = @"fatal";
static NSString * const PiwikPrefixExceptionCaught = @"caught";
static NSString * const PiwikPrefixSocial = @"social";


@interface PiwikTracker ()

@property (nonatomic) NSUInteger totalNumberOfVisits;

@property (nonatomic, readonly) NSTimeInterval firstVisitTimestamp;
@property (nonatomic) NSTimeInterval previousVisitTimestamp;
@property (nonatomic) NSTimeInterval currentVisitTimestamp;
@property (nonatomic, strong) NSDate *appDidEnterBackgroundDate;

@property (nonatomic, strong) NSMutableArray *visitorCustomVariables;

@property (nonatomic, strong) NSDictionary *staticParameters;

@property (nonatomic, strong) NSTimer *dispatchTimer;
@property (nonatomic) BOOL isDispatchRunning;

@property (nonatomic, strong) PTLocationManagerWrapper *locationManager;

@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (id)initWithBaseURL:(NSURL*)baseURL siteID:(NSString*)siteID authenticationToken:(NSString*)authenticationToken;

- (void)startDispatchTimer;
- (void)stopDispatchTimer;

- (void)appDidBecomeActive:(NSNotification*)notification;
- (void)appDidEnterBackground:(NSNotification*)notification;

- (NSDictionary*)addCommonParameters:(NSDictionary*)parameters;
- (BOOL)queueEvent:(NSDictionary*)parameters;
- (void)dispatch:(NSNotification*)notification;
- (void)sendEvent;
- (void)sendEventDidFinishHasMorePending:(BOOL)hasMore;
- (BOOL)shouldAbortdispatchForNetworkError:(NSError*)error;

- (BOOL)storeEventWithParameters:(NSDictionary*)parameters completionBlock:(void (^)(void))completionBlock;
- (void)eventsFromStore:(NSUInteger)numberOfEvents completionBlock:(void (^)(NSArray *entityIDs, NSArray *events, BOOL hasMore))completionBlock;
- (void)deleteEventsWithIDs:(NSArray*)entityIDs;

- (NSURL*)applicationDocumentsDirectory;

+ (NSString*)encodeCustomVariables:(NSArray*)variables;
+ (NSString*)md5:(NSString*)input;
+ (NSString*)UUIDString;

@end


// Functions
NSString* customVariable(NSString* name, NSString* value);
NSString* userDefaultKeyWithSiteID(NSString* siteID, NSString *key);


@implementation PiwikTracker

@synthesize totalNumberOfVisits = _totalNumberOfVisits;
@synthesize firstVisitTimestamp = _firstVisitTimestamp;
@synthesize previousVisitTimestamp = _previousVisitTimestamp;
@synthesize currentVisitTimestamp = _currentVisitTimestamp;
@synthesize clientID = _clientID;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


static PiwikTracker *_sharedInstance;

// Get shared instance
+ (instancetype)sharedInstanceWithBaseURL:(NSURL*)baseURL siteID:(NSString*)siteID authenticationToken:(NSString*)authenticationToken {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[PiwikTracker alloc] initWithBaseURL:baseURL siteID:siteID authenticationToken:authenticationToken];
  });
  
  return _sharedInstance;
}


+ (instancetype)sharedInstance {
  
  if (!_sharedInstance) {
    ALog(@"Piwik tracker must first be initialized using sharedInstanceWithBaseURL:siteID:authenticationToken:");
    return nil;
  } else {
    return _sharedInstance;
  }

}


// Init new tracker
- (id)initWithBaseURL:(NSURL*)baseURL siteID:(NSString*)siteID authenticationToken:(NSString*)authenticationToken {
  
  // Make sure the base url is correct
  NSString *lastPathComponent = [baseURL lastPathComponent];
  if ([lastPathComponent isEqualToString:@"piwik.php"] && [lastPathComponent isEqualToString:@"piwik-proxy.php"]) {
    baseURL = [baseURL URLByDeletingLastPathComponent];
  }
    
  if (self = [super initWithBaseURL:baseURL]) {
    
    // Initialize instance variables
    
    _authenticationToken = authenticationToken;
    _siteID = siteID;
    
    _isPrefixingEnabled = YES;
    
    _sessionTimeout = PiwikDefaultSessionTimeout;
    
    _sampleRate = PiwikDefaultSampleRate;
    
    // By default a new session will be started when the tracker is created
    _sessionStart = YES;
    
    _dispatchInterval = PiwikDefaultDispatchTimer;
    _maxNumberOfQueuedEvents = PiwikDefaultMaxNumberOfStoredEvents;
    _isDispatchRunning = NO;
    
    // Bulk tracking require authentication token
    if (_authenticationToken) {
      _eventsPerRequest = PiwikDefaultNumberOfEventsPerRequest;
    } else {
      _eventsPerRequest = 1;
    }
    
    _locationManager = [[PTLocationManagerWrapper alloc] init];
    
    _includeLocationInformation = NO;
    
    // Set default user defatult values
    NSDictionary *defaultValues = @{PiwikUserDefaultOptOutKey : @NO};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];

    ALog(@"Piwik Tracker created with baseURL %@ and siteID %@", baseURL, siteID);
    
    if (self.optOut) {
      ALog(@"Piwik Tracker user optout from tracking");
    }
    
    if (_debug) {
      ALog(@"Piwik Tracker in debug mode, nothing will be sent to the server");
    }
    
    [self startDispatchTimer];
    
#if TARGET_OS_IPHONE
    dispatch_async(dispatch_get_main_queue(), ^{
      
      // Notifications
      // Run on main thread to avoid trigger notification when creating the tracker (will create two sessions)
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(appDidBecomeActive:)
                                                   name:UIApplicationDidBecomeActiveNotification
                                                 object:nil];
      
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(appDidEnterBackground:)
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:nil];
    });
#endif
    
    return self;
  }
  else {
    return nil;
  }
}


// Overwritten from AFHTTPClient
- (NSMutableURLRequest*)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
  
  NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];

  // Reduce request timeout
  request.timeoutInterval = PiwikHTTPRequestTimeout;
  
  return request;
}


// Start dispatch timer
- (void)startDispatchTimer {
  
  // Run on main tread run loop
  dispatch_async(dispatch_get_main_queue(), ^{
    
    [self stopDispatchTimer];
    
    // If dispatch interval is < 0, manual dispatch must be used
    // If dispatch internal is = 0, the event is dispatched automatically directly after the event is tracked
    if (self.dispatchInterval > 0) {
      
      // Run on timer
      self.dispatchTimer = [NSTimer scheduledTimerWithTimeInterval:self.dispatchInterval target:self selector:@selector(dispatch:) userInfo:nil repeats:NO];
      DLog(@"Dispatch timer started with interval %f", self.dispatchInterval);
            
    }
    
  });
  
}


// Stop dispatch timer
- (void)stopDispatchTimer {
  
  if (self.dispatchTimer) {
    [self.dispatchTimer invalidate];
    self.dispatchTimer = nil;
    
    DLog(@"Dispatch timer stopped");
  }
  
}


- (void)appDidBecomeActive:(NSNotification*)notification {

  // Create new session?
  if (!self.appDidEnterBackgroundDate || labs([self.appDidEnterBackgroundDate timeIntervalSinceNow]) >= self.sessionTimeout || self.appDidEnterBackgroundDate == 0) {
    self.sessionStart = YES;
  }
  
  [self.locationManager startMonitoringLocationChanges];
  
  [self startDispatchTimer];  
}


- (void)appDidEnterBackground:(NSNotification*)notification {
  self.appDidEnterBackgroundDate = [NSDate date];
  
  [self.locationManager stopMonitoringLocationChanges];
  
  [self stopDispatchTimer];
}


- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark Views and Events

// Send screen views
- (BOOL)sendView:(NSString*)screen {
  return [self sendViews:screen, nil];
}


// Send screen views
// Piwik support screen names with / and will group views hierarchically
- (BOOL)sendViews:(NSString*)screen, ... {
  
  // Collect var args
  NSMutableArray *components = [NSMutableArray array];
  va_list args;
  va_start(args, screen);
  for (NSString *arg = screen; arg != nil; arg = va_arg(args, NSString*)) {
    [components addObject:arg];
  }
  va_end(args);
  
  if (self.isPrefixingEnabled) {
    // Add prefix 
    [components insertObject:PiwikPrefixView atIndex:0];
  }
  
  return [self send:components];
 }


// Track the event as hierarchical screen view
- (BOOL)sendEventWithCategory:(NSString*)category action:(NSString*)action label:(NSString*)label {

  // Combine category, action and lable into a screen name
  NSMutableArray *components = [NSMutableArray array];

  if (self.isPrefixingEnabled) {
    [components addObject:PiwikPrefixEvent];
  }
  
  if (category) {
    [components addObject:category];
  }
  
  if (action) {
    [components addObject:action];
  }
  
  if (label) {
    [components addObject:label];
  }
  
  return [self send:components];
}


// Track exceptions and errors
- (BOOL)sendExceptionWithDescription:(NSString*)description isFatal:(BOOL)isFatal {
  
  // Maximum 50 character
  if (description.length > PiwikExceptionDescriptionMaximumLength) {
    description = [description substringToIndex:PiwikExceptionDescriptionMaximumLength];
  }
  
  NSMutableArray *components = [NSMutableArray array];
  
  if (self.isPrefixingEnabled) {
    [components addObject:PiwikPrefixException];
  }
  
  if (isFatal) {
    [components addObject:PiwikPrefixExceptionFatal];
  } else {
    [components addObject:PiwikPrefixExceptionCaught];
  }
  
  [components addObject:description];
  
  return [self send:components];
}


// Track social interaction
- (BOOL)sendSocialInteraction:(NSString*)action target:(NSString*)target forNetwork:(NSString*)network {

  NSMutableArray *components = [NSMutableArray array];

  if (self.isPrefixingEnabled) {
    [components addObject:PiwikPrefixSocial];
  }
  
  [components addObject:network];
  [components addObject:action];
  
  if (target) {
    [components addObject:target];
  }
  
  return [self send:components];
}


// Generic send method
- (BOOL)send:(NSArray*)components {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  NSString *actionName = [components componentsJoinedByString:@"/"];
  params[PiwikParameterActionName] = actionName;
  
  // Setting the url is mandatory but not fully applicable in an application context
  // Set url by using the action name
  params[PiwikParameterURL] = [NSString stringWithFormat:@"http://%@/%@", self.appName, actionName];
  
  DLog(@"Send page view %@", actionName);
  
  return [self queueEvent:[self addCommonParameters:params]];
}


// Track goal conversion
- (BOOL)sendGoalWithID:(NSString*)goalID revenue:(NSUInteger)revenue {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  params[PiwikParameterGoalID] = goalID;
  params[PiwikParameterRevenue] = [NSNumber numberWithInteger:revenue];
  
  // Setting the url is mandatory but not fully applicable in an application context
  params[PiwikParameterURL] = [NSString stringWithFormat:@"http://%@", self.appName];

  return [self queueEvent:[self addCommonParameters:params]];
}


// Track app search
- (BOOL)sendSearchWithKeyword:(NSString*)keyword category:(NSString*)category numberOfHits:(NSNumber*)numberOfHits {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];

  params[PiwikParameterSearchKeyword] = keyword;

  if (category) {
    params[PiwikParameterSearchCategory] = category;
  }
  
  if (numberOfHits && [numberOfHits integerValue] >= 0) {
    params[PiwikParameterSearchNumberOfHits]  = numberOfHits;
  }
  
  // Setting the url is mandatory but not fully applicable in an application context
  params[PiwikParameterURL] = [NSString stringWithFormat:@"http://%@", self.appName];
  
  return [self queueEvent:[self addCommonParameters:params]];  
}

   
// Add common Piwik query parameters
- (NSDictionary*)addCommonParameters:(NSDictionary*)parameters {
  
  if (self.sessionStart) {
    
    self.totalNumberOfVisits = self.totalNumberOfVisits + 1;
    self.currentVisitTimestamp = [[NSDate date] timeIntervalSince1970];
    
    // Reset static params to force a rebuild
    self.staticParameters = nil;
    
  }
  
  if (!self.staticParameters) {
    NSMutableDictionary *staticParameters = [NSMutableDictionary dictionary];
    
    staticParameters[PiwikParameterSiteID] = self.siteID;
    
    staticParameters[PiwikParameterRecord]  = PiwikDefaultRecordValue;
    
    staticParameters[PiwikParameterAPIVersion] = PiwikDefaultAPIVersionValue;
    
    if (self.authenticationToken) {
      staticParameters[PiwikParameterAuthenticationToken] = self.authenticationToken;
    }
    
    // Set resolution
#if TARGET_OS_IPHONE
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
#else
      CGRect screenBounds = [[NSScreen mainScreen] frame];
      CGFloat screenScale = [[NSScreen mainScreen] backingScaleFactor];
#endif
    CGSize screenSize = CGSizeMake(CGRectGetWidth(screenBounds) * screenScale, CGRectGetHeight(screenBounds) * screenScale);
    staticParameters[PiwikParameterScreenReseloution] = [NSString stringWithFormat:@"%.0fx%.0f", screenSize.width, screenSize.height];
    
    staticParameters[PiwikParameterVisitorID] = self.clientID;
    
    staticParameters[PiwikParameterTotalNumberOfVisits] = [NSString stringWithFormat:@"%ld", (unsigned long)self.totalNumberOfVisits];
    
    // Timestamps
    staticParameters[PiwikParameterFirstVisitTimestamp] = [NSString stringWithFormat:@"%.0f", self.firstVisitTimestamp];
    staticParameters[PiwikParameterPreviousVisitTimestamp] = [NSString stringWithFormat:@"%.0f", self.previousVisitTimestamp];
    
    // Set custom variables - platform, OS version and application version
    self.visitorCustomVariables = [NSMutableArray array];
    
    self.visitorCustomVariables[0] = customVariable(@"Platform", [self platformName]);
    
#if TARGET_OS_IPHONE
    self.visitorCustomVariables[1] = customVariable(@"OS version", [UIDevice currentDevice].systemVersion);
#else
    self.visitorCustomVariables[1] = customVariable(@"OS version", [[NSProcessInfo processInfo] operatingSystemVersionString]);
#endif
    
    self.visitorCustomVariables[2] = customVariable(@"App version", self.appVersion);
    staticParameters[PiwikParameterVisitScopeCustomVariables] = [PiwikTracker encodeCustomVariables:self.visitorCustomVariables];
    
    self.staticParameters = staticParameters;
  }
  
  // Join event parameters with static parameters
  NSMutableDictionary *joinedParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
  [joinedParameters addEntriesFromDictionary:self.staticParameters];
  
  if (self.sessionStart) {
    joinedParameters[PiwikParameterSessionStart] = @"1";
    self.sessionStart = NO;
  }
  
  // Add random number
  int randomNumber = arc4random_uniform(50000);
  joinedParameters[PiwikParameterRandomNumber] = [NSString stringWithFormat:@"%ld", (long)randomNumber];
  
  // Location
  if (self.includeLocationInformation && self.locationManager) {
    id<PTLocation> location = self.locationManager.location;
    if (location) {
      joinedParameters[PiwikParameterLatitude] = [NSNumber numberWithDouble:location.latitude];
      joinedParameters[PiwikParameterLongitude] = [NSNumber numberWithDouble:location.longitude];
    }
  }
  
  // Add local time
  NSCalendar *calendar = [NSCalendar currentCalendar];
  unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
  NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
  joinedParameters[PiwikParameterHours] = [NSString stringWithFormat:@"%ld", (long)[dateComponents hour]];
  joinedParameters[PiwikParameterMinutes] = [NSString stringWithFormat:@"%ld", (long)[dateComponents minute]];
  joinedParameters[PiwikParameterSeconds] = [NSString stringWithFormat:@"%ld", (long)[dateComponents second]];
    
  return joinedParameters;
}


// Encode a custom variable
inline NSString* customVariable(NSString* name, NSString* value) {
  return [NSString stringWithFormat:@"[\"%@\",\"%@\"]", name, value];
}
   

// Encode list of custom variables
+ (NSString*)encodeCustomVariables:(NSArray*)variables {
  
  NSMutableArray *encodedVariables = [NSMutableArray array];
  [variables enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [encodedVariables addObject:[NSString stringWithFormat:@"\"%ld\":%@", (long)idx + 1, obj]];
  }];
  
  return [NSString stringWithFormat:@"{%@}", [encodedVariables componentsJoinedByString:@","]];
}


// Queue event
- (BOOL)queueEvent:(NSDictionary*)parameters {
  
  // OptOut check
  if (self.optOut == YES) {
    // User opted out from tracking, to nothing
    // Still return YES, since returning NO is considered an error
    return YES;
  }
  
  // Use the sampling rate to decide if the event should be queued or not
  if (self.sampleRate != 100 && self.sampleRate < (arc4random_uniform(101))) {
    // Outsampled, do not queue
    return YES;
  }

  DLog(@"Store event with parameters %@", parameters);

  [self storeEventWithParameters:parameters completionBlock:^{
    
    if (self.dispatchInterval == 0) {
      // Trigger dispatch
      dispatch_async(dispatch_get_main_queue(), ^{
        [self dispatch];
      });
    }
    
  }];
  
  return YES;
}


// Dispatch notification
- (void)dispatch:(NSNotification*)notification {
  [self dispatch];
}


// Dispatch stored events
- (BOOL)dispatch {
  
  if (self.isDispatchRunning) {
    return YES;
  } else {
    self.isDispatchRunning = YES;
    [self sendEvent];
    return YES;
  }
  
}


- (void)sendEvent {

  NSUInteger numberOfEventsToSend = self.authenticationToken != nil && self.eventsPerRequest > 0 ? self.eventsPerRequest : 1;
  
  [self eventsFromStore:numberOfEventsToSend completionBlock:^(NSArray *entityIDs, NSArray *events, BOOL hasMore) {
    
    if (!events || events.count == 0) {
      
      // No pending events
      [self sendEventDidFinishHasMorePending:NO];
      
    } else {

      if (self.debug) {
        // Debug mode
              
        // Print the result to the console, format the URL for easy reading
        NSURLRequest *request = [self requestForEvents:events];
        NSMutableString *absoluteRequestURL = [NSMutableString stringWithString:[[request URL] absoluteString]];
                
        [absoluteRequestURL replaceOccurrencesOfString:@"?"
                                            withString:@"\n  "
                                               options:NSLiteralSearch
                                                 range:NSMakeRange(0, [absoluteRequestURL length])];
        [absoluteRequestURL replaceOccurrencesOfString:@"&"
                                            withString:@"\n  "
                                               options:NSLiteralSearch
                                                 range:NSMakeRange(0, [absoluteRequestURL length])];

        ALog(@"Debug Piwik request:\n%@", absoluteRequestURL);
        
        [self deleteEventsWithIDs:entityIDs];
        
        [self sendEventDidFinishHasMorePending:hasMore];
    
      } else {
        
        NSURLRequest *request = [self requestForEvents:events];
//        DLog(@"Request headers %@", request);
//        DLog(@"Request headers %@", [request allHTTPHeaderFields]);
//        
//        NSLocale *locale = [NSLocale currentLocale];
//        DLog(@"Language %@", [locale objectForKey:NSLocaleLanguageCode]);
//        DLog(@"Country %@", [locale objectForKey:NSLocaleCountryCode]);
        
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          DLog(@"Successfully sent stats to Piwik server");
          
          [self deleteEventsWithIDs:entityIDs];
          
          [self sendEventDidFinishHasMorePending:hasMore];
          
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

          ALog(@"Failed to send stats to Piwik server with reason : %@", error);
          
          if ([self shouldAbortdispatchForNetworkError:error]) {
            [self sendEventDidFinishHasMorePending:NO];
          } else {
            [self sendEventDidFinishHasMorePending:hasMore];
          }
          
          
        }];
        
        [self enqueueHTTPRequestOperation:operation];
        
      }
      
    }
    
  }];
  
}


- (NSMutableURLRequest*)requestForEvents:(NSArray*)events {
  
  NSMutableURLRequest *request = nil;
  
  if (events.count == 1) {
    
    // Send event as query string
    self.parameterEncoding = AFFormURLParameterEncoding;
    
    request = [self requestWithMethod:@"GET" path:@"piwik.php" parameters:[events objectAtIndex:0]];
    
  } else {
    
    // Send events as JSON
    // Authentication token is mandatory
    self.parameterEncoding = AFJSONParameterEncoding;
    
    NSMutableDictionary *JSONParams = [NSMutableDictionary dictionaryWithCapacity:2];
    JSONParams[@"token_auth"] = self.authenticationToken;
    
    NSMutableArray *queryStrings = [NSMutableArray arrayWithCapacity:events.count];
    for (NSDictionary *params in events) {
      NSString *queryString = [NSString stringWithFormat:@"?%@", AFQueryStringFromParametersWithEncoding(params, NSUTF8StringEncoding)];
      [queryStrings addObject:queryString];
    }
        
    JSONParams[@"requests"] = queryStrings;
    
    request = [self requestWithMethod:@"POST" path:@"piwik.php" parameters:JSONParams];
    
  }
  
  return request;
  
}


// Dispatch did dinish
- (void)sendEventDidFinishHasMorePending:(BOOL)hasMore {
 
  if (hasMore) {
    [self sendEvent];
  } else {
    
    self.isDispatchRunning = NO;
    
    [self startDispatchTimer];
    
  }

}


// Should the dispatch be aborted and pending events rescheduled
// Subclasses can overwrite too change behaviour
- (BOOL)shouldAbortdispatchForNetworkError:(NSError*)error {
  
  if (error.code == NSURLErrorBadURL ||
      error.code == NSURLErrorUnsupportedURL ||
      error.code == NSURLErrorCannotFindHost ||
      error.code == NSURLErrorCannotConnectToHost ||
      error.code == NSURLErrorDNSLookupFailed) {
    return YES;
  } else {
    return NO;
  }
  
}


// Delete all queued events
- (void)deleteQueuedEvents {
  [self deleteAllStoredEvents];
}


#pragma mark - Properties

// Set opt out
- (void)setOptOut:(BOOL)optOut {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setBool:optOut forKey:PiwikUserDefaultOptOutKey];
  [userDefaults synchronize];
}

// Get opt out
- (BOOL)optOut {
  return [[NSUserDefaults standardUserDefaults] boolForKey:PiwikUserDefaultOptOutKey];
}


// Dispatch interval
- (void)setDispatchInterval:(NSTimeInterval)interval {
  
  if (interval == 0) {
    // Trigger a dispatch
    [self dispatch];
  }
  
  _dispatchInterval = interval;
}


// Client id
- (NSString*)clientID {
  
  if (nil == _clientID) {
    
    // Get from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _clientID = [userDefaults stringForKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultVisitorIDKey)];
    
    if (!_clientID) {
      // Still nil, create
      
      // Get an UUID
      NSString *UUID = [PiwikTracker UUIDString];
      // md5 and max 16 chars
      _clientID = [[PiwikTracker md5:UUID] substringToIndex:16];
           
      [userDefaults setValue:_clientID forKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultVisitorIDKey)];
      [userDefaults synchronize];
    }
  }
  
  return _clientID;
}


inline NSString* userDefaultKeyWithSiteID(NSString *siteID, NSString *key) {
  return [NSString stringWithFormat:@"%@_%@", siteID, key];
}


- (void)setCurrentVisitTimestamp:(NSTimeInterval)currentVisitTimestamp {
    
  self.previousVisitTimestamp = _currentVisitTimestamp;
   
  _currentVisitTimestamp = currentVisitTimestamp;
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setDouble:_currentVisitTimestamp forKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultCurrentVisitTimestampKey)];
  [userDefaults synchronize];
}


- (NSTimeInterval)currentVisitTimestamp {
  
  if (_currentVisitTimestamp == 0) {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _currentVisitTimestamp = [userDefaults doubleForKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultCurrentVisitTimestampKey)];
    
    if (_currentVisitTimestamp == 0) {
      // If still no value, create one
      _currentVisitTimestamp = [[NSDate date] timeIntervalSince1970];
      [userDefaults setDouble:_currentVisitTimestamp  forKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultCurrentVisitTimestampKey)];
      [userDefaults synchronize];
    }
  }
  
  return _currentVisitTimestamp;
}


- (void)setPreviousVisitTimestamp:(NSTimeInterval)previousVisitTimestamp {
  
  _previousVisitTimestamp = previousVisitTimestamp;

  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setDouble:previousVisitTimestamp forKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultPreviousVistsTimestampKey)];
  [userDefaults synchronize]; 
}


- (NSTimeInterval)previousVisitTimestamp {
  
  if (_previousVisitTimestamp == 0) {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _previousVisitTimestamp = [userDefaults doubleForKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultPreviousVistsTimestampKey)];
    
    if (_previousVisitTimestamp == 0) {
      // If still no value, create one
      _previousVisitTimestamp = [[NSDate date] timeIntervalSince1970];
      [userDefaults setDouble:_previousVisitTimestamp  forKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultPreviousVistsTimestampKey)];
      [userDefaults synchronize];
    }

  }
  
  return _previousVisitTimestamp;
}


// First visit timestamp
- (NSTimeInterval)firstVisitTimestamp {
  
  if (_firstVisitTimestamp == 0) {
    
    // Get the value from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _firstVisitTimestamp = [userDefaults doubleForKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultFirstVistsTimestampKey)];
    
    if (_firstVisitTimestamp == 0) {
      // If still no value, create one
      _firstVisitTimestamp = [[NSDate date] timeIntervalSince1970];
      [userDefaults setDouble:_firstVisitTimestamp  forKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultFirstVistsTimestampKey)];
      [userDefaults synchronize];
    }
  }
  
  return _firstVisitTimestamp;
}


// Number of visits
- (void)setTotalNumberOfVisits:(NSUInteger)numberOfVisits {
  
  _totalNumberOfVisits = numberOfVisits;
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setInteger:numberOfVisits forKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultTotalNumberOfVisitsKey)];
  [userDefaults synchronize];
}

- (NSUInteger)totalNumberOfVisits {
  
  if (_totalNumberOfVisits <= 0) {
    // Read value from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _totalNumberOfVisits = [userDefaults integerForKey:userDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultTotalNumberOfVisitsKey)];
  }
  
  return _totalNumberOfVisits;
}



// App name
- (NSString*)appName {
  if (nil == _appName) {
    // Use the CFBundleName as default
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
  }
  
  return _appName;
}


// App version
- (NSString*)appVersion {
  if (nil == _appVersion) {
    // Use the CFBundleName as default
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
  }
  
  return _appVersion;
}


#pragma mark Help methods

// Create md5
+ (NSString*)md5:(NSString*)input {
  const char* str = [input UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, (CC_LONG)strlen(str), result);
  
  NSMutableString *hexString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
    [hexString appendFormat:@"%02x", result[i]];
  }
  
  return hexString;
}


// Create UUID
+ (NSString*)UUIDString {
  CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
  NSString *UUIDString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, UUID);
  CFRelease(UUID); // Need to release the UUID, the UUIDString ownership is transfered
  
  return UUIDString;
}


- (NSString*)platform {
  
  size_t size;
  sysctlbyname("hw.machine", NULL, &size, NULL, 0);
  char *machine = malloc(size * sizeof(char));
  sysctlbyname("hw.machine", machine, &size, NULL, 0);
  NSString *platform = [NSString stringWithUTF8String:machine];
  free(machine);
  
  return platform;
}


- (NSString*)platformName  {
  
  NSString *platform = [self platform];

  if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
  if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
  if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
  if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
  if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
  if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
  if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
  if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
  if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
  if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
  if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
  if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
  if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
  if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
  if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
  if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
  if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
  if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
  if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
  if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
  if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
  if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
  if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
  if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
  if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
  if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
  if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
  if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
  if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
  if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
  if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
  if ([platform isEqualToString:@"i386"])         return @"Simulator";
  if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
  
  return platform;
  
}


#pragma mark - core data methods

- (BOOL)storeEventWithParameters:(NSDictionary*)parameters completionBlock:(void (^)(void))completionBlock {
  
  [self.managedObjectContext performBlock:^{
    
    NSError *error;
    
    // Check if we reached the limit of the number of queued events
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTEventEntity"];
    NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    if (count < self.maxNumberOfQueuedEvents) {
      
      // Create new event entity
      PTEventEntity *eventEntity = [NSEntityDescription insertNewObjectForEntityForName:@"PTEventEntity" inManagedObjectContext:self.managedObjectContext];
      eventEntity.requestParameters = [NSKeyedArchiver archivedDataWithRootObject:parameters];
      
      [self.managedObjectContext save:&error];
      
    } else {
      ALog(@"Piwik tracker reach maximum number of queued events");
    }
    
    completionBlock();
    
  }];
  
  return YES;
}


- (void)eventsFromStore:(NSUInteger)numberOfEvents completionBlock:(void (^)(NSArray *entityIDs, NSArray *events, BOOL hasMore))completionBlock {
  
  [self.managedObjectContext performBlock:^{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTEventEntity"];
    
    // Oldest first
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];

    fetchRequest.fetchLimit = numberOfEvents + 1;
    
    NSError *error;
    NSArray *eventEntities = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSUInteger returnCount = eventEntities.count == fetchRequest.fetchLimit ? numberOfEvents : eventEntities.count;
    
    NSMutableArray *events = [NSMutableArray arrayWithCapacity:returnCount];
    NSMutableArray *entityIDs = [NSMutableArray arrayWithCapacity:returnCount];
    
    if (eventEntities && eventEntities.count > 0) {
      
      [eventEntities enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, returnCount)] options:0
        usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          
          PTEventEntity *eventEntity = (PTEventEntity*)obj;
          NSDictionary *parameters = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:eventEntity.requestParameters];
          
          [events addObject:parameters];
          [entityIDs addObject:eventEntity.objectID];
          
      }];
      
      completionBlock(entityIDs, events, eventEntities.count == fetchRequest.fetchLimit ? YES : NO);
      
    } else {
      // No more pending events
      completionBlock(nil, nil, NO);
    }
    
  }];
    
}


- (void)deleteEventsWithIDs:(NSArray*)entityIDs {

  [self.managedObjectContext performBlock:^{
    
    NSError *error;
    
    for (NSManagedObjectID *entityID in entityIDs) {
      
      PTEventEntity *event = (PTEventEntity*)[self.managedObjectContext existingObjectWithID:entityID error:&error];
      if (event) {
        [self.managedObjectContext deleteObject:event];
      }

    }
    
    [self.managedObjectContext save:&error];
    
  }];
  
}


- (void)deleteAllStoredEvents {
  
  [self.managedObjectContext performBlock:^{
    
    NSError *error;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTEventEntity"];

    NSArray *events = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];    
    for (NSManagedObject *event in events) {
      [self.managedObjectContext deleteObject:event];
    }
    
    [self.managedObjectContext save:&error];
    
  }];
  
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext*)managedObjectContext {
  
  if (_managedObjectContext) {
    return _managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator) {
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  
  return _managedObjectContext;
}


// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel*)managedObjectModel {
  
  if (_managedObjectModel) {
    return _managedObjectModel;
  }
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"piwiktracker" withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  return _managedObjectModel;
}


// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
  
  if (_persistentStoreCoordinator) {
    return _persistentStoreCoordinator;
  }
  
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"piwiktracker"];
  
  NSError *error = nil;
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    
    BOOL isMigrationError = [error code] == NSPersistentStoreIncompatibleVersionHashError || [error code] == NSMigrationMissingSourceModelError;
    
    if ([[error domain] isEqualToString:NSCocoaErrorDomain] && isMigrationError) {
      
      // Could not open the database, remote it ans try again
      [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
      
      ALog(@"Removed incompatible model version: %@", [storeURL lastPathComponent]);
      
      // Try one more time to create the store
      [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                configuration:nil
                                                          URL:storeURL
                                                      options:nil
                                                        error:&error];
      
      if (_persistentStoreCoordinator) {
        // If we successfully added a store, remove the error that was initially created
        error = nil;
      } else {
        // Not possible to recover of workaround
        ALog(@"Unresolved error when setting up code data stack %@, %@", error, [error userInfo]);
        abort();
      }
      
    }
    
  }
  
  return _persistentStoreCoordinator;
}


// Returns the URL to the application's Documents directory.
- (NSURL*)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
