//
//  PiwikTransaction.m
//  PiwikTracker
//
//  Created by Mattias Levin on 19/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "PiwikTransaction.h"

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

@end
