//
//  UserIDViewController.h
//  PiwikTracker
//
//  Created by Mattias Levin on 16/10/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserIDViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet UIButton *singoutButton;

- (IBAction)signinAction:(id)sender;
- (IBAction)signOutAction:(id)sender;

@end
