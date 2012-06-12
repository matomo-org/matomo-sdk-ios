//
//  PiwikCounterObserver.m
//  PiwikTestApp
//
//  Created by Mattias Levin on 1/2/12.
//  Copyright 2012 Mattias Levin. All rights reserved.
//

#import "PTCounterDispatchDelegate.h"
#import "PiwikTracker.h"

@implementation PTCounterDispatchDelegate

@synthesize triggerValue = triggerValue_;


// Initialize
- (id)init {
  self = [super init];
  if (self) {
    // Default trigger value set to 10
    self.triggerValue = 10;    
   }
  
  return self;
}


// Free memory
- (void) dealloc {
  // Remove delegate
  if ([PiwikTracker sharedTracker].delegate == self)
    [PiwikTracker sharedTracker].delegate = nil;
  
  [super dealloc];
}


// PiwikTracker delegate method called when a new event is added to the cache
- (void)trackerCachedEvent:(PTEvent*)event numberOfCachedEvents:(NSNumber*)numberOfCachedEvents {
  int eventCount = [numberOfCachedEvents intValue];
  NSLog(@"Event added to cache. Number of events in queue: %d", eventCount);
  
  if (eventCount > self.triggerValue) {
    NSLog(@"Number of events reached the trigger value, initate dispach of events to the Piwik server");
    [[PiwikTracker sharedTracker] dispatch];    
  }

}





@end
