//
//  PiwikTransaction.m
//  PiwikTracker
//
//  Created by Mattias Levin on 19/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "PiwikTransaction.h"
#import "PiwikTransactionItem.h"


@implementation PiwikTransaction


+ (instancetype)transactionWithIdentifier:(NSString*)identifier
                                    total:(NSUInteger)total
                                      tax:(NSUInteger)tax
                                 shipping:(NSUInteger)shipping
                                 discount:(NSUInteger)discount
                                    items:(NSArray*)items {

  return [[PiwikTransaction alloc] initWithIdentifier:identifier total:total tax:tax shipping:shipping discount:discount items:items];
  
}


- (id)initWithIdentifier:(NSString*)identifier
                   total:(NSUInteger)total
                     tax:(NSUInteger)tax
                shipping:(NSUInteger)shipping
                discount:(NSUInteger)discount
                   items:(NSArray*)items {
  
  self = [super init];
  if (self) {
    _identifier = identifier;
    _total = total;
    _tax = tax;
    _shipping = shipping;
    _discount = discount;
    _items = items;
  }
  return self;
  
}

- (BOOL)isValid {
  
  BOOL isTransactionValid = self.identifier.length > 0;
  
  __block BOOL isAllItemsValid = YES;
  [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
    PiwikTransactionItem *item = (PiwikTransactionItem*)obj;
    if (!item.isValid) {
      isAllItemsValid = NO;
      *stop = YES;
    }
    
  }];
  
  return isTransactionValid && isAllItemsValid;
}

@end
