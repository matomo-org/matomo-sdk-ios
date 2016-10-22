//
//  DetailViewController.m
//  PiwikTrackeriOSDemo
//
//  Created by Mattias Levin on 9/16/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "ScreenViewController.h"
@import PiwikTrackerSwift;

@implementation ScreenViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Report screen view to Piwik
  [[PiwikTracker sharedInstance] sendViews:@[@"menu", @"screen view"]];
}


@end
