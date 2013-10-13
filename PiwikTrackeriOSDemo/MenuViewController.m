//
//  MasterViewController.m
//  PiwikTrackeriOSDemo
//
//  Created by Mattias Levin on 9/16/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "MenuViewController.h"
#import "PiwikTracker.h"

@interface MenuViewController () <UIAlertViewDelegate>

@end


@implementation MenuViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Report screen view to Piwik
  [[PiwikTracker sharedInstance] sendView:@"menu"];
  
  if (![[NSUserDefaults standardUserDefaults] boolForKey:PiwikAskedForPermissonKey]) {
    // Firt time the user start the app
    // Ask for permission to track activities
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pivacy"
                                                        message:@"Depending on context ask the user for permission to track their activities the first time they start the app"
                                                       delegate:self
                                              cancelButtonTitle:@"Deny"
                                              otherButtonTitles:@"Allow", nil];
    [alertView show];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:PiwikAskedForPermissonKey];
    
  }
  
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  // Turn tracking off
  if (buttonIndex == 0) {
    [PiwikTracker sharedInstance].optOut = YES;
  } else {
    [PiwikTracker sharedInstance].optOut = NO;
  }
  
}







@end
