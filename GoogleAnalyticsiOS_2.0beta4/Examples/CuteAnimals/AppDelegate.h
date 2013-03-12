//
//  AppDelegate.h
//  CuteAnimals
//
//  Copyright 2012 Google, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAI.h"

@class RootViewController;
@class NavController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic, retain) UIWindow *window;
@property(nonatomic, retain) NavController *navController;
@property(nonatomic, retain) RootViewController *viewController;
@property(nonatomic, retain) id<GAITracker> tracker;
@property(nonatomic, retain) NSDictionary *images;

@end
