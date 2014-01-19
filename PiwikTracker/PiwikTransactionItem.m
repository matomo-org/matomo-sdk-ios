//
//  PiwikTransactionItem.m
//  PiwikTracker
//
//  Created by Mattias Levin on 19/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "PiwikTransactionItem.h"

@implementation PiwikTransactionItem


+ (instancetype)itemWithName:(NSString*)name
                         sku:(NSString*)sku
                    category:(NSString*)category
                       price:(NSUInteger)price
                    quantity:(NSUInteger)quantity {
  
  return [[PiwikTransactionItem alloc] initWithName:name sku:sku category:category price:price quantity:quantity];
  
}


- (id)initWithName:(NSString*)name sku:(NSString*)sku category:(NSString*)category price:(NSUInteger)price quantity:(NSUInteger)quantity {
  
  self = [super init];
  if (self) {
    _name = name;
    _category = category;
    _price = price;
    _quantity = quantity;
  }
  return self;
  
}


@end
