//
//  PTRetryDispatchDelegate.m
//  PiwikTestApp
//
//  Created by Mattias Levin on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTRetryDispatchDelegate.h"


// Private stuff
@interface PTRetryDispatchDelegate ()

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) NSInteger currentNumberOfRetries;

@end


@implementation PTRetryDispatchDelegate


@synthesize maxNumberOfRetries = maxNumberOfRetries_;
@synthesize retryTimeInterval = retryTimeInterval_;
@synthesize timer = timer_;
@synthesize currentNumberOfRetries = currentNumberOfRetries_;


// Initialize
- (id)init {
  self = [super init];
  if (self) {
    // Default maximum number of retires
    self.maxNumberOfRetries = 10;
    self.currentNumberOfRetries = 0;
    self.retryTimeInterval = 60;
  }
  
  return self;
}


// Free memory
- (void) dealloc {
  // Remove delegate
  if ([PiwikTracker sharedTracker].delegate == self)
    [PiwikTracker sharedTracker].delegate = nil;  
  
  // Get rid of the timer
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
  [super dealloc];
}


// Called when the dispatch retry timer fires
- (void)retryTimerFired:(NSTimer*)timer {
  // Bump the number of retries
  self.currentNumberOfRetries = self.currentNumberOfRetries + 1;
  // Initiate a dispatch
  [[PiwikTracker sharedTracker] dispatch];
}


// Called when a request to the Piwik server fails
- (void)trackerDispachFailed:(PiwikTracker*)tracker {
  
  // Check if the the number of retries reached its limit
  if (self.currentNumberOfRetries > self.maxNumberOfRetries) {
    NSLog(@"The maximum number of retries have been reached");
    // TODO
  } else {
    // Reset the timer interval if already started
    [self.timer invalidate];
    // Start the timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.retryTimeInterval
                                                  target:self 
                                                selector:@selector(retryTimerFired:) 
                                                userInfo:nil 
                                                 repeats:NO];
  }
  
}


// Called when all events in the cache have to sent to the Piwik server
- (void)trackerDispatchDidComplete:(PiwikTracker*)tracker {  
  // Reset the number of retries
  self.currentNumberOfRetries = 0;
}

@end
