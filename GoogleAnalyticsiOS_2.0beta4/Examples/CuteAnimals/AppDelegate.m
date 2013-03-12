//
//  AppDelegate.m
//  CuteAnimals
//
//  Copyright 2012 Google, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "NavController.h"
#import "RootViewController.h"

/******* Set your tracking ID here *******/
static NSString *const kTrackingId = @"UA-TRACKING-ID";

@interface AppDelegate ()

- (NSDictionary *)loadImages;

@end

@implementation AppDelegate

@synthesize window = window_;
@synthesize navController = navController_;
@synthesize viewController = viewController_;
@synthesize tracker = tracker_;
@synthesize images = images_;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.images = [self loadImages];

  // Initialize Google Analytics with a 120-second dispatch interval. There is a
  // tradeoff between battery usage and timely dispatch.
  [GAI sharedInstance].debug = YES;
  [GAI sharedInstance].dispatchInterval = 120;
  [GAI sharedInstance].trackUncaughtExceptions = YES;
  self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];

  self.window =
      [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]
       autorelease];
  // Override point for customization after application launch.
  self.viewController =
      [[[RootViewController alloc] initWithNibName:@"RootViewController"
                                            bundle:nil] autorelease];

  self.navController =
      [[[NavController alloc] initWithRootViewController:self.viewController]
       autorelease];
  self.navController.delegate = self.navController;

  self.viewController.navController = self.navController;
  self.window.rootViewController = self.navController;
  [self.window makeKeyAndVisible];

  return YES;
}

- (void)dealloc {
  [tracker_ release];
  [viewController_ release];
  [navController_ release];
  [window_ release];
  [super dealloc];
}

- (NSDictionary *)loadImages {
  NSArray *contents = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg"
                                                         inDirectory:nil];
  if (!contents) {
    NSLog(@"Failed to load directory contents");
    return nil;
  }
  NSMutableDictionary *images = [NSMutableDictionary dictionaryWithCapacity:0];
  for (NSString *file in contents) {
    NSArray *components = [[file lastPathComponent]
                           componentsSeparatedByString:@"-"];
    if (components.count == 0) {
      NSLog(@"Filename doesn't contain dash: %@", file);
      continue;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:file];
    if (!image) {
      NSLog(@"Failed to load file: %@", file);
      continue;
    }
    NSString *prefix = [components objectAtIndex:0];
    NSMutableArray *categoryImages = [images objectForKey:prefix];
    if (!categoryImages) {
      categoryImages = [NSMutableArray arrayWithCapacity:0];
      [images setObject:categoryImages
                 forKey:prefix];
    }
    [categoryImages addObject:image];
  }
  for (NSString *cat in [images allKeys]) {
    NSArray *array = [images objectForKey:cat];
    NSLog(@"Category %@: %u image(s).", cat, array.count);
  }
  return images;
}

@end
