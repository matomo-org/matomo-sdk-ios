//
//  UserIDViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 16/10/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "UserIDViewController.h"
#import "PiwikTracker.h"


@interface UserIDViewController ()
@end


@implementation UserIDViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self toggleState];
}

- (void)toggleState {
  
  self.userIDTextField.text = [PiwikTracker sharedInstance].userID;
  
  NSString *userID = [PiwikTracker sharedInstance].userID;
  if (userID && userID.length > 0) {
    self.signinButton.enabled = NO;
    self.singoutButton.enabled = YES;
  } else {
    self.signinButton.enabled = YES;
    self.singoutButton.enabled = NO;
  }
  
}


- (IBAction)signinAction:(id)sender {
  NSLog(@"Sign in");
  
  if (self.userIDTextField.text && self.userIDTextField.text.length > 0) {
    [PiwikTracker sharedInstance].userID = self.userIDTextField.text;
    [self toggleState];
  }
  
}


- (IBAction)signOutAction:(id)sender {
  NSLog(@"Sign out");
  
  [PiwikTracker sharedInstance].userID = nil;
  [self toggleState];
  
}


@end
