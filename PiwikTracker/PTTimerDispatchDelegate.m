//
//  PTTimerDispatchObserver.m
//  PiwikTestApp
//
//  Created by Mattias Levin on 5/15/12.
//  Copyright (c) 2012 Mattias Levin. All rights reserved.
//

#import "PTTimerDispatchDelegate.h"


@interface PTTimerDispatchDelegate ()
@property (retain, nonatomic) NSTimer *timer;
@end


@implementation PTTimerDispatchDelegate


@synthesize timeInteraval = timeInterval_;
@synthesize startDispatchTimer = startDispatchTimer_;
@synthesize timer = timer_;


// Initialize
- (id)init {
  self = [super init];
  if (self) {
    // Default timer value to once ever 5 minutes
    self.timeInteraval = 60 * 5;
  }
  
  return self;
}


// Free memory
- (void) dealloc {
  
  // Remove as delegate
  if ([PiwikTracker sharedTracker].delegate == self)
    [PiwikTracker sharedTracker].delegate = nil;
  
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
  [[PiwikTracker sharedTracker] dispatch];
}


// Called when all events in the cache have to sent to the Piwik server
- (void)trackerDispatchDidComplete:(PiwikTracker*)tracker {  
  // Only restart the timer if the timer is on in the first place
  if (self.startDispatchTimer) {
    // Reset the timer interval
    [self.timer invalidate];
    // Start the timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInteraval
                                                  target:self 
                                                selector:@selector(dispatchTimerFired:) 
                                                userInfo:nil 
                                                repeats:NO];
  }
}


// Called when a request to the Piwik server fails
- (void)trackerDispachFailed:(PiwikTracker*)tracker {
  // Only restart the timer if the timer is on in the first place
  if (self.startDispatchTimer) {
    
    // Reset the timer interval
    [self.timer invalidate];
    // Start the timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInteraval
                                                  target:self 
                                                selector:@selector(dispatchTimerFired:) 
                                                userInfo:nil 
                                                 repeats:NO];
  }
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
