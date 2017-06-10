//
//  OptOutViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 9/17/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "OptOutViewController.h"
#import "PiwikTracker.h"


@interface OptOutViewController ()
@end


@implementation OptOutViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.optOutSwitch.on = ![PiwikTracker sharedInstance].optOut;
  
}


- (IBAction)sendOptOutAction:(id)sender {
  
  UISwitch *option = (UISwitch*)sender;
  
  if (option.on) {
    
    [PiwikTracker sharedInstance].optOut = NO;
    
  } else {
    
    [PiwikTracker sharedInstance].optOut = YES;
    
  }
  
}


@end
