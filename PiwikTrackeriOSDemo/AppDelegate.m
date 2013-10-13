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


static NSString * const PiwikServerURL = @"http://localhost/~mattias/piwik/";
static NSString * const PiwikSiteID = @"2";
static NSString * const PiwikAuthenticationToken = @"5d8e854ebf1cc7959bb3b6d111cc5dd6";



@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [[NSUserDefaults standardUserDefaults] registerDefaults:@{PiwikAskedForPermissonKey : @(NO)}];
    
  // Initialize the Piwik Tracker
  [PiwikTracker sharedInstanceWithBaseURL:[NSURL URLWithString:PiwikServerURL] siteID:PiwikSiteID authenticationToken:PiwikAuthenticationToken];
  
  // Configure the tracker
  //[PiwikTracker sharedInstance].debug = YES;
  [PiwikTracker sharedInstance].dispatchInterval = 0;
  
  return YES;
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
