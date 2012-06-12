//
//  ViewController.m
//  PiwikTrackerDemo
//
//  Created by Mattias Levin on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


#define PIWIK_URL @"http://piwik.golgek.com/piwik/"
#define SITE_ID_TEST @"6"


@interface ViewController ()
@property (nonatomic, retain) PiwikTracker *tracker;
@end


@implementation ViewController


@synthesize tracker = tracker_;


- (void)dealloc {
  self.tracker = nil;
  
  [super dealloc];
}


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
                                delegate:self 
                               withError:&error];
  self.tracker.dryRun = YES;
}


- (IBAction)stopTracker:(id)sender {
  NSLog(@"Stop the Tracker");
  
  // Stop the Tracker from accepting new events
  [self.tracker stopTracker];
}


- (IBAction)generateEvent1:(id)sender {
  NSLog(@"Generate Event 1");
  
  // Generate a pageview event
  NSError *error = nil;
  [self.tracker trackPageview:@"Event1" withError:&error];
}


- (IBAction)generateEvent2:(id)sender {
  NSLog(@"Generate Event 2");
  
  // Generate a another pageview event
  NSError *error = nil;
  [self.tracker trackPageview:@"Event2" withError:&error];
}


- (IBAction)generateEvent3:(id)sender {
  NSLog(@"Generate Event 3");
  
  // Generate a another pageview event
  NSError *error = nil;
  [self.tracker trackPageview:@"Event3" withError:&error];
}


- (IBAction)generate10Event3:(id)sender {
  NSLog(@"Generate 10 x Event 3");
  
  // Generate 10 pageview event
  for (int i = 0; i < 10; i++) {
    NSError *error = nil;
    [self.tracker trackPageview:@"Event3" withError:&error];
  }
}


- (IBAction)generateGoal:(id)sender {
  NSLog(@"Generate goal");
  
  // Generate goal
  NSError *error = nil;
  [self.tracker trackGoal:1 withRevenue:10.0 withError:&error];
}


- (IBAction)deleteEvents:(id)sender {
  NSLog(@"Delete all queued Events");
  
  // Delete all events in the queue
  [self.tracker emptyQueue];
}

- (IBAction)dispatchEvents:(id)sender {
  NSLog(@"Dispatch all queued Events");
  
  // Dispatch all events in the queue
  [self.tracker dispatch];
}

@end
