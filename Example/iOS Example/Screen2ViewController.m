//
//  Screen2ViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 9/17/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "Screen2ViewController.h"
#import "PiwikTracker.h"


@implementation Screen2ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Report screen view to Piwik
  [[PiwikTracker sharedInstance] sendViews:@"menu", @"screen view", @"screen view 2", nil];

}

@end
