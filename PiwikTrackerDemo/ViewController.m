//
//  ViewController.m
//  PiwikTrackerDemo
//
//  Created by Mattias Levin on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "PiwikTracker.h"



@interface ViewController ()
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


- (IBAction)generateEvent1:(id)sender {
  NSLog(@"Generate Event 1");
  
  // Generate a pageview event
  [[PiwikTracker sharedInstance] sendView:@"Screen1"]];
   
}


- (IBAction)generateEvent2:(id)sender {
  NSLog(@"Generate Event 2");
  
  // Generate a another pageview event
  [[PiwikTracker sharedInstance] sendView:@"Screen2"];

}


- (IBAction)generateEventWithCategoryAndName:(id)sender {
  NSLog(@"Generate Event");
  
  [[PiwikTracker sharedInstance] sendEventWithCategory:@"category" action:@"action" label:@"label"];
}


- (IBAction)trackGoal:(id)sender {
  NSLog(@"Track goal");
  
  [[PiwikTracker sharedInstance] sendGoalWithID:@"1" revenue:200];
}


- (IBAction)deleteEvents:(id)sender {
  NSLog(@"Delete all queued Events");
  
  [[PiwikTracker sharedInstance] deleteQueuedEvents];
}


- (IBAction)dispatchEvents:(id)sender {
  NSLog(@"Dispatch all queued Events");
  
  // Dispatch all events in the queue
  [[PiwikTracker sharedInstance] dispatch];
}


@end
