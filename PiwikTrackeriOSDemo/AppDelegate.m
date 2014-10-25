//
//  AppDelegate.m
//  PiwikTrackeriOSDemo
//
//  Created by Mattias Levin on 9/16/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "AppDelegate.h"
#import "PiwikTracker.h"
#import "MenuViewController.h"


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
  return [[PiwikTracker sharedInstance] sendCampaign:[url absoluteString]];  
}


- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
