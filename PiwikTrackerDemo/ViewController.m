//
//  ViewController.m
//  PiwikTrackerDemo
//
//  Created by Mattias Levin on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "PTTimerDispatchStrategy.h"


#define PIWIK_URL @"http://piwik.golgek.com/piwik/"
#define SITE_ID_TEST @"6"


@interface ViewController ()
@property (nonatomic, strong) PiwikTracker *tracker;
@property (nonatomic, strong) PTTimerDispatchStrategy *timerStrategy;
@end


@implementation ViewController


- (void)viewDidLoad {
  [super viewDidLoad];
	
  // Get the shared tracker
  self.tracker = [PiwikTracker sharedTracker];
}


- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}


- (IBAction)startTracker:(id)sender {
  NSLog(@"Start the Tracker");
  
  // Start the tracker. This also creates a new session.
  NSError *error = nil;
  [self.tracker startTrackerWithPiwikURL:PIWIK_URL 
                                  siteID:SITE_ID_TEST 
                     authenticationToken:nil 
                               withError:&error];
  self.tracker.dryRun = YES;
  
  // Start the timer dispatch strategy
  self.timerStrategy = [PTTimerDispatchStrategy strategyWithErrorBlock:^(NSError *error) {
    NSLog(@"The timer strategy failed to initated dispatch of analytic events");
  }];
  self.timerStrategy.timeInteraval = 20; // Set the time intervall to 20s, default value is 3 minutes
  [self.timerStrategy startDispatchTimer];
}


- (IBAction)stopTracker:(id)sender {
  NSLog(@"Stop the Tracker");
  
  // Stop the Tracker from accepting new events
  [self.tracker stopTracker];
  
  // Stop the time strategy
  [self.timerStrategy stopDispatchTimer];
}


- (IBAction)generateEvent1:(id)sender {
  NSLog(@"Generate Event 1");
  
  // Generate a pageview event
  [self.tracker trackPageview:@"Event1" completionBlock:^(NSError *error) {
    if (error != nil) {
      NSLog(@"Track page failed with error message %@", [error description]);
    }
  }];
}


- (IBAction)generateEvent2:(id)sender {
  NSLog(@"Generate Event 2");
  
  // Generate a another pageview event
  [self.tracker trackPageview:@"Event2" completionBlock:^(NSError *error) {
    if (error != nil) {
      NSLog(@"Track page failed with error message %@", [error description]);
    }
  }];
}


- (IBAction)generateEvent3:(id)sender {
  NSLog(@"Generate Event 3");
  
  // Generate a another pageview event
  [self.tracker trackPageview:@"Event3" completionBlock:^(NSError *error) {
    if (error != nil) {
      NSLog(@"Track page failed with error message %@", [error description]);
    }
  }];
}


- (IBAction)generate10Event3:(id)sender {
  NSLog(@"Generate 10 x Event 3");
  
  // Generate 10 pageview event
  for (int i = 0; i < 10; i++) {
    [self.tracker trackPageview:@"Event3" completionBlock:^(NSError *error) {
      if (error != nil) {
        NSLog(@"Track page failed with error message %@", [error description]);
      }
    }];
  }
}


- (IBAction)generateGoal:(id)sender {
  NSLog(@"Generate goal");
  
  // Generate goal
  [self.tracker trackGoal:1 withRevenue:10.0 completionBlock:^(NSError *error) {
    if (error != nil) {
      NSLog(@"Track goal failed with error message %@", [error description]);
    }
  }];
}


- (IBAction)deleteEvents:(id)sender {
  NSLog(@"Delete all queued Events");
  
  // Delete all events in the queue
  [self.tracker emptyQueueWithCompletionBlock:^(NSError *error) {
    if (error != nil) {
      NSLog(@"Delete cached events failed with error message %@", [error description]);
    }
  }];
}

- (IBAction)dispatchEvents:(id)sender {
  NSLog(@"Dispatch all queued Events");
  
  // Dispatch all events in the queue
  [self.tracker dispatchWithCompletionBlock:^(NSError *error) {
    if (error != nil) {
      NSLog(@"Dispatch cached events failed with error message %@", [error description]);
    }
  }];
}

@end
