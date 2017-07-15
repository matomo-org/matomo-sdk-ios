//
//  OptOutViewController.h
//  PiwikTracker
//
//  Created by Mattias Levin on 9/17/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptOutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *optOutSwitch;

- (IBAction)sendOptOutAction:(id)sender;

@end
