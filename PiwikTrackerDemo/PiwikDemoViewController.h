//
//  ViewController.h
//  PiwikTrackerDemo
//
//  Created by Mattias Levin on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PiwikDemoViewController : UIViewController


- (IBAction)generateEvent1:(id)sender;
- (IBAction)generateEvent2:(id)sender;
- (IBAction)generateEventWithCategoryAndName:(id)sender;
- (IBAction)trackGoal:(id)sender;

- (IBAction)deleteEvents:(id)sender;
- (IBAction)dispatchEvents:(id)sender;

@end
