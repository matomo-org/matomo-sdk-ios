//
//  SocialViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 9/16/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "SocialViewController.h"
#import "PiwikTracker.h"


@interface SocialViewController ()
@end


@implementation SocialViewController


- (IBAction)sendSocialInteractionAction:(id)sender {
  
  // Send social interacations to Piwik
  [[PiwikTracker sharedInstance] sendSocialInteraction:@"like" target:@"Piwik app" forNetwork:@"Facebook"];
    
}


@end
