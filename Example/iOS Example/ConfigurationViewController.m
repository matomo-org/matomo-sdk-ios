//
//  ConfigurationViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 01/06/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "PiwikTracker.h"


@implementation ConfigurationViewController


- (IBAction)newSessionAction:(id)sender {
  // Create a new session
  [PiwikTracker sharedInstance].sessionStart = YES;
}


- (IBAction)dispatchEventsAction:(id)sender {
  // Dispatch queued events
  [[PiwikTracker sharedInstance] dispatch];
}


@end
