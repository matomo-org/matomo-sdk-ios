//
//  PiwikTracker.m
//  PiwikTracker
//
//  Created by Mattias Levin on 3/12/13.
//  Copyright 2013 Mattias Levin. All rights reserved.
//

#import "PiwikTracker.h"
#import <CommonCrypto/CommonDigest.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#include <sys/sysctl.h>
#endif
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "PTEventEntity.h"


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

static NSUInteger const PiwikHTTPRequestTimeout = 5.0;


@interface PiwikTracker () <CLLocationManagerDelegate>

@property (nonatomic) NSUInteger totalNumberOfVisits;

@property (nonatomic, readonly) NSTimeInterval firstVisitTimestamp;
@property (nonatomic) NSTimeInterval previousVisitTimestamp;
@property (nonatomic) NSTimeInterval currentVisitTimestamp;
@property (nonatomic, strong) NSDate *appDidEnterBackgroundDate;

@property (nonatomic, strong) NSMutableArray *visitorCustomVariables;

@property (nonatomic, strong) NSDictionary *staticParameters;

@property (nonatomic, strong) NSTimer *dispatchTimer;
@property (nonatomic) BOOL isDispatchRunning;

@property (nonatomic, strong) CLLocationManager *locationManager;

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

- (void)startLocationManager;

- (BOOL)storeEventWithParameters:(NSDictionary*)parameters completionBlock:(void (^)(void))completionBlock;
- (void)eventsFromStore:(NSUInteger)numberOfEvents completionBlock:(void (^)(NSArray *entityIDs, NSArray *events, BOOL hasMore))completionBlock;
- (void)deleteEventsWithIDs:(NSArray*)entityIDs;

- (NSURL*)applicationDocumentsDirectory;

+ (NSString*)encodeCustomVariables:(NSArray*)variables;
+ (NSString*)md5:(NSString*)input;
+ (NSString*)UUIDString;

@end


// Function declaration
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
    ALog(@"Create new tracker with baseURL %@ and siteID %@", baseURL, siteID);
    
    // Initialize instance variables
    
    _authenticationToken = authenticationToken;
    _siteID = siteID;
    
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
    
    _includeLocationInformation = NO;
    
    // Set default user defatult values
    NSDictionary *defaultValues = @{PiwikUserDefaultOptOutKey : @NO};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];

#if TARGET_OS_IPHONE
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
#endif
    [self startDispatchTimer];
        
    return self;
  }
  else {
    return nil;
  }
}


// Overwritten from AFHTTPClient
- (NSMutableURLRequest*)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
  
  NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];

  // Reduce request time out
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
  
  // Start the location manager again if it exist
  if (self.locationManager) {
    [self.locationManager startMonitoringSignificantLocationChanges];
  }
  
  [self startDispatchTimer];  
}


- (void)appDidEnterBackground:(NSNotification*)notification {
  self.appDidEnterBackgroundDate = [NSDate date];
  
  // Stop the location manager if it exists
  if (self.locationManager) {
    [self.locationManager stopMonitoringSignificantLocationChanges];
  }
  
  [self stopDispatchTimer];
}


- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark Views and Events

// Send screen views
- (BOOL)sendView:(NSString*)screen {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:screen forKey:PiwikParameterActionName];
  
  // Setting the url is mandatory but not fully applicable in an application context
  // Set url by combining the app name and the screen name
  [params setObject:[NSString stringWithFormat:@"http://%@/%@", self.appName, screen] forKey:PiwikParameterURL];
  
  DLog(@"Send view %@", screen);
  
  return [self queueEvent:[self addCommonParameters:params]];
}


// Send screen views
// Piwik support screen names with / and will then group the screen views hierarchically
- (BOOL)sendViews:(NSString*)screen, ... {
  
  // Collect var args
  NSMutableArray *screens = [NSMutableArray array];
  va_list args;
  va_start(args, screen);
  for (NSString *arg = screen; arg != nil; arg = va_arg(args, NSString*))
  {
    [screens addObject:arg];
  }
  va_end(args);
  
  return [self sendView:[screens componentsJoinedByString:@"/"]];
}



// Track the event as hierarchical screen view
- (BOOL)sendEventWithCategory:(NSString*)category action:(NSString*)action label:(NSString*)label {
    
  // Combine category, action and lable into a screen name
  return [self sendView:[NSString stringWithFormat:@"%@/%@/%@", category, action, label]];
}


// Track goal conversion
- (BOOL)sendGoalWithID:(NSString*)goalID revenue:(NSUInteger)revenue {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:goalID forKey:PiwikParameterGoalID];
  [params setObject:[NSNumber numberWithInteger:revenue] forKey:PiwikParameterRevenue];
  
  // Setting the url is mandatory but not fully applicable in an application context
  [params setObject:[NSString stringWithFormat:@"http://%@", self.appName] forKey:PiwikParameterURL];

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
    
    [staticParameters setObject:self.siteID forKey:PiwikParameterSiteID];
    
    [staticParameters setObject:PiwikDefaultRecordValue forKey:PiwikParameterRecord];
    
    [staticParameters setObject:PiwikDefaultAPIVersionValue forKey:PiwikParameterAPIVersion];
    
    if (self.authenticationToken) {
      [staticParameters setObject:self.authenticationToken forKey:PiwikParameterAuthenticationToken];
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
    [staticParameters setObject:[NSString stringWithFormat:@"%.0fx%.0f", screenSize.width, screenSize.height]
                     forKey:PiwikParameterScreenReseloution];
    
    [staticParameters setObject:self.clientID forKey:PiwikParameterVisitorID];
    
    [staticParameters setObject:[NSString stringWithFormat:@"%ld", (unsigned long)self.totalNumberOfVisits] forKey:PiwikParameterTotalNumberOfVisits];
    
    // Timestamps
    [staticParameters setObject:[NSString stringWithFormat:@"%.0f", self.firstVisitTimestamp] forKey:PiwikParameterFirstVisitTimestamp];
    [staticParameters setObject:[NSString stringWithFormat:@"%.0f", self.previousVisitTimestamp] forKey:PiwikParameterPreviousVisitTimestamp];
    
    // Set custom variables - platform, OS version and application version
      self.visitorCustomVariables = [NSMutableArray array];
#if TARGET_OS_IPHONE
    UIDevice *device = [UIDevice currentDevice];
    [self.visitorCustomVariables insertObject:customVariable(@"Platform", device.model) atIndex:0];
    [self.visitorCustomVariables insertObject:customVariable(@"OS version", device.systemVersion) atIndex:1];
#else
    NSString *model;
    size_t length = 0;
    sysctlbyname("hw.model", NULL, &length, NULL, 0);
    if (length) {
        char *m = malloc(length * sizeof(char));
        sysctlbyname("hw.model", m, &length, NULL, 0);
        model = [NSString stringWithUTF8String:m];
        free(m);
    } else {
        model = @"Unknown";
    }
    [self.visitorCustomVariables insertObject:customVariable(@"Platform", model) atIndex:0];
    [self.visitorCustomVariables insertObject:customVariable(@"OS version", [[NSProcessInfo processInfo] operatingSystemVersionString]) atIndex:1];
#endif
    [self.visitorCustomVariables insertObject:customVariable(@"App version", self.appVersion) atIndex:2];
    [staticParameters setObject:[PiwikTracker encodeCustomVariables:self.visitorCustomVariables] forKey:PiwikParameterVisitScopeCustomVariables];
    
    // Location information
    if (self.includeLocationInformation && !self.locationManager) {
      [self startLocationManager];      
    }
    
    self.staticParameters = staticParameters;
  }
  
  // Join event parameters with static parameters
  NSMutableDictionary *joinedParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
  [joinedParameters addEntriesFromDictionary:self.staticParameters];
  
  if (self.sessionStart) {
    [joinedParameters setObject:@"1" forKey:PiwikParameterSessionStart];    
    self.sessionStart = NO;
  }
  
  // Add random number
  int randomNumber = arc4random_uniform(50000);
  [joinedParameters setObject:PiwikParameterRandomNumber forKey:[NSString stringWithFormat:@"%d", randomNumber]];
  
  // Location
  if (self.includeLocationInformation && self.locationManager) {
    CLLocation *location = self.locationManager.location;
    if (location) {
      [joinedParameters setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:PiwikParameterLatitude];
      [joinedParameters setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:PiwikParameterLongitude];
    }
  }
  
  // Add local time
  NSCalendar *calendar = [NSCalendar currentCalendar];
  unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
  NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
  [joinedParameters setObject:[NSString stringWithFormat:@"%ld", (long)[dateComponents hour]] forKey:PiwikParameterHours];
  [joinedParameters setObject:[NSString stringWithFormat:@"%ld", (long)[dateComponents minute]] forKey:PiwikParameterMinutes];
  [joinedParameters setObject:[NSString stringWithFormat:@"%ld", (long)[dateComponents second]] forKey:PiwikParameterSeconds];
    
  return joinedParameters;
}


- (void)startLocationManager {
  
  if (!self.locationManager && [CLLocationManager locationServicesEnabled] &&
      [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted &&
      [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
    self.locationManager = [[CLLocationManager alloc] init];
  }
  
  self.locationManager.delegate = self;
  
  [self.locationManager startMonitoringSignificantLocationChanges];  
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
        //DLog(@"Request headers %@", request);
        //DLog(@"Request headers %@", [request allHTTPHeaderFields]);
        
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
    [JSONParams setObject:self.authenticationToken forKey:@"token_auth"];
    
    NSMutableArray *queryStrings = [NSMutableArray arrayWithCapacity:events.count];
    for (NSDictionary *params in events) {
      NSString *queryString = [NSString stringWithFormat:@"?%@", AFQueryStringFromParametersWithEncoding(params, NSUTF8StringEncoding)];
      [queryStrings addObject:queryString];
    }
        
    [JSONParams setObject:queryStrings forKey:@"requests"];
    
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
    
    if (nil == _clientID) {
      // Still nil, create
      
      // Get an UUID
      NSString *UUID = [PiwikTracker UUIDString];
      // md5 and max 16 chars
      _clientID = [[PiwikTracker md5:UUID] substringToIndex:15];
      
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
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
  }
  
  return _appName;
}


// App version
- (NSString*)appVersion {
  if (nil == _appVersion) {
    // Use the CFBundleName as default
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
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


#pragma mark - core location delegate methods

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray*)locations {
  // Do nothing
}


- (void)locationManager:(CLLocationManager*)manager monitoringDidFailForRegion:(CLRegion*)region withError:(NSError*)error {
  // Do nothing
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
