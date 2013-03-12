//
//  PiwikTracker.m
//  PiwikTracker
//
//  Created by Mattias Levin on 3/12/13.
//
//

#import "PiwikTracker.h"
#import <CommonCrypto/CommonDigest.h>
#import "PWTUserAgentReader.h"
#import "PiwikAnalytics.h"


// User default keys
#define USER_DEFAULTS_NUMBER_OF_VISITS(siteId) @"##_NumberOfVisit"
#define USER_DEFAULTS_PREVIOUS_VISIT(siteId) @"##_PreviousVisit"
#define USER_DEFAULTS_FIRST_VISIT(siteId) @"##_FirstVisit"
#define USER_DEFAULTS_CLIENT_ID(siteId) @"##_ClientId"

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
#define PIWIK_PARAM_LAST_VISIT_TIMESTAMP @"_viewts"
#define PIWIK_PARAM_NUMBER_OF_VISIT @"_idvc"
#define PIWIK_PARAM_GOAL_ID @"idgoal"
#define PIWIK_PARAM_REVENUE @"revenue"

// Piwik default parmeter values
#define PIWIK_RECORD_VALUE @"1"
#define PIWIK_API_VERSION_VALUE @"1"

#define DEFAULT_USER_AGENT @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"

// Custom variables
#define CUSTOM_VARIABLE_MAX_NUMBER 5
#define CUSTOM_VARIABLE_NAME_MAX_LENGTH 20
#define CUSTOM_VARIABLE_VALUE_MAX_LENGTH 100


// Private stuff
@interface PiwikTracker ()

@property (nonatomic) NSUInteger numberOfVisits;
@property (nonatomic, readonly) NSTimeInterval firstVisitTimestamp;
@property (nonatomic, readonly) NSTimeInterval previousVisitTimestamp;
@property (nonatomic) NSTimeInterval currentVisitTimestamp;
@property (nonatomic, readonly) NSString *userAgent;

@property (nonatomic, strong) NSMutableArray *visitorCustomVariables;

+ (NSString*)md5:(NSString*)input;
+ (NSString*)UUIDString;

+ (NSString*)queryParametersFromDict:(NSDictionary*)dictionary;
+ (NSString*)urlEncodeString:(NSString*)string;

- (id)initWithSiteId:(NSString*)siteId authenticationToken:(NSString*)authenticationToken baseURL:(NSString*)baseURL;
- (BOOL)queueTrackingInformation:(NSDictionary*)information;
- (NSDictionary*)addStaticParams:(NSDictionary*)params;

@end


// Implementation
@implementation PiwikTracker


// Synthesize
@synthesize firstVisitTimestamp = _firstVisitTimestamp;
@synthesize numberOfVisits = _numberOfVisits;
@synthesize cliendId = _cliendId;
@synthesize userAgent = _userAgent;


// Create a new tracker
+ (instancetype)trackerWithSiteId:(NSString*)siteId authenticationToken:(NSString*)authenticationToken baseURL:(NSString*)baseURL {
  
  // Make sure the base url is correct
  if ([baseURL hasSuffix:@"/piwik.php"] == NO && [baseURL hasSuffix:@"/piwik-proxy.php"] == NO) {
    baseURL = [baseURL stringByAppendingString:@"piwik.php"];
  }
  
  return [[PiwikTracker alloc] initWithSiteId:siteId authenticationToken:authenticationToken baseURL:baseURL];
}


// Init new tracker
- (id)initWithSiteId:(NSString*)siteId authenticationToken:(NSString*)authenticationToken baseURL:(NSString*)baseURL {
  
  if (self = [super initWithBaseURL:[NSURL URLWithString:baseURL]]) {
    // initialize instance variables
    _authenticationToken = authenticationToken;
    _siteId = siteId;
    
    // The creation of a new tracker is counted as a new visit
    // Set visit start values
    self.sampleRate = 100;
    self.numberOfVisits = self.numberOfVisits + 1;
    self.currentVisitTimestamp = [[NSDate date] timeIntervalSince1970];
        
    // Cache the user agent (do not use the value yet)
    NSString *ua = self.userAgent;
    #pragma unused(ua) // Supress compiler warning
    
    return self;
  }
  else {
    return nil;
  }
}


#pragma mark Views and Events

// Send page views
// Piwik support screen names with / and will when group the screen views hierarchically
- (BOOL)sendView:(NSString*)screen {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  // Set screen name
  [params setValue:screen forKey:PIWIK_PARAM_ACTION_NAME];
  
  // Setting the url is mandatory but not fully applicable in an application context
  // Set url by combining the app name and the action name
  [params setValue:[NSString stringWithFormat:@"http://%@/%@", self.appName, screen] forKey:PIWIK_PARAM_URL];
  
  return [self queueTrackingInformation:[self addStaticParams:params]];
}

// Track the event as hierarchical screen view
// TODO Is this a relevant methon for Piwik tracker
- (BOOL)sendEventWithCategory:(NSString*)category withAction:(NSString*)action withLabel:(NSString*)label {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  // Set screen name
  NSString *actionName = [NSString stringWithFormat:@"%@/%@/%@", category, action, label];
  [params setValue:actionName forKey:PIWIK_PARAM_ACTION_NAME];
  
  // Setting the url is mandatory but not fully applicable in an application context
  // Set url by combining the app name and the action name
  [params setValue:[NSString stringWithFormat:@"http://%@/%@", self.appName, actionName] forKey:PIWIK_PARAM_URL];
  
  return [self queueTrackingInformation:[self addStaticParams:params]];
}

// Add common Piwik query parameters
- (NSDictionary*)addStaticParams:(NSDictionary*)params {
  
  // TODO caching
  
  NSMutableDictionary *updatedParams = [NSMutableDictionary dictionaryWithDictionary:params];
  
  // Force recording
  [updatedParams setValue:PIWIK_RECORD_VALUE forKey:PIWIK_PARAM_RECORD];
  
  // API version
  [updatedParams setValue:PIWIK_API_VERSION_VALUE forKey:PIWIK_PARAM_API_VERSION];
  
  // siteId
  [updatedParams setValue:self.siteId forKey:PIWIK_PARAM_SITE_ID];
  
  // Authentication token
  if (self.authenticationToken) {
    [updatedParams setValue:self.authenticationToken forKey:PIWIK_PARAM_AUTH_TOKEN];
  }
  
  // Set resolution
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  CGFloat screenScale = [[UIScreen mainScreen] scale];
  CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
  
  [updatedParams setValue:[NSString stringWithFormat:@"%.0fx%.0f", screenSize.width, screenSize.height]
                   forKey:PIWIK_PARAM_SCREEN_RESOLUTION];
  
  // Client id
  [updatedParams setObject:self.cliendId forKey:PIWIK_PARAM_VISITOR_ID];
  
  // First visit timestamp
  [updatedParams setObject:[NSString stringWithFormat:@"%.0f", self.firstVisitTimestamp] forKey:PIWIK_PARAM_FIRST_VISIT_TIMESTAMP];
  
  // Set custom variables - platform, OS version and application version
  UIDevice *device = [UIDevice currentDevice];
  [self.visitorCustomVariables insertObject:[PiwikTracker encodeCustomVariableWithName:@"Platform" value:device.model]
                                    atIndex:0];
  [self.visitorCustomVariables insertObject:[PiwikTracker encodeCustomVariableWithName:@"OS version" value:device.systemVersion]
                                    atIndex:1];
  [self.visitorCustomVariables insertObject:[PiwikTracker encodeCustomVariableWithName:@"App version" value:self.appVersion]
                                    atIndex:2];
  [updatedParams setObject:[PiwikTracker encodeCustomVariables:self.visitorCustomVariables]
                    forKey:PIWIK_PARAM_VISIT_SCOPE_CUSTOM_VARIABLES];
  
  return updatedParams;
}


+ (NSString*)encodeCustomVariableWithName:(NSString*)name value:(NSString*)value {
  return [NSString stringWithFormat:@"[\"%@\",\"%@\"]", name, value];
}
   

+ (NSString*)encodeCustomVariables:(NSArray*)variables {
  
  
  //NSString *customVariables = [NSString stringWithFormat:@"{%@}", [self.visitorCustomVariables componentsJoinedByString:@","]];

  
  return nil;
}
   
   



#pragma mark Queue tracking information

- (BOOL)queueTrackingInformation:(NSDictionary*)params {
  
  if ([PiwikAnalytics sharedInstance].optOut == YES) {
    // User opted out from tracking, to nothing
    // Still return YES, since returning NO is considered an error
    return YES;
  }
  
  // Add send unique parameters
  
  
  if ([PiwikAnalytics sharedInstance].debug == YES) {
    // Debug mode
    // Print the result to the console, format the URL for easy reading
    NSMutableString *prettyURL = [NSString stringWithFormat:@"%@?%@",
                                  self.baseURL,
                                  [PiwikTracker queryParametersFromDict:params]];
    [prettyURL replaceOccurrencesOfString:@"?" withString:@"\n  " options:NSLiteralSearch
                                    range:NSMakeRange(0, [prettyURL length])];
    [prettyURL replaceOccurrencesOfString:@"&" withString:@"\n  " options:NSLiteralSearch
                                    range:NSMakeRange(0, [prettyURL length])];
    NSLog(@"Debug Piwik request:\n%@", prettyURL);
    return YES;
  }
  
  // TODO Queue the tracking info
  
  return YES;
}


#pragma mark Properties

// Last visit timestamp
- (void)setCurrentVisitTimestamp:(NSTimeInterval)currentVisitTimestamp {
  _currentVisitTimestamp = currentVisitTimestamp;
  
  // Get the previous visit and and store the current visit as the "new" previous visit until next time the tracker is started
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  _previousVisitTimestamp = [userDefaults doubleForKey:USER_DEFAULTS_PREVIOUS_VISIT(self.siteId)];
  [userDefaults setDouble:_currentVisitTimestamp forKey:USER_DEFAULTS_PREVIOUS_VISIT(self.siteId)];
  [userDefaults synchronize];  
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
      // If still no value, create
      _firstVisitTimestamp = [[NSDate date] timeIntervalSince1970];
      [userDefaults setDouble:_firstVisitTimestamp  forKey:USER_DEFAULTS_FIRST_VISIT(self.siteId)];
      [userDefaults synchronize];
    }
  }
  
  return _firstVisitTimestamp;
}


// Number of visits
- (void)setNumberOfVisits:(NSUInteger)numberOfVisits {
  _numberOfVisits = numberOfVisits;
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setInteger:numberOfVisits forKey:USER_DEFAULTS_NUMBER_OF_VISITS(self.siteId)];
  [userDefaults synchronize];
}

- (NSUInteger)numberOfVisits {
  if (_numberOfVisits <= 0) {
    // Read value from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _numberOfVisits = [userDefaults integerForKey:USER_DEFAULTS_NUMBER_OF_VISITS(self.siteId)];
  }
  return _numberOfVisits;
}


// User agent
- (NSString*)userAgent {
  static PWTUserAgentReader *userAgentReader = nil;
  
  if (nil == _userAgent) {
    // Try and get the user agent
    if (!userAgentReader) {
      userAgentReader = [[PWTUserAgentReader alloc] init];
    }
    
    [userAgentReader userAgentStringWithCallbackBlock:^(NSString *userAgent) {
      _userAgent = userAgent;
    }];
    
    // Use a fallback UA while we wait for the real value
    return DEFAULT_USER_AGENT;
  }
  
  return _userAgent;
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


// Create a query parameters from dict
+ (NSString*)queryParametersFromDict:(NSDictionary*)dictionary {
  // Parameter list
  NSMutableArray *params = [NSMutableArray array];
  [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    // Need to do URL encoding of the value
    [params addObject:[NSString stringWithFormat:@"%@=%@", key, [PiwikTracker urlEncodeString:(NSString*)obj]]];
  }];
  
  return [params componentsJoinedByString:@"&"];
}


// Url encoding a string
+ (NSString*)urlEncodeString:(NSString*)string {
  return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                              (CFStringRef)string,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8);
}


@end
