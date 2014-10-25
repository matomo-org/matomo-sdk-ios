//
//  GoalsViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 10/6/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "GoalsViewController.h"
#import "PiwikTracker.h"


@interface GoalsViewController ()
@end


@implementation GoalsViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  
  [[PiwikTracker sharedInstance] sendViews:@"menu", @"goals", nil];
}


- (IBAction)sendGoalAction:(id)sender {
  
  // Track a conversion
  [[PiwikTracker sharedInstance] sendGoalWithID:1 revenue:5];
  
}


@end
