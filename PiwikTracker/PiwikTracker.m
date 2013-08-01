//
//  PiwikTracker.m
//  PiwikTracker
//
//  Created by Mattias Levin on 3/12/13.
//
//

#import "PiwikTracker.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "EventEntity.h"
#import "AFHTTPRequestOperation.h"


// User default keys
#define USER_DEFAULTS_NUMBER_OF_VISITS(siteId) @"##_TotalNumberOfVisit"
#define USER_DEFAULTS_CURRENT_VISIT(siteId) @"##_CurrentVisit"
#define USER_DEFAULTS_PREVIOUS_VISIT(siteId) @"##_PreviousVisit"
#define USER_DEFAULTS_FIRST_VISIT(siteId) @"##_FirstVisit"
#define USER_DEFAULTS_CLIENT_ID(siteId) @"##_ClientId"
#define USER_DEFAULTS_OPT_OUT @"OptOut"

// Piwik query parameter names
#define PIWIK_PARAM_SITE_ID @"idsite"
#define PIWIK_PARAM_AUTH_TOKEN @"token_auth"
#define PIWIK_PARAM_RECORD @"rec"
#define PIWIK_PARAM_API_VERSION @"apiv"
#define PIWIK_PARAM_SCREEN_RESOLUTION @"res"
#define PIWIK_PARAM_HOURS @"h"
#define PIWIK_PARAM_MINUTES @"m"
#define PIWIK_PARAM_SECONDS @"s"
#define PIWIK_PARAM_ACTION_NAME @"action_name"
#define PIWIK_PARAM_URL @"url"
#define PIWIK_PARAM_VISITOR_ID @"_id"
#define PIWIK_PARAM_VISIT_SCOPE_CUSTOM_VARIABLES @"_cvar"
#define PIWIK_PARAM_RANDOM_NUMBER @"r"
#define PIWIK_PARAM_FIRST_VISIT_TIMESTAMP @"_idts"
#define PIWIK_PARAM_PREVIOUS_VISIT_TIMESTAMP @"_viewts"
#define PIWIK_PARAM_NUMBER_OF_VISITS @"_idvc"
#define PIWIK_PARAM_GOAL_ID @"idgoal"
#define PIWIK_PARAM_REVENUE @"revenue"

// Piwik default parmeter values
#define PIWIK_RECORD_VALUE @"1"
#define PIWIK_API_VERSION_VALUE @"1"

// Custom variables
#define CUSTOM_VARIABLE_MAX_NUMBER 5
#define CUSTOM_VARIABLE_NAME_MAX_LENGTH 20
#define CUSTOM_VARIABLE_VALUE_MAX_LENGTH 100

// Core data
#define MAX_NUMBER_OF_STORED_EVENT 500


// Private stuff
@interface PiwikTracker ()

@property (nonatomic) NSUInteger totalNumberOfVisits;

@property (nonatomic, readonly) NSTimeInterval firstVisitTimestamp;
@property (nonatomic, readonly) NSTimeInterval previousVisitTimestamp;
@property (nonatomic) NSTimeInterval currentVisitTimestamp;
@property (nonatomic, strong) NSDate *appDidEnterBackgroundDate;

@property (nonatomic, strong) NSMutableArray *visitorCustomVariables;

@property (nonatomic, strong) NSDictionary *staticParameters;

@property (nonatomic, strong) NSTimer *dispatchTimer;

@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (id)initWithBaseURL:(NSURL*)baseURL siteId:(NSString*)siteId authenticationToken:(NSString*)authenticationToken;

- (void)startDispatchTimer;
- (void)stopDispatchTimer;

- (void)appDidBecomeActive:(NSNotification*)notification;
- (void)appDidEnterBackground:(NSNotification*)notification;

- (NSDictionary*)addCommonParameters:(NSDictionary*)parameters;
- (BOOL)queueEvent:(NSDictionary*)parameters;
- (void)dispatch:(NSNotification*)notification;

- (BOOL)storeEventsWithParameters:(NSDictionary*)parameters completionBlock:(void (^)(void))completionBlock;
- (void)eventFromStoreWithCompletionBlock:(void (^)(NSManagedObjectID *entityID, NSDictionary *parameters, BOOL hasMore))block;
- (void)deleteEventWithID:(NSManagedObjectID*)entityID;

- (NSURL*)applicationDocumentsDirectory;

+ (NSString*)encodeCustomVariables:(NSArray*)variables;
+ (NSString*)md5:(NSString*)input;
+ (NSString*)UUIDString;

@end


// Function declaration
NSString* customVariable(NSString* name, NSString* value);


// Implementation
@implementation PiwikTracker


// Synthesize
@synthesize totalNumberOfVisits = _totalNumberOfVisits;
@synthesize firstVisitTimestamp = _firstVisitTimestamp;
@synthesize currentVisitTimestamp = _currentVisitTimestamp;
@synthesize cliendId = _cliendId;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


static PiwikTracker *_sharedInstance;

// Get shared instance
+ (instancetype)sharedInstanceWithBaseURL:(NSURL*)baseURL siteId:(NSString*)siteId authenticationToken:(NSString*)authenticationToken {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[PiwikTracker alloc] initWithBaseURL:baseURL siteId:siteId authenticationToken:authenticationToken];
  });
  
  return _sharedInstance;
}


+ (instancetype)sharedInstance {
  
  if (!_sharedInstance) {
    ALog(@"Piwik tracker must first be initialized using sharedInstanceWithBaseURL:siteId:authenticationToken:");
    return nil;
  } else {
    return _sharedInstance;
  }

}


// Init new tracker
- (id)initWithBaseURL:(NSURL*)baseURL siteId:(NSString*)siteId authenticationToken:(NSString*)authenticationToken {
  
  // Make sure the base url is correct
  NSString *lastPathComponent = [baseURL lastPathComponent];
  if (![lastPathComponent isEqualToString:@"piwik.php"] && ![lastPathComponent isEqualToString:@"piwik-proxy.php"]) {
    baseURL = [NSURL URLWithString:@"pikik.php" relativeToURL:baseURL];
  }
    
  if (self = [super initWithBaseURL:baseURL]) {
    
    // Initialize instance variables
    
    _authenticationToken = authenticationToken;
    _siteId = siteId;
    
    _sessionTimeout = 30;
    
    _sampleRate = 100;
    
    // By default a new session will started when the tracker is created
    _sessionStart = YES;
    
    _dispatchInterval = 120;
    
    // Set default user defatult values
    NSDictionary *defaultValues = @{USER_DEFAULTS_OPT_OUT : @NO};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];

    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [self startDispatchTimer];
    
    DLog(@"Created new tracker with baseURL %@ and siteId %@", baseURL, siteId);
    
    return self;
  }
  else {
    return nil;
  }
}


// Start dispatch timer
- (void)startDispatchTimer {
  
  if (self.dispatchInterval < 0) {
    // Manual dispatch, do nothing
  } else if (self.dispatchInterval == 0) {
    // Send as soon at the event is queued, no timer
  } else {
    // Run on timer
    
    [self stopDispatchTimer];
    
    self.dispatchTimer = [NSTimer timerWithTimeInterval:self.dispatchInterval target:self selector:@selector(dispatch:) userInfo:nil repeats:NO];
  }
  
}


// Stop dispatch timer
- (void)stopDispatchTimer {
  
  if (self.dispatchTimer) {
    [self.dispatchTimer invalidate];
    self.dispatchTimer = nil;
  }
  
}


- (void)appDidBecomeActive:(NSNotification*)notification {
  
  if (!self.appDidEnterBackgroundDate || [self.appDidEnterBackgroundDate timeIntervalSinceNow] >= self.sessionTimeout || self.appDidEnterBackgroundDate == 0) {
    // First application launch
    self.sessionStart = YES;
  }
  
  [self startDispatchTimer];  
}


- (void)appDidEnterBackground:(NSNotification*)notification {
  self.appDidEnterBackgroundDate = [NSDate date];
  
  [self stopDispatchTimer];
}


- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark Views and Events

// Send screen views
- (BOOL)sendView:(NSString*)screen {
  
  if (self.sessionStart) {
    // Trigger a new session
    
    self.totalNumberOfVisits = self.totalNumberOfVisits + 1;
    self.currentVisitTimestamp = [[NSDate date] timeIntervalSince1970];
    
    // Reset static params
    self.staticParameters = nil;
    
    self.sessionStart = NO;
  }
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  // Set screen name
  [params setObject:screen forKey:PIWIK_PARAM_ACTION_NAME];
  
  // Setting the url is mandatory but not fully applicable in an application context
  // Set url by combining the app name and the screen name
  [params setObject:[NSString stringWithFormat:@"http://%@/%@", self.appName, screen] forKey:PIWIK_PARAM_URL];
  
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


// Add common Piwik query parameters
- (NSDictionary*)addCommonParameters:(NSDictionary*)parameters {
  
  if (!_staticParameters) {
    NSMutableDictionary *staticParameters = [NSMutableDictionary dictionary];
    
    // Force recording
    [staticParameters setObject:PIWIK_RECORD_VALUE forKey:PIWIK_PARAM_RECORD];
    
    // API version
    [staticParameters setObject:PIWIK_API_VERSION_VALUE forKey:PIWIK_PARAM_API_VERSION];
    
    // siteId
    [staticParameters setObject:self.siteId forKey:PIWIK_PARAM_SITE_ID];
    
    // Authentication token
    if (self.authenticationToken) {
      [staticParameters setObject:self.authenticationToken forKey:PIWIK_PARAM_AUTH_TOKEN];
    }
    
    // Set resolution
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    [staticParameters setObject:[NSString stringWithFormat:@"%.0fx%.0f", screenSize.width, screenSize.height]
                     forKey:PIWIK_PARAM_SCREEN_RESOLUTION];
    
    // Client id
    [staticParameters setObject:self.cliendId forKey:PIWIK_PARAM_VISITOR_ID];
    
    // First visit timestamp
    [staticParameters setObject:[NSString stringWithFormat:@"%.0f", self.firstVisitTimestamp] forKey:PIWIK_PARAM_FIRST_VISIT_TIMESTAMP];
    
    // Set previous visit timestamp
    [staticParameters setObject:[NSString stringWithFormat:@"%.0f", self.firstVisitTimestamp] forKey:PIWIK_PARAM_FIRST_VISIT_TIMESTAMP];
    
    // Set total number of visits
    [staticParameters setObject:[NSString stringWithFormat:@"%d", self.totalNumberOfVisits] forKey:PIWIK_PARAM_NUMBER_OF_VISITS];
    
    // Set custom variables - platform, OS version and application version
    UIDevice *device = [UIDevice currentDevice];
    [self.visitorCustomVariables insertObject:customVariable(@"Platform", device.model) atIndex:0];
    [self.visitorCustomVariables insertObject:customVariable(@"OS version", device.systemVersion) atIndex:1];
    [self.visitorCustomVariables insertObject:customVariable(@"App version", self.appVersion) atIndex:2];
    [staticParameters setObject:[PiwikTracker encodeCustomVariables:self.visitorCustomVariables]
                      forKey:PIWIK_PARAM_VISIT_SCOPE_CUSTOM_VARIABLES];
    
    _staticParameters = staticParameters;
  }
  
  // Join event parameters with static parameters
  NSMutableDictionary *commonParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
  
  [commonParameters addEntriesFromDictionary:_staticParameters];
  
  // Add random number
  int randomNumber = arc4random_uniform(50000);
  [commonParameters setObject:PIWIK_PARAM_RANDOM_NUMBER forKey:[NSString stringWithFormat:@"%d", randomNumber]];
  
  // Add local time
  NSCalendar *calendar = [NSCalendar currentCalendar];
  unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
  NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
  [commonParameters setObject:[NSString stringWithFormat:@"%d", [dateComponents hour]] forKey:PIWIK_PARAM_HOURS];
  [commonParameters setObject:[NSString stringWithFormat:@"%d", [dateComponents minute]] forKey:PIWIK_PARAM_MINUTES];
  [commonParameters setObject:[NSString stringWithFormat:@"%d", [dateComponents second]] forKey:PIWIK_PARAM_SECONDS];
    
  return commonParameters;
}


// Encode a custom variable
inline NSString* customVariable(NSString* name, NSString* value) {
  // TODO Do we need to do URL encoding?
  return [NSString stringWithFormat:@"[\"%@\",\"%@\"]", name, value];
}
   

// Encode list of custom variables
+ (NSString*)encodeCustomVariables:(NSArray*)variables {
  
  NSMutableArray *encodedVariables = nil;
  [variables enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [encodedVariables addObject:[NSString stringWithFormat:@"\"%d\":%@", idx, obj]];
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

  DLog(@"Que event with parameters %@", parameters);

  [self storeEventsWithParameters:parameters completionBlock:^{
    
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
  
  [self eventFromStoreWithCompletionBlock:^(NSManagedObjectID *entityID, NSDictionary *parameters, BOOL hasMore) {
    
    if (!parameters) {
      
      // No more pending events
      // Restart the dispatch timer
      [self startDispatchTimer];
      
    } else {

      if (self.debug) {
        // Debug mode
        // Print the result to the console, format the URL for easy reading
        NSMutableString *absoluteRequestURL = [NSMutableString stringWithString:@""];
        
        [absoluteRequestURL replaceOccurrencesOfString:@"?"
                                            withString:@"\n  "
                                               options:NSLiteralSearch
                                                 range:NSMakeRange(0, [absoluteRequestURL length])];
        [absoluteRequestURL replaceOccurrencesOfString:@"&"
                                            withString:@"\n  "
                                               options:NSLiteralSearch
                                                 range:NSMakeRange(0, [absoluteRequestURL length])];

        DLog(@"Debug Piwik request:\n%@", absoluteRequestURL);
        
        [self deleteEventWithID:entityID];
        
        if (hasMore ) {
          // Send remaining events
          [self dispatch];
        } else {
          // No more evets, restart the timer
          [self startDispatchTimer];
        }
    
      } else {
        
        [self getPath:nil parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          [self deleteEventWithID:entityID];
          
          if (hasMore ) {
            // Send remaining events
            [self dispatch];            
          } else {
            // No more evets, restart the timer
            [self startDispatchTimer];
          }
          
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          
          ALog(@"Failed to send stats to Piwik server with reason : %@", error);
          
          if ([self shouldAbortdispatchForNetworkError:error]) {
            // Do not continue for some errors
            // Restart the dispatch timer
            [self startDispatchTimer];
          } else if (hasMore) {
            // Leave failed event, contiune with next
            [self dispatch];
          }
          
        }];
        
      }
      
    }
    
  }];
  
  return YES;  
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
  [userDefaults setBool:optOut forKey:USER_DEFAULTS_OPT_OUT];
  [userDefaults synchronize];
}


// Get opt out
- (BOOL)optOut {
  return [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_OPT_OUT];
}


// Dispatch interval
- (void)setDispatchInterval:(NSTimeInterval)interval {
  
  if (interval == 0) {
    // Trigger a dispatch
    [self dispatch];
  }
  
  _dispatchInterval = interval;
}


// Last visit timestamp
- (void)setCurrentVisitTimestamp:(NSTimeInterval)currentVisitTimestamp {
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
  // Make the old current visit the previous visit
  [userDefaults setDouble:_currentVisitTimestamp forKey:USER_DEFAULTS_PREVIOUS_VISIT(self.siteId)];
  
  // Update current visit
  _currentVisitTimestamp = currentVisitTimestamp;
  [userDefaults setDouble:_currentVisitTimestamp forKey:USER_DEFAULTS_CURRENT_VISIT(self.siteId)];
  
  [userDefaults synchronize];
}


- (NSTimeInterval)currentVisitTimestamp {
  
  if (_currentVisitTimestamp == 0) {
    
    // Get the value from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _currentVisitTimestamp = [userDefaults doubleForKey:USER_DEFAULTS_CURRENT_VISIT(self.siteId)];
    
    if (_currentVisitTimestamp == 0) {
      // If still no value, create one
      _currentVisitTimestamp = [[NSDate date] timeIntervalSince1970];
      [userDefaults setDouble:_currentVisitTimestamp  forKey:USER_DEFAULTS_CURRENT_VISIT(self.siteId)];
      [userDefaults synchronize];
    }
  }
  
  return _currentVisitTimestamp;
}


// Client id
- (NSString*)cliendId {
  
  if (nil == _cliendId) {
    
    // Get from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _cliendId = [userDefaults stringForKey:USER_DEFAULTS_CLIENT_ID(self.siteId)];
    
    if (nil == _cliendId) {
      // Still nil, create
      
      // Get an UUID
      NSString *UUID = [PiwikTracker UUIDString];
      // md5 and max 16 chars
      _cliendId = [[PiwikTracker md5:UUID] substringToIndex:15];
      
      [userDefaults setValue:_cliendId forKey:USER_DEFAULTS_CLIENT_ID(self.siteId)];
      [userDefaults synchronize];
    }
  }
  
  return _cliendId;
}


// First visit timestamp
- (NSTimeInterval)firstVisitTimestamp {
  
  if (_firstVisitTimestamp == 0) {
    
    // Get the value from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _firstVisitTimestamp = [userDefaults doubleForKey:USER_DEFAULTS_FIRST_VISIT(self.siteId)];
    
    if (_firstVisitTimestamp == 0) {
      // If still no value, create one
      _firstVisitTimestamp = [[NSDate date] timeIntervalSince1970];
      [userDefaults setDouble:_firstVisitTimestamp  forKey:USER_DEFAULTS_FIRST_VISIT(self.siteId)];
      [userDefaults synchronize];
    }
  }
  
  return _firstVisitTimestamp;
}


// Number of visits
- (void)setNumberOfVisits:(NSUInteger)numberOfVisits {
  _totalNumberOfVisits = numberOfVisits;
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setInteger:numberOfVisits forKey:USER_DEFAULTS_NUMBER_OF_VISITS(self.siteId)];
  [userDefaults synchronize];
}

- (NSUInteger)numberOfVisits {
  
  if (_totalNumberOfVisits <= 0) {
    // Read value from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _totalNumberOfVisits = [userDefaults integerForKey:USER_DEFAULTS_NUMBER_OF_VISITS(self.siteId)];
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
  CC_MD5(str, strlen(str), result);
  
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


#pragma mark - core data methods

- (BOOL)storeEventsWithParameters:(NSDictionary*)parameters completionBlock:(void (^)(void))completionBlock {
  
  [self.managedObjectContext performBlock:^{
    
    NSError *error;
    
    // Check if we reached the limit of the number of queued events
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"EventEntity"];
    NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    if (count < MAX_NUMBER_OF_STORED_EVENT) {
      
      // Create new event entity
      EventEntity *eventEntity = [NSEntityDescription insertNewObjectForEntityForName:@"EventEntity" inManagedObjectContext:self.managedObjectContext];
      eventEntity.requestParameters = [NSKeyedArchiver archivedDataWithRootObject:parameters];
      
      [self.managedObjectContext save:&error];
      
    } else {
      ALog(@"Piwik tracker reach maximum number of queued events");
    }
    
    completionBlock();
    
  }];
  
  return YES;
}


- (void)eventFromStoreWithCompletionBlock:(void (^)(NSManagedObjectID *entityID, NSDictionary *parameters, BOOL hasMore))block {
  
  [self.managedObjectContext performBlock:^{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"EventEntity"];
    
    // Oldest first
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    // Bring up two events to check if there are more pending events stored
    fetchRequest.fetchLimit = 2;
    
    NSError *error;
    NSArray *events = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (events && events.count > 0) {
      EventEntity *event = [events objectAtIndex:0];
      
      NSDictionary *parameters = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:event.requestParameters];
      
      block(event.objectID, parameters, events.count == 2 ? YES : NO);
      
    } else {
      // No more pending events
      block(nil, nil, NO);
    }
    
  }];
    
}


- (void)deleteEventWithID:(NSManagedObjectID*)entityID {

  [self.managedObjectContext performBlock:^{
    
    NSError *error;
    
    EventEntity *event = (EventEntity*)[self.managedObjectContext existingObjectWithID:entityID error:&error];
    if (event) {
      [self.managedObjectContext deleteObject:event];
      
      [self.managedObjectContext save:&error];
    }
    
  }];
  
}


- (void)deleteAllStoredEvents {
  
  [self.managedObjectContext performBlock:^{
    
    NSError *error;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"EventEntity"];

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
      
      DLog(@"Removed incompatible model version: %@", [storeURL lastPathComponent]);
      
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
        DLog(@"Unresolved error when setting up code data stack %@, %@", error, [error userInfo]);
        abort();
      }
      
    }
    
  }
  
  return _persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL*)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
