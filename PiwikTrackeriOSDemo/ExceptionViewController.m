//
//  ExceptionViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 9/16/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "ExceptionViewController.h"
@import PiwikTrackerSwift;

@interface ExceptionViewController ()
@end

@implementation ExceptionViewController

- (IBAction)sendExceptionAction:(id)sender {
    // Send an exception event to the Piwik server
    [[PiwikTracker sharedInstance] sendExceptionWithDescription:@"Send a fake exception from my app" fatal:NO];
}


@end
