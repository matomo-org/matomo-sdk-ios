//
//  EcommerceViewController.m
//  PiwikTracker
//
//  Created by Mattias Levin on 26/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "EcommerceViewController.h"
#import "PiwikTransaction.h"
#import "PiwikTransactionBuilder.h"
#import "PiwikTracker.h"


static NSUInteger const ItemPrice = 1;


@implementation EcommerceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Start with one items
  self.numberOfItemsTextField.text = @"1";
  
  [self calculateCost];
  
}


- (IBAction)stepNumberOfItemsAction:(UIStepper *)sender {
  
  self.numberOfItemsTextField.text = [NSString stringWithFormat:@"%.0f", sender.value];
  
  [self calculateCost];
  
}


- (IBAction)purchaseAction:(id)sender {
  
  PiwikTransaction *transaction = [PiwikTransaction transactionWithBuilder:^(PiwikTransactionBuilder *builder) {

    builder.identifier = @"T123";
    builder.total = [self.totalCostLabel.text integerValue];
    builder.tax = [self.taxLabel.text integerValue];
    builder.shipping = [self.shippingCostLabel.text integerValue];
    builder.discount = 0;
    
    [builder addItemWithName:@"Cookies"
                         sku:@"SKU123"
                    category:@"Food"
                       price:1
                    quantity:[self.numberOfItemsTextField.text integerValue]];
  }];
  
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
