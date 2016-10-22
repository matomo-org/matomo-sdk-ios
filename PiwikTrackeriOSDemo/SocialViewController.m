//
//  SocialViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 9/16/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "SocialViewController.h"
@import PiwikTrackerSwift;

@interface SocialViewController ()
@end

@implementation SocialViewController

- (IBAction)sendSocialInteractionAction:(id)sender {
    // Send social interacations to Piwik
    [[PiwikTracker sharedInstance] sendSocialWithAction:@"like" forNetwork:@"Facebook" target:@"Piwik app"];
}

@end
