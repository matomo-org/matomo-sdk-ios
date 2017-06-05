//
//  CustomVariablesViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 17/08/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "CustomVariablesViewController.h"
#import "PiwikTracker.h"


@implementation CustomVariablesViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}


- (IBAction)customVariableAAction:(id)sender {
  
  NSArray *values = @[@"Member", @"Admin", @"Anonymous"];
  
  [[PiwikTracker sharedInstance] setCustomVariableForIndex:4 name:@"CustomA" value:values[arc4random_uniform(3)] scope:VisitCustomVariableScope];
}


- (IBAction)CustomVariableBAction:(id)sender {
  
  NSArray *values = @[@"Computers", @"Keyboard", @"Mouse"];
  
  [[PiwikTracker sharedInstance] setCustomVariableForIndex:1 name:@"Custom B" value:values[arc4random_uniform(3)] scope:ScreenCustomVariableScope];
}


@end
