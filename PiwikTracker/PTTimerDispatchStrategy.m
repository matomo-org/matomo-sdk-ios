//
//  PTTimerDispatchStrategy.m
//
//  Created by Mattias Levin on 5/15/12.
//  Copyright (c) 2012 Mattias Levin. All rights reserved.
//

#import "PTTimerDispatchStrategy.h"


@interface PTTimerDispatchStrategy ()
@property (retain, nonatomic) NSTimer *timer;
@property (copy, nonatomic) void (^errorBlock) (NSError*);
@end


@implementation PTTimerDispatchStrategy


@synthesize timeInteraval = timeInterval_;
@synthesize startDispatchTimer = startDispatchTimer_;
@synthesize timer = timer_;
@synthesize errorBlock = errorBlock_;


// Initialize
- (id)initWithErrorBlock:(void(^)(NSError* error))errorBlock {
  self = [super init];
  if (self) {
    // Default timer value to once ever 5 minutes
    self.timeInteraval = 60 * 5;
    self.errorBlock = errorBlock;
  }
  
  return self;
}


// Create a new PTTimerDispatchStrategy
+ (PTTimerDispatchStrategy*)strategyWithErrorBlock:(void(^)(NSError* error))errorBlock {
  return [[[PTTimerDispatchStrategy alloc] initWithErrorBlock:errorBlock] autorelease];
}


// Free memory
- (void) dealloc {  
  self.errorBlock = nil;
   // Get rid of the timer
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
  
  [super dealloc];
}


// Called when the dispatch timer fires
- (void)dispatchTimerFired:(NSTimer*)timer {
  // Initiate a dispatch
  [[PiwikTracker sharedTracker] dispatchWithCompletionBlock:^(NSError *error) {
    if (error == nil) {
      // Dispatch was successful
      // Reset the timer interval
      [self.timer invalidate];
      // Start the timer again
      self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInteraval
                                                    target:self 
                                                  selector:@selector(dispatchTimerFired:) 
                                                  userInfo:nil 
                                                   repeats:NO];
    } else {
      // Dispatch did fail, run unrecoverable error block
      self.errorBlock(error);
    }
  }];
}


// Setter for starting or stopping the dispatch timer
- (void)startDispatchTimer:(BOOL)startTimer {
  startDispatchTimer_ = startTimer;
  
  if (startDispatchTimer_) {
    // Reset the timer interval
    [self.timer invalidate];
    // Start the timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInteraval
                                                  target:self 
                                                selector:@selector(dispatchTimerFired:) 
                                                userInfo:nil 
                                                 repeats:YES];
  } else {
    [self.timer invalidate];
    self.timer = nil;
  }
}


@end
