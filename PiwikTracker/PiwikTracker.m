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

#import "PiwikTransaction.h"
#import "PiwikTransactionItem.h"
#import "PTEventEntity.h"
#import "PiwikLocationManager.h"

#import "PiwikDispatcher.h"
#import "PiwikNSURLSessionDispatcher.h"

#include <sys/types.h>
#include <sys/sysctl.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif


#pragma mark - Constants

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
static NSString * const PiwikParameterScreenScopeCustomVariables = @"cvar";
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
// Ecommerce
static NSString * const PiwikParameterTransactionIdentifier = @"ec_id";
static NSString * const PiwikParameterTransactionSubTotal = @"ec_st";
static NSString * const PiwikParameterTransactionTax = @"ec_tx";
static NSString * const PiwikParameterTransactionShipping = @"ec_sh";
static NSString * const PiwikParameterTransactionDiscount = @"ec_dt";
static NSString * const PiwikParameterTransactionItems = @"ec_items";
// Campaign
static NSString * const PiwikParameterReferrer = @"urlref";
static NSString * const PiwikParameterCampaignName = @"_rcn";
static NSString * const PiwikParameterCampaignKeyword = @"_rck";
// Events
static NSString * const PiwikParameterEventCategory = @"e_c";
static NSString * const PiwikParameterEventAction = @"e_a";
static NSString * const PiwikParameterEventName = @"e_n";
static NSString * const PiwikParameterEventValue = @"e_v";

// Piwik default parmeter values
static NSString * const PiwikDefaultRecordValue = @"1";
static NSString * const PiwikDefaultAPIVersionValue = @"1";

/*
// Custom variables
static NSUInteger const PiwikCustomVariablesMaxNumber = 5;
static NSUInteger const PiwikCustomVariablesMaxNameLength = 20;
static NSUInteger const PiwikCustomVariablesMaxValueLengt = 100;
 */

// Default values
static NSUInteger const PiwikDefaultSessionTimeout = 120;
static NSUInteger const PiwikDefaultDispatchTimer = 120;
static NSUInteger const PiwikDefaultMaxNumberOfStoredEvents = 500;
static NSUInteger const PiwikDefaultSampleRate = 100;
static NSUInteger const PiwikDefaultNumberOfEventsPerRequest = 20;

static NSUInteger const PiwikExceptionDescriptionMaximumLength = 50;

// Page view prefix values
static NSString * const PiwikPrefixView = @"screen";
static NSString * const PiwikPrefixEvent = @"event";
static NSString * const PiwikPrefixException = @"exception";
static NSString * const PiwikPrefixExceptionFatal = @"fatal";
static NSString * const PiwikPrefixExceptionCaught = @"caught";
static NSString * const PiwikPrefixSocial = @"social";

// Incoming campaign URL parameters
static NSString * const PiwikURLCampaignName = @"pk_campaign";
static NSString * const PiwikURLCampaignKeyword = @"pk_kwd";


#pragma mark - Custom variable

@interface CustomVariable : NSObject

@property (nonatomic) NSUInteger index;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;

- (id)initWithIndex:(NSUInteger)index name:(NSString*)name value:(NSString*)value;

@end


@implementation CustomVariable

- (id)initWithIndex:(NSUInteger)index name:(NSString*)name value:(NSString*)value {
  self = [super init];
  if (self) {
    _index = index;
    _name = name;
    _value = value;
  }
  return self;
}

@end


#pragma mark - Pwik tracker

@interface PiwikTracker ()

@property (nonatomic) NSUInteger totalNumberOfVisits;

@property (nonatomic, readonly) NSTimeInterval firstVisitTimestamp;
@property (nonatomic) NSTimeInterval previousVisitTimestamp;
@property (nonatomic) NSTimeInterval currentVisitTimestamp;
@property (nonatomic, strong) NSDate *appDidEnterBackgroundDate;

@property (nonatomic, strong) NSMutableDictionary *screenCustomVariables;
@property (nonatomic, strong) NSMutableDictionary *visitCustomVariables;
@property (nonatomic, strong) NSDictionary *sessionParameters;
@property (nonatomic, strong) NSDictionary *staticParameters;
@property (nonatomic, strong) NSDictionary *campaignParameters;

@property (nonatomic, strong) id<PiwikDispatcher> dispatcher;
@property (nonatomic, strong) NSTimer *dispatchTimer;
@property (nonatomic) BOOL isDispatchRunning;

@property (nonatomic, strong) PiwikLocationManager *locationManager;

@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


//NSString* customVariable(NSString* name, NSString* value);
NSString* UserDefaultKeyWithSiteID(NSString* siteID, NSString *key);


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


- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (instancetype)sharedInstanceWithSiteID:(NSString*)siteID baseURL:(NSURL*)baseURL  {
  return [self sharedInstanceWithSiteID:(NSString*)siteID baseURL:baseURL authenticationToken:nil];
}


+ (instancetype)sharedInstanceWithSiteID:(NSString*)siteID
                                 baseURL:(NSURL*)baseURL
                     authenticationToken:(NSString*)authenticationToken {
  
  // Make sure the base url is correct
  NSString *lastPathComponent = [baseURL lastPathComponent];
  if ([lastPathComponent isEqualToString:@"piwik.php"] && [lastPathComponent isEqualToString:@"piwik-proxy.php"]) {
    baseURL = [baseURL URLByDeletingLastPathComponent];
  }
  
  return [self sharedInstanceWithSiteID:siteID authenticationToken:authenticationToken dispatcher:[self defaultDispatcherWithPiwikURL:baseURL]];
}


+ (id<PiwikDispatcher>)defaultDispatcherWithPiwikURL:(NSURL*)piwikURL {
  
  NSURL *endpoint = [[NSURL alloc] initWithString:@"piwik.php" relativeToURL:piwikURL];
  
  // Instantiate dispatchers in priority order
  if (NSClassFromString(@"PiwikAFNetworking2Dispather")) {
    return [[NSClassFromString(@"PiwikAFNetworking2Dispather") alloc] initWithPiwikURL:endpoint];
  } else if (NSClassFromString(@"PiwikAFNetworking1Dispather")) {
    return [[NSClassFromString(@"PiwikAFNetworking1Dispather") alloc] initWithPiwikURL:endpoint];
  } else {
    return [[PiwikNSURLSessionDispatcher alloc] initWithPiwikURL:endpoint];
  }
  
}


+ (instancetype)sharedInstanceWithSiteID:(NSString*)siteID
                     authenticationToken:(NSString*)authenticationToken
                              dispatcher:(id<PiwikDispatcher>)dispatcher {
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[PiwikTracker alloc] initWithSiteID:siteID authenticationToken:authenticationToken dispatcher:dispatcher];
  });
  
  return _sharedInstance;
  
}


+ (instancetype)sharedInstance {
  
  if (!_sharedInstance) {
    NSLog(@"Piwik tracker must first be initialized using sharedInstanceWithBaseURL:siteID:authenticationToken:");
    return nil;
  } else {
    return _sharedInstance;
  }

}


// TODO The authenticationToken parameter will be removed sometime on the future.
- (id)initWithSiteID:(NSString*)siteID authenticationToken:(NSString*)authenticationToken dispatcher:(id<PiwikDispatcher>)dispatcher {
  
  if (self = [super init]) {
    
    // Initialize instance variables
    _siteID = siteID;
    _authenticationToken = authenticationToken;
    _dispatcher = dispatcher;
    
    _isPrefixingEnabled = YES;
    
    _sessionTimeout = PiwikDefaultSessionTimeout;
    
    _sampleRate = PiwikDefaultSampleRate;
    
    // By default a new session will be started when the tracker is created
    _sessionStart = YES;
    
    _includeDefaultCustomVariable = YES;
    
    _dispatchInterval = PiwikDefaultDispatchTimer;
    _maxNumberOfQueuedEvents = PiwikDefaultMaxNumberOfStoredEvents;
    _isDispatchRunning = NO;
    
    // Piwik server does not require authentication token after release 2.2.1 to send bulk requests
    // TODO Change to bulk requests by default in the future.
    // Bulk tracking require authentication token
    if (_authenticationToken) {
      _eventsPerRequest = PiwikDefaultNumberOfEventsPerRequest;
    } else {
      _eventsPerRequest = 1;
    }
    
    _locationManager = [[PiwikLocationManager alloc] init];
    _includeLocationInformation = NO;
    
    // Set default user defatult values
    NSDictionary *defaultValues = @{PiwikUserDefaultOptOutKey : @NO};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    
    NSLog(@"Piwik Tracker created with siteID %@", siteID);
    
    if (self.optOut) {
      NSLog(@"Piwik Tracker user optout from tracking");
    }
    
    if (_debug) {
      NSLog(@"Piwik Tracker in debug mode, nothing will be sent to the server");
    }
    
    [self startDispatchTimer];
    
#if TARGET_OS_IPHONE
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
#endif
    
    return self;
  }
  else {
    return nil;
  }

}


- (void)startDispatchTimer {
  
  // Run on main thread run loop
  __weak typeof(self)weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    
    [weakSelf stopDispatchTimer];
    
    // If dispatch interval is < 0, manual dispatch must be used
    // If dispatch internal is = 0, the event is dispatched automatically directly after the event is tracked
    if (weakSelf.dispatchInterval > 0) {
      
      // Run on timer
      weakSelf.dispatchTimer = [NSTimer scheduledTimerWithTimeInterval:weakSelf.dispatchInterval
                                                                target:weakSelf
                                                              selector:@selector(dispatch:)
                                                              userInfo:nil
                                                               repeats:NO];
      
      NSLog(@"Dispatch timer started with interval %f", weakSelf.dispatchInterval);
      
    }
    
  });
  
}


- (void)stopDispatchTimer {
  
  if (self.dispatchTimer) {
    [self.dispatchTimer invalidate];
    self.dispatchTimer = nil;
    
    NSLog(@"Dispatch timer stopped");
  }
  
}


- (void)appDidBecomeActive:(NSNotification*)notification {
  
  if (!self.appDidEnterBackgroundDate) {
    // Cold start, init have already configured and started any services needed
    return;
  }

  // Create new session?
  if (labs([self.appDidEnterBackgroundDate timeIntervalSinceNow]) >= self.sessionTimeout) {
    self.sessionStart = YES;
  }
  
  if (self.includeLocationInformation) {
    [self.locationManager startMonitoringLocationChanges];
  }
  
  [self startDispatchTimer];  
}


- (void)appDidEnterBackground:(NSNotification*)notification {
  self.appDidEnterBackgroundDate = [NSDate date];
  
  if (self.includeLocationInformation) {
    [self.locationManager stopMonitoringLocationChanges];
  }
  
  [self stopDispatchTimer];
}


#pragma mark Views and Events

- (BOOL)sendView:(NSString*)screen {
  return [self sendViews:screen, nil];
}


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


- (BOOL)sendEventWithCategory:(NSString*)category action:(NSString*)action label:(NSString*)label {
  return [self sendEventWithCategory:category action:action name:label value:nil];
}


- (BOOL)sendEventWithCategory:(NSString*)category action:(NSString*)action name:(NSString*)name value:(NSNumber*)value {
  
#ifdef PIWIK_LEGACY_EVENT_ENCODING
  
  // Legacy event encoding (<2.3)
  // Track the event as a screen view by combining category, action and event into a screen name
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
    [components addObject:name];
  }
  
  return [self send:components];
  
#else
  
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  
  params[PiwikParameterEventCategory] = category;
  params[PiwikParameterEventAction] = action;
  if (name) {
    params[PiwikParameterEventName] = name;
  }
  if (value) {
    params[PiwikParameterEventValue] = value;
  }
  
  return [self queueEvent:params];
  
#endif
  
}


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


- (BOOL)send:(NSArray*)components {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  NSString *actionName = [components componentsJoinedByString:@"/"];
  params[PiwikParameterActionName] = actionName;
  
  // Setting the url is mandatory but not fully applicable in an application context
  // Set url by using the action name
  params[PiwikParameterURL] = [NSString stringWithFormat:@"http://%@/%@", self.appName, actionName];
  
  //NSLog(@"Send page view %@", actionName);
  
  return [self queueEvent:params];
}


- (BOOL)sendGoalWithID:(NSUInteger)goalID revenue:(NSUInteger)revenue {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  params[PiwikParameterGoalID] = @(goalID);
  params[PiwikParameterRevenue] = @(revenue);
  
  // Setting the url is mandatory but not fully applicable in an application context
  params[PiwikParameterURL] = [NSString stringWithFormat:@"http://%@", self.appName];

  return [self queueEvent:params];
}


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
  
  return [self queueEvent:params];
}


- (BOOL)sendTransaction:(PiwikTransaction*)transaction {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  params[PiwikParameterTransactionIdentifier] = transaction.identifier;
  // Must idgoal=0 or revenue parameter will be ignored
  params[PiwikParameterGoalID] = @(0);
  params[PiwikParameterRevenue] = transaction.grandTotal;
  if (transaction.subTotal) {
    params[PiwikParameterTransactionSubTotal] = transaction.subTotal;
  }
  if (transaction.tax) {
    params[PiwikParameterTransactionTax] = transaction.tax;
  }
  if (transaction.shippingCost) {
    params[PiwikParameterTransactionShipping] = transaction.shippingCost;
  }
  if (transaction.discount) {
    params[PiwikParameterTransactionDiscount] = transaction.discount;
  }
  if (transaction.items.count > 0) {
    // Items should be a JSON encoded string
    params[PiwikParameterTransactionItems] = [self JSONEncodeTransactionItems:transaction.items];
  }
  
  return [self queueEvent:params];
}


- (NSString*)JSONEncodeTransactionItems:(NSArray*)items {
  
  NSMutableArray *JSONObject = [NSMutableArray arrayWithCapacity:items.count];
  for (PiwikTransactionItem *item in items) {
    // The order of the properties are important
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    if (item.sku) {
      [itemArray addObject:item.sku];
    }
    if (item.name) {
      [itemArray addObject:item.name];
    }
    if (item.category) {
      [itemArray addObject:item.category];
    }
    if (item.price) {
      [itemArray addObject:item.price];
    }
    if (item.quantity) {
      [itemArray addObject:item.quantity];
    }

    [JSONObject addObject:itemArray];
  }
  
  NSError *error;
  NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:&error];
  
  return [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
  
}


- (BOOL)sendCampaign:(NSString*)campaignURLString {
  
  NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
  BOOL isCampaignURL = NO;
  
  NSArray *components = [campaignURLString componentsSeparatedByString:@"?"];
  if (components.count == 2) {
    
    NSArray *nameValueStrings = [components[1] componentsSeparatedByString:@"&"];
    for (NSString *nameValueString in nameValueStrings) {
      NSArray *parts = [nameValueString componentsSeparatedByString:@"="];
      if (parts.count == 2) {
        if ([parts[0] isEqualToString:PiwikURLCampaignName]) {
          isCampaignURL = YES;
          parameters[PiwikParameterCampaignName] = [parts[1] copy];
        } else if ([parts[0] isEqualToString:PiwikURLCampaignKeyword]) {
          parameters[PiwikParameterCampaignKeyword] = [parts[1] copy];
        }
      }
    }
    
  }
  
  if (isCampaignURL) {
    parameters[PiwikParameterReferrer] = campaignURLString;
    self.campaignParameters = [NSDictionary dictionaryWithDictionary:parameters];
    return YES;
  } else {
    return NO;
    
  }
}


- (BOOL)setCustomVariableForIndex:(NSUInteger)index name:(NSString*)name value:(NSString*)value scope:(CustomVariableScope)scope {
  
  NSParameterAssert(index > 0);
  NSParameterAssert(name);
  NSParameterAssert(value);
  
  if (index < 1) {
    NSLog(@"Custom variable index must be > 0");
    return NO;
  } else if (scope == VisitCustomVariableScope && self.includeDefaultCustomVariable && index <= 3) {
    NSLog(@"Custom variable index conflicting with default indexes used by the SDK. Change index or turn off default default variables");
    return NO;
  }
  
  CustomVariable *customVariable = [[CustomVariable alloc] initWithIndex:index name:name value:value];
  
  if (scope == VisitCustomVariableScope) {
    
    if (!self.visitCustomVariables) {
      self.visitCustomVariables = [NSMutableDictionary dictionary];
    }
    self.visitCustomVariables[@(index)] = customVariable;
    
    // Force generation of session parameters
    self.sessionParameters = nil;
    
  } else if (scope == ScreenCustomVariableScope) {
    
    if (!self.screenCustomVariables) {
      self.screenCustomVariables = [NSMutableDictionary dictionary];
    }
    self.screenCustomVariables[@(index)] = customVariable;
    
  }
  
  return YES;
}


- (BOOL)queueEvent:(NSDictionary*)parameters {
  
  // OptOut check
  if (self.optOut) {
    // User opted out from tracking, to nothing
    // Still return YES, since returning NO is considered an error
    return YES;
  }
  
  // Use the sampling rate to decide if the event should be queued or not
  if (self.sampleRate != 100 && self.sampleRate < (arc4random_uniform(101))) {
    // Outsampled, do not queue
    return YES;
  }
  
  parameters = [self addPerRequestParameters:parameters];
  parameters = [self addSessionParameters:parameters];
  parameters = [self addStaticParameters:parameters];
  
  NSLog(@"Store event with parameters %@", parameters);
  
  [self storeEventWithParameters:parameters completionBlock:^{
    
    if (self.dispatchInterval == 0) {
      // Trigger dispatch
      __weak typeof(self)weakSelf = self;
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf dispatch];
      });
    }
    
  }];
  
  return YES;
}


- (NSDictionary*)addPerRequestParameters:(NSDictionary*)parameters {
  
  NSMutableDictionary *joinedParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
  
  // Custom parameters
  if (self.screenCustomVariables) {
    joinedParameters[PiwikParameterScreenScopeCustomVariables] = [PiwikTracker JSONEncodeCustomVariables:self.screenCustomVariables];
    self.screenCustomVariables = nil;
  }
  
  // Add campaign parameters if they are set
  if (self.campaignParameters.count > 0) {
    [joinedParameters addEntriesFromDictionary:self.campaignParameters];
    self.campaignParameters = nil;
  }
  
  // Add random number (cache buster)
  int randomNumber = arc4random_uniform(50000);
  joinedParameters[PiwikParameterRandomNumber] = [NSString stringWithFormat:@"%ld", (long)randomNumber];
  
  // Location
  if (self.includeLocationInformation) {
    // The first request for location will ask the user for permission
    CLLocation *location = self.locationManager.location;
    if (location) {
      joinedParameters[PiwikParameterLatitude] = @(location.coordinate.latitude);
      joinedParameters[PiwikParameterLongitude] = @(location.coordinate.longitude);
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


- (NSDictionary*)addSessionParameters:(NSDictionary*)parameters {
  
  if (self.sessionStart) {
    
    self.totalNumberOfVisits = self.totalNumberOfVisits + 1;
    self.currentVisitTimestamp = [[NSDate date] timeIntervalSince1970];
    
    // Reset session params and visit custom variables to force a rebuild
    self.sessionParameters = nil;
    self.visitCustomVariables = nil;
  }
  
  if (!self.sessionParameters) {
    NSMutableDictionary *sessionParameters = [NSMutableDictionary dictionary];
    
    sessionParameters[PiwikParameterTotalNumberOfVisits] = [NSString stringWithFormat:@"%ld", (unsigned long)self.totalNumberOfVisits];
    
    sessionParameters[PiwikParameterPreviousVisitTimestamp] = [NSString stringWithFormat:@"%.0f", self.previousVisitTimestamp];
    
    if (self.visitCustomVariables) {
      sessionParameters[PiwikParameterVisitScopeCustomVariables] = [PiwikTracker JSONEncodeCustomVariables:self.visitCustomVariables];
    }
    
    self.sessionParameters = sessionParameters;
  }
  
  // Join event parameters with session parameters
  NSMutableDictionary *joinedParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
  [joinedParameters addEntriesFromDictionary:self.sessionParameters];
  
  if (self.sessionStart) {
    joinedParameters[PiwikParameterSessionStart] = @"1";
    self.sessionStart = NO;
  }
  
  return joinedParameters;
}


- (NSMutableDictionary*)visitCustomVariables {
  
  if (self.includeDefaultCustomVariable) {
    
    if (!_visitCustomVariables) {
      _visitCustomVariables = [NSMutableDictionary dictionary];
    }
    
    // Set custom variables - platform, OS version and application version
    
    _visitCustomVariables[@(0)] = [[CustomVariable alloc] initWithIndex:1 name:@"Platform" value:self.platformName];
    
#if TARGET_OS_IPHONE
    _visitCustomVariables[@(1)] = [[CustomVariable alloc] initWithIndex:2 name:@"OS version" value:[UIDevice currentDevice].systemVersion];
#else
    _visitCustomVariables[@(1)] = [[CustomVariable alloc] initWithIndex:2 name:@"OS version" value:[NSProcessInfo processInfo].operatingSystemVersionString];
#endif
    
    _visitCustomVariables[@(2)] = [[CustomVariable alloc] initWithIndex:3 name:@"App version" value:self.appVersion];
  }

  return _visitCustomVariables;
}

   
- (NSDictionary*)addStaticParameters:(NSDictionary*)parameters {
  
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
    
    // Timestamps
    staticParameters[PiwikParameterFirstVisitTimestamp] = [NSString stringWithFormat:@"%.0f", self.firstVisitTimestamp];
    
    self.staticParameters = staticParameters;
  }
  
  // Join event parameters with static parameters
  NSMutableDictionary *joinedParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
  [joinedParameters addEntriesFromDictionary:self.staticParameters];
    
  return joinedParameters;
}


+ (NSString*)JSONEncodeCustomVariables:(NSDictionary*)variables {
  
  // Travers all custom variables and create a JSON object that be be serialized
  NSMutableDictionary *JSONObject = [NSMutableDictionary dictionaryWithCapacity:variables.count];
  for (CustomVariable *customVariable in [variables objectEnumerator]) {
        JSONObject[[NSString stringWithFormat:@"%ld", (long)customVariable.index]] = [NSArray arrayWithObjects:customVariable.name, customVariable.value, nil];
  }
  
  NSError *error;
  NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:&error];
  
  return [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
}


- (void)dispatch:(NSNotification*)notification {
  [self dispatch];
}


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

  NSUInteger numberOfEventsToSend = self.authenticationToken && self.eventsPerRequest > 0 ? self.eventsPerRequest : 1;
  
  [self eventsFromStore:numberOfEventsToSend completionBlock:^(NSArray *entityIDs, NSArray *events, BOOL hasMore) {
    
    if (!events || events.count == 0) {
      
      // No pending events
      [self sendEventDidFinishHasMorePending:NO];
      
    } else {
      
      NSDictionary *requestParameters = [self requestParametersForEvents:events];
  
      __weak typeof(self)weakSelf = self;
      void (^successBlock)(void) = ^ () {
        [weakSelf deleteEventsWithIDs:entityIDs];
        [weakSelf sendEventDidFinishHasMorePending:hasMore];
      };
      
      void (^failureBlock)(BOOL shouldContinue) = ^ (BOOL shouldContinue) {
        NSLog(@"Failed to send stats to Piwik server");
        
        if (shouldContinue) {
          [weakSelf sendEventDidFinishHasMorePending:hasMore];
        } else {
          [weakSelf sendEventDidFinishHasMorePending:NO];
        }
        
      };
      
      if (events.count == 1) {
        [self.dispatcher sendSingleEventWithParameters:requestParameters success:successBlock failure:failureBlock];
      } else {
        [self.dispatcher sendBulkEventWithParameters:requestParameters success:successBlock failure:failureBlock];
      }
      
    }
    
  }];
  
}


- (NSDictionary*)requestParametersForEvents:(NSArray*)events {
  
  if (events.count == 1) {
    
    // Send events as query parameters
    return [events objectAtIndex:0];
    
  } else {
    
    // Send events as JSON encoded post body    
    NSMutableDictionary *JSONParams = [NSMutableDictionary dictionaryWithCapacity:2];
    
    // Authentication token is no longer needed in bulk requests starting Piwik 2.2.1
    JSONParams[@"token_auth"] = self.authenticationToken;
    
    // Piwik server will process each record in the batch request in reverse order, not sure if this is a bug
    // Build the request in revers order
    NSEnumerationOptions enumerationOption = NSEnumerationReverse;
  
    NSMutableArray *queryStrings = [NSMutableArray arrayWithCapacity:events.count];
    [events enumerateObjectsWithOptions:enumerationOption usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      
      NSDictionary *params = (NSDictionary*)obj;
      
#ifdef PIWIK1_X_BULK_ENCODING
      
      // Piwik 1.x require the paramers to be url encoded in the request body
      NSString *queryString = [NSString stringWithFormat:@"?%@", AFQueryStringFromParametersWithEncoding(params, NSUTF8StringEncoding)];
      
#else
      
      // As of Piwik 2.0 the query string should not be url encoded in the request body
      // Unfortenatly the AFNetworking methods for create parameter pairs are not external
      NSMutableArray *parameterPair = [NSMutableArray arrayWithCapacity:params.count];
      [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [parameterPair addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
      }];
      
      NSString *queryString = [NSString stringWithFormat:@"?%@", [parameterPair componentsJoinedByString:@"&"]];
      
#endif
  
      [queryStrings addObject:queryString];
      
    }];
        
    JSONParams[@"requests"] = queryStrings;
//    DLog(@"Bulk request:\n%@", JSONParams);
    
    return JSONParams;
    
  }
  
}


- (void)sendEventDidFinishHasMorePending:(BOOL)hasMore {
 
  if (hasMore) {
    [self sendEvent];
  } else {
    self.isDispatchRunning = NO;
    [self startDispatchTimer];
  }

}


- (void)deleteQueuedEvents {
  [self deleteAllStoredEvents];
}


#pragma mark - Properties


- (void)setIncludeLocationInformation:(BOOL)includeLocationInformation {
  _includeLocationInformation = includeLocationInformation;
  
  if (_includeLocationInformation) {
    [self.locationManager startMonitoringLocationChanges];
  } else {
    [self.locationManager stopMonitoringLocationChanges];
  }
  
}


- (void)setDebug:(BOOL)debug {
  
  if (debug && !_debug) {
    PiwikDebugDispatcher *debugDispatcher = [[PiwikDebugDispatcher alloc] init];
    debugDispatcher.wrappedDispatcher = self.dispatcher;
    self.dispatcher = debugDispatcher;
  } else if (!debug && [self.dispatcher isKindOfClass:[PiwikDebugDispatcher class]]) {
    self.dispatcher = ((PiwikDebugDispatcher*)self.dispatcher).wrappedDispatcher;
  }
  
  _debug = debug;
}


- (void)setOptOut:(BOOL)optOut {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setBool:optOut forKey:PiwikUserDefaultOptOutKey];
  [userDefaults synchronize];
}


- (BOOL)optOut {
  return [[NSUserDefaults standardUserDefaults] boolForKey:PiwikUserDefaultOptOutKey];
}


- (void)setDispatchInterval:(NSTimeInterval)interval {
  
  if (interval == 0) {
    // Trigger a dispatch
    [self dispatch];
  }
  
  _dispatchInterval = interval;
}


- (NSString*)clientID {
  
  if (nil == _clientID) {
    
    // Get from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _clientID = [userDefaults stringForKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultVisitorIDKey)];
    
    if (!_clientID) {
      // Still nil, create
      
      // Get an UUID
      NSString *UUID = [PiwikTracker UUIDString];
      // md5 and max 16 chars
      _clientID = [[PiwikTracker md5:UUID] substringToIndex:16];
           
      [userDefaults setValue:_clientID forKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultVisitorIDKey)];
      [userDefaults synchronize];
    }
  }
  
  return _clientID;
}


inline NSString* UserDefaultKeyWithSiteID(NSString *siteID, NSString *key) {
  return [NSString stringWithFormat:@"%@_%@", siteID, key];
}


- (void)setCurrentVisitTimestamp:(NSTimeInterval)currentVisitTimestamp {
    
  self.previousVisitTimestamp = _currentVisitTimestamp;
   
  _currentVisitTimestamp = currentVisitTimestamp;
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setDouble:_currentVisitTimestamp forKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultCurrentVisitTimestampKey)];
  [userDefaults synchronize];
}


- (NSTimeInterval)currentVisitTimestamp {
  
  if (_currentVisitTimestamp == 0) {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _currentVisitTimestamp = [userDefaults doubleForKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultCurrentVisitTimestampKey)];
    
    if (_currentVisitTimestamp == 0) {
      // If still no value, create one
      _currentVisitTimestamp = [[NSDate date] timeIntervalSince1970];
      [userDefaults setDouble:_currentVisitTimestamp  forKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultCurrentVisitTimestampKey)];
      [userDefaults synchronize];
    }
  }
  
  return _currentVisitTimestamp;
}


- (void)setPreviousVisitTimestamp:(NSTimeInterval)previousVisitTimestamp {
  
  _previousVisitTimestamp = previousVisitTimestamp;

  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setDouble:previousVisitTimestamp forKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultPreviousVistsTimestampKey)];
  [userDefaults synchronize]; 
}


- (NSTimeInterval)previousVisitTimestamp {
  
  if (_previousVisitTimestamp == 0) {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _previousVisitTimestamp = [userDefaults doubleForKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultPreviousVistsTimestampKey)];
    
    if (_previousVisitTimestamp == 0) {
      // If still no value, create one
      _previousVisitTimestamp = [[NSDate date] timeIntervalSince1970];
      [userDefaults setDouble:_previousVisitTimestamp  forKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultPreviousVistsTimestampKey)];
      [userDefaults synchronize];
    }

  }
  
  return _previousVisitTimestamp;
}


- (NSTimeInterval)firstVisitTimestamp {
  
  if (_firstVisitTimestamp == 0) {
    
    // Get the value from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _firstVisitTimestamp = [userDefaults doubleForKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultFirstVistsTimestampKey)];
    
    if (_firstVisitTimestamp == 0) {
      // If still no value, create one
      _firstVisitTimestamp = [[NSDate date] timeIntervalSince1970];
      [userDefaults setDouble:_firstVisitTimestamp  forKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultFirstVistsTimestampKey)];
      [userDefaults synchronize];
    }
  }
  
  return _firstVisitTimestamp;
}


- (void)setTotalNumberOfVisits:(NSUInteger)numberOfVisits {
  
  _totalNumberOfVisits = numberOfVisits;
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setInteger:numberOfVisits forKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultTotalNumberOfVisitsKey)];
  [userDefaults synchronize];
}

- (NSUInteger)totalNumberOfVisits {
  
  if (_totalNumberOfVisits <= 0) {
    // Read value from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _totalNumberOfVisits = [userDefaults integerForKey:UserDefaultKeyWithSiteID(self.siteID, PiwikUserDefaultTotalNumberOfVisitsKey)];
  }
  
  return _totalNumberOfVisits;
}



- (NSString*)appName {
  if (!_appName) {
    // Use the CFBundleDispayName and CFBundleName as default
    _appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    if (!_appName) {
      _appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    }
  }
  
  return _appName;
}


- (NSString*)appVersion {
  if (!_appVersion) {
    // Use the CFBundleVersion as default
    _appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
  }
  
  return _appVersion;
}


#pragma mark - Help methods

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


#pragma mark - Core data methods

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
      NSLog(@"Piwik tracker reach maximum number of queued events");
    }
    
    completionBlock();
    
  }];
  
  return YES;
}


- (void)eventsFromStore:(NSUInteger)numberOfEvents completionBlock:(void (^)(NSArray *entityIDs, NSArray *events, BOOL hasMore))completionBlock {
  
  [self.managedObjectContext performBlock:^{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTEventEntity"];
    
    // Oldest first
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
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


- (NSManagedObjectModel*)managedObjectModel {
  
  if (_managedObjectModel) {
    return _managedObjectModel;
  }
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"piwiktracker" withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  return _managedObjectModel;
}


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
      
      NSLog(@"Removed incompatible model version: %@", [storeURL lastPathComponent]);
      
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
        NSLog(@"Unresolved error when setting up code data stack %@, %@", error, [error userInfo]);
        abort();
      }
      
    }
    
  }
  
  return _persistentStoreCoordinator;
}


- (NSURL*)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
