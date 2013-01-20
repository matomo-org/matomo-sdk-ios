//
//  PTRetryDispatchDelegate.m
//  PiwikTestApp
//
//  Created by Mattias Levin on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTRetryDispatchStrategy.h"


// Private stuff
@interface PTRetryDispatchStrategy ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) NSInteger currentNumberOfRetries;
@property (nonatomic, copy) void (^errorBlock) (NSError*);
@end


@implementation PTRetryDispatchStrategy


// Initialize
- (id)initWithErrorBlock:(void(^)(NSError* error))errorBlock {
  self = [super init];
  if (self) {
    // Default maximum number of retires
    self.maxNumberOfRetries = 10;
    self.currentNumberOfRetries = 0;
    self.retryTimeInterval = 60;
    self.errorBlock = errorBlock;
    
    // Listen to failed dispatch notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(trackerDispachFailed:)
                                                 name:@"PTDispatchFailedNotification"
                                               object:nil];
  }
  
  return self;
}


// Create a new PTRetryDispatchStrategy
+ (PTRetryDispatchStrategy*)strategyWithErrorBlock:(void(^)(NSError* error))errorBlock {
  return [[PTRetryDispatchStrategy alloc] initWithErrorBlock:errorBlock];
}


// Called when the dispatch retry timer fires
- (void)retryTimerFired:(NSTimer*)timer {
  // Bump the number of retries
  self.currentNumberOfRetries = self.currentNumberOfRetries + 1;
  // Initiate a dispatch
  [[PiwikTracker sharedTracker] dispatchWithCompletionBlock:^(NSError *error) {
    if (error == nil) {
      self.currentNumberOfRetries = 0;
      [self.timer invalidate];
      self.timer = nil;
    } else {
      // Check if the the number of retries reached its limit
      if (self.currentNumberOfRetries >= self.maxNumberOfRetries) {
        NSLog(@"The maximum number of retries have been reached");
        // Run the unrecoverable error block
        self.errorBlock(error);
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
  }];
}


// Called when a request to the Piwik server fails
- (void)trackerDispachFailed:(NSNotification*)notification {
  // Start the retry time if not already running
  if (self.timer == nil) {
    [self.timer invalidate];
    // Start the timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.retryTimeInterval
                                                  target:self
                                                selector:@selector(retryTimerFired:)
                                                userInfo:nil
                                                 repeats:NO];
  }
}


@end
