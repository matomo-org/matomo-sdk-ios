//
//  AppDelegate.m
//  PiwikTrackeriOSDemo
//
//  Created by Mattias Levin on 9/16/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"

@import PiwikTrackerSwift;


static NSString * const PiwikTestServerURL = @"http://localhost/~mattias/piwik/";
static NSString * const PiwikTestSiteID = @"7";

static NSString * const PiwikProductionServerURL = @"http://someserver.com/piwik/";
static NSString * const PiwikProductionSiteID = @"23";


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{PiwikAskedForPermissonKey : @(NO)}];
    
    // Initialise the Piwik Tracker
    // Use different Piwik server urls and tracking site data depending on if building for test or production.
#ifdef DEBUG
    [PiwikTracker sharedInstanceWithSiteID:PiwikTestSiteID baseURL:[NSURL URLWithString:PiwikTestServerURL]];
#else
    [PiwikTracker sharedInstanceWithSiteID:PiwikTestSiteID baseURL:[NSURL URLWithString:PiwikProductionServerURL]];
#endif
    
    /* Configure the tracker */
    
    [PiwikTracker sharedInstance].debug = YES;
    [PiwikTracker sharedInstance].dispatchInterval = 30;
    
    //  id<PiwikDispatcher> dispatcher = [PiwikTracker sharedInstance].dispatcher;
    //  if ([dispatcher respondsToSelector:@selector(setUserAgent:)]) {
    //    [dispatcher setUserAgent:@"My-User-Agent"];
    //  }
    
    //  [PiwikTracker sharedInstance].sampleRate = 50;
    //  [PiwikTracker sharedInstance].eventsPerRequest = 2;
    
    // Do not track anything until the user give consent
    if (![[NSUserDefaults standardUserDefaults] boolForKey:PiwikAskedForPermissonKey]) {
        [PiwikTracker sharedInstance].optOut = YES;
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    // Look for any Piwik campaign keywords
    return [[PiwikTracker sharedInstance] sendCampaignWithUrl:url];
}

@end
