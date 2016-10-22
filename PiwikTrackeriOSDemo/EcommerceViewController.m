//
//  EcommerceViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 26/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "EcommerceViewController.h"

@import PiwikTrackerSwift;

static NSUInteger const ItemPrice = 1;

@implementation EcommerceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[PiwikTracker sharedInstance] sendViews:@[@"menu", @"transaction"]];
    
    // Start with one items
    self.numberOfItemsTextField.text = @"1";
    
    [self calculateCost];
}

- (IBAction)stepNumberOfItemsAction:(UIStepper *)sender {
    self.numberOfItemsTextField.text = [NSString stringWithFormat:@"%.0f", sender.value];
    [self calculateCost];
}

- (IBAction)purchaseAction:(id)sender {
    TransactionItem *item = [[TransactionItem alloc] initWithSku:@"SKU123" name:@"Cookies" category:@"Food" price:1.0 quantity:[self.numberOfItemsTextField.text integerValue]];
    
    Transaction *transaction = [[Transaction alloc] initWithIdentifier:[NSString stringWithFormat:@"Trans-%d", arc4random_uniform(1000)] revenue:[self.totalCostLabel.text floatValue] tax:[self.taxLabel.text floatValue] shippingCost:[self.shippingCostLabel.text floatValue] discount:0 items:@[item]];
    
    [[PiwikTracker sharedInstance] sendTransaction:transaction];
}

- (void)calculateCost {
    int numberOfItems = (int)[self.numberOfItemsTextField.text integerValue];
    
    int totalCost = numberOfItems * ItemPrice;
    
    self.totalCostLabel.text = [NSString stringWithFormat:@"%d", totalCost];
    self.taxLabel.text = [NSString stringWithFormat:@"%.1f", totalCost * 0.3];
    self.shippingCostLabel.text = [NSString stringWithFormat:@"%.1f", MAX(1, (numberOfItems / 3)) * 0.1];
}

@end
