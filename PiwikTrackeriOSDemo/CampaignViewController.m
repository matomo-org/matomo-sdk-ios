//
//  CampaignViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 03/06/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "CampaignViewController.h"
#import "PiwikTracker.h"


@implementation CampaignViewController

- (IBAction)campaignAction:(id)sender {
  
  // When tracking campaigns the app should detect app launch and look for Piwik campaign parameters in the launch parameters
  // This is done by registering a unqiue URL schema for the app and checking the launch URL in the application delegate class. Please look at the AppDelegate.m and the PiwikTrackeriOSDemo-Info.plist for an example.
  
  // This action implementation is only for desting and demonstration purpose.
  
  NSString *URLString = @"http://example.org/offer.html?pk_campaign=Email-SummerDeals&pk_kwd=LearnMore";
  [[PiwikTracker sharedInstance] sendCampaign:URLString];
  
}

@end
