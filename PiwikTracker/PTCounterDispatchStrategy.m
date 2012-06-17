//
//  PiwikCounterObserver.m
//  PiwikTestApp
//
//  Created by Mattias Levin on 1/2/12.
//  Copyright 2012 Mattias Levin. All rights reserved.
//

#import "PTCounterDispatchStrategy.h"
#import "PiwikTracker.h"

@interface PTCounterDispatchStrategy ()
@property (copy, nonatomic) void (^errorBlock) (NSError*);
@end


@implementation PTCounterDispatchStrategy


@synthesize triggerValue = triggerValue_;
@synthesize errorBlock = errorBlock_;


// Initialize
- (id)initWithErrorBlock:(void(^)(NSError* error))errorBlock {
  self = [super init];
  if (self) {
    // Default trigger value set to 10
    self.triggerValue = 10;   
    self.errorBlock = errorBlock;
    
    // Listen to cached event notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(trackerCachedEvent:) 
                                                 name:@"PTEventQueuedSuccessNotification" 
                                               object:nil];

   }
  
  return self;
}

// Create a new PTCounterDispatchStrategy
+ (PTCounterDispatchStrategy*)strategyWithErrorBlock:(void(^)(NSError* error))errorBlock {
  return [[[PTCounterDispatchStrategy alloc] initWithErrorBlock:errorBlock] autorelease];
}


// Free memory
- (void) dealloc { 
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.errorBlock = nil;
  [super dealloc];
}


// PiwikTracker delegate method called when a new event is added to the cache
- (void)trackerCachedEvent:(NSNotification*)notification {
  NSDictionary *userInfo = notification.userInfo;
  NSNumber *eventCount = [userInfo objectForKey:@"NumberOfCachedEvents"];
  NSLog(@"Event added to cache. Number of events in queue: %d", [eventCount integerValue]);
  
  if (eventCount && [eventCount integerValue] > self.triggerValue) {
    NSLog(@"Number of events reached the trigger value, initate dispach of events to the Piwik server");
    [[PiwikTracker sharedTracker] dispatchWithCompletionBlock:^(NSError *error) {
      if (error != nil)
        self.errorBlock(error);
    }];    
  }

}


@end
