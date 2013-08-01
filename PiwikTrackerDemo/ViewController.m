//
//  ViewController.m
//  PiwikTrackerDemo
//
//  Created by Mattias Levin on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "PiwikTracker.h"


#define PIWIK_URL @"http://piwik.golgek.com/piwik/"
#define SITE_ID_TEST @"6"


@interface ViewController ()
@property (nonatomic, strong) PiwikTracker *tracker;
@end


@implementation ViewController


- (void)viewDidLoad {
  [super viewDidLoad];
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
  
  // Get the shared tracker
  self.tracker = [PiwikTracker sharedInstanceWithBaseURL:[NSURL URLWithString:PIWIK_URL] siteId:SITE_ID_TEST authenticationToken:nil];  
}


- (IBAction)generateEvent1:(id)sender {
  NSLog(@"Generate Event 1");
  
  // Generate a pageview event
  [self.tracker sendView:@"Screen1"];
   
}


- (IBAction)generateEvent2:(id)sender {
  NSLog(@"Generate Event 2");
  
  // Generate a another pageview event
  [self.tracker sendView:@"Screen2"];

}


- (IBAction)generate10Event2:(id)sender {
  NSLog(@"Generate 10 x Event 2");
  
  // Generate 10 pageview event
  for (int i = 0; i < 10; i++) {
    [self.tracker sendView:@"Screen2"];
  }
}


- (IBAction)generateEventWithCategoryAndName:(id)sender {
  NSLog(@"Generate Event - not implemented");
}


- (IBAction)deleteEvents:(id)sender {
  NSLog(@"Delete all queued Events");
  
  [self.tracker deleteQueuedEvents];
}


- (IBAction)dispatchEvents:(id)sender {
  NSLog(@"Dispatch all queued Events");
  
  // Dispatch all events in the queue
  [self.tracker dispatch];
}


@end
