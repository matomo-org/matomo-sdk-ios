//
//  PiwikAnalytics.m
//  PiwikTracker
//
//  Created by Mattias Levin on 3/12/13.
//
//

#import "PiwikAnalytics.h"
#import "PiwikTracker.h"


#define USER_DEFAULTS_OPT_OUT @"OptOut"


// Private stuff
@interface PiwikAnalytics ()

@property(strong) NSMutableDictionary *trackers;

@end


// Implementation
@implementation PiwikAnalytics


// Return a singleton shared Piwik instance
+ (instancetype)sharedInstance {
  static PiwikAnalytics *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[PiwikAnalytics alloc] init];
  });
  
  return _sharedInstance;
}


// Init
- (id)init {
  if (self = [super init]) {
    // initialize instance variables
    self.trackers = [NSMutableDictionary dictionary];
    
    // Set default user defatult values
    NSDictionary *defaultValues = @{
      USER_DEFAULTS_OPT_OUT : @NO
    };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    
    return self;
  }
  else {
    return nil;
  }
}


// Get a tracker, create if it does not exist
- (PiwikTracker*)trackerWithSiteId:(NSString*)siteId authenticationToken:(NSString*)authenticationToken
                           baseURL:(NSString*)baseURL {
  
  // Check if the tracker already exists
  PiwikTracker *tracker = [self.trackers objectForKey:siteId];
  
  if (nil == tracker) {
    // Create new
    tracker = [PiwikTracker trackerWithSiteId:siteId authenticationToken:authenticationToken baseURL:baseURL];
    [self.trackers setObject:tracker forKey:siteId];
  }
  
  // If we do not have a default tracker set the first one created as default
  if (nil == self.defaultTracker) {
    self.defaultTracker = tracker;
  }
  
  return tracker;
}


// Initiate a manual dispatch of pending tacking information
- (void)dispatch {
  
  // TODO
  
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


@end



