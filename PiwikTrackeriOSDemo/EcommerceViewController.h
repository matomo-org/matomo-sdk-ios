//
//  EcommerceViewController.h
//  PiwikTracker
//
//  Created by Mattias Levin on 26/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EcommerceViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *numberOfItemsTextField;
@property (weak, nonatomic) IBOutlet UILabel *totalCostLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingCostLabel;


- (IBAction)stepNumberOfItemsAction:(UIStepper *)sender;
- (IBAction)purchaseAction:(id)sender;

@end
