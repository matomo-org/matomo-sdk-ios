//
//  PTTimerDispatchStrategy.m
//
//  Created by Mattias Levin on 5/15/12.
//  Copyright (c) 2012 Mattias Levin. All rights reserved.
//

#import "PTTimerDispatchStrategy.h"


@interface PTTimerDispatchStrategy ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) void (^errorBlock) (NSError*);
@end


@implementation PTTimerDispatchStrategy


// Initialize
- (id)initWithErrorBlock:(void(^)(NSError* error))errorBlock {
  self = [super init];
  if (self) {
    // Default timer value to once ever 5 minutes
    self.timeInteraval = 60 * 3;
    self.errorBlock = errorBlock;
  }
  
  return self;
}


// Create a new PTTimerDispatchStrategy
+ (PTTimerDispatchStrategy*)strategyWithErrorBlock:(void(^)(NSError* error))errorBlock {
  NSLog(@"Create timer dispatch strategy");
  return [[PTTimerDispatchStrategy alloc] initWithErrorBlock:errorBlock];
}



// Called when the dispatch timer fires
- (void)dispatchTimerFired:(NSTimer*)timer {
  NSLog(@"Dispatch timer fired");
  // Initiate a dispatch
  [[PiwikTracker sharedTracker] dispatchWithCompletionBlock:^(NSError *error) {
    if (error == nil) {
      NSLog(@"Dispatch completed, restart timer");
      // Dispatch was successful
      // Reset the timer interval
      [self startDispatchTimer];
    } else {
      // Stop timer
      [self stopDispatchTimer];
      // Dispatch did fail, run unrecoverable error block
      self.errorBlock(error);
    }
  }];
}


// Start the dispatch timer
- (void)startDispatchTimer {
  // Make sure it run on the main thread always
  dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"Start dispatch timer");
    self.isRunning = YES;
    
    // Reset the timer interval
    [self.timer invalidate];
    self.timer = nil;
    
    // Start a new timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInteraval
                                                  target:self
                                                selector:@selector(dispatchTimerFired:)
                                                userInfo:nil
                                                 repeats:NO];
  });
}


// Stop the dispatch timer
- (void)stopDispatchTimer {
  // Run in main thread
  dispatch_async(dispatch_get_main_queue(), ^{
    self.isRunning = NO;
  
    [self.timer invalidate];
    self.timer = nil;
  });
}


@end
