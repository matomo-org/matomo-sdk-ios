//
//  ConfigurationViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 01/06/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "ConfigurationViewController.h"
@import PiwikTrackerSwift;

@implementation ConfigurationViewController

- (IBAction)newSessionAction:(id)sender {
    [PiwikTracker sharedInstance].sessionStart = YES;
}

- (IBAction)dispatchEventsAction:(id)sender {
    [[PiwikTracker sharedInstance] dispatch];
}

@end
