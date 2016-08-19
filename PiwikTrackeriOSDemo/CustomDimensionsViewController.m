//
//  CustomDimensionsViewController.m
//  PiwikTracker
//
//  Created by Sean Cunningham on 05/05/16.
//  Copyright (c) 2016 Sean Cunningham. All rights reserved.
//

#import "CustomDimensionsViewController.h"
#import "PiwikTracker.h"


@implementation CustomDimensionsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)customDimensionAAction:(id)sender {
    NSLog(@"Log Dimension");
    BOOL result = [[PiwikTracker sharedInstance] setCustomDimensionForIndex:4 value:@"TestDimension"];
    NSLog(result? @"yes" : @"no");
}


@end
