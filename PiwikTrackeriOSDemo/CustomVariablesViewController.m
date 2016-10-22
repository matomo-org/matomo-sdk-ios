//
//  CustomVariablesViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 17/08/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "CustomVariablesViewController.h"
@import PiwikTrackerSwift;

@implementation CustomVariablesViewController

- (IBAction)customVariableAAction:(id)sender {
    NSArray *values = @[@"Member", @"Admin", @"Anonymous"];
    [[PiwikTracker sharedInstance] setCustomVariableForIndex:4 name:@"CustomA" value:values[arc4random_uniform(3)] scope:CustomVariableScopeVisit];
}

- (IBAction)CustomVariableBAction:(id)sender {
    NSArray *values = @[@"Computers", @"Keyboard", @"Mouse"];
    [[PiwikTracker sharedInstance] setCustomVariableForIndex:1 name:@"Custom B" value:values[arc4random_uniform(3)] scope:CustomVariableScopeScreen];
}

@end
