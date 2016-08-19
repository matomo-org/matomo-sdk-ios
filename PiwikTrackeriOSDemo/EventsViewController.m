//
//  EventsViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 9/16/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "EventsViewController.h"
#import "PiwikTracker.h"


@interface EventsViewController ()
@end


@implementation EventsViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  
  [[PiwikTracker sharedInstance] sendViews:@"menu", @"events", nil];
}


- (IBAction)sendEventAction:(id)sender {
  
  // Send a custom event tp Piwik  
  [[PiwikTracker sharedInstance] sendEventWithCategory:@"TestCategory" action:@"Play" name:@"Song12" value:@(2)];
  
}


@end
