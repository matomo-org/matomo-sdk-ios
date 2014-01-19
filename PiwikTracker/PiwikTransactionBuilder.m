//
//  PiwikTransactionBuilder.m
//  PiwikTracker
//
//  Created by Mattias Levin on 19/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "PiwikTransactionBuilder.h"
#import "PiwikTransaction.h"
#import "PiwikTransactionItem.h"


@interface PiwikTransactionBuilder ()

@property (readonly) NSString *identifier;
@property (readonly) NSUInteger total;
@property (readonly) NSUInteger tax;
@property (readonly) NSUInteger shipping;
@property (readonly) NSUInteger discount;
@property (readonly) NSMutableArray *items;


@end



@implementation PiwikTransactionBuilder


+ (instancetype)builderWithTransactionIdentifier:(NSString*)identifier total:(NSUInteger)total {
  
  return [self builderWithTransactionIdentifier:identifier total:total tax:0 shipping:0 discount:0];
  
}


+ (instancetype)builderWithTransactionIdentifier:(NSString*)identifier
                                           total:(NSUInteger)total
                                             tax:(NSUInteger)tax
                                        shipping:(NSUInteger)shipping
                                        discount:(NSUInteger)discount {
  
  return [[PiwikTransactionBuilder alloc] initWithTransactionIdentifier:identifier total:total tax:tax shipping:shipping discount:discount];
  
}


- (id)initWithTransactionIdentifier:(NSString*)identifier
                              total:(NSUInteger)total
                                tax:(NSUInteger)tax
                           shipping:(NSUInteger)shipping
                           discount:(NSUInteger)discount {
  self = [super init];
  if (self) {
    _identifier = identifier;
    _total = total;
    _tax = tax;
    _shipping = shipping;
    _discount = discount;
    _items = [NSMutableArray array];
  }
  return self;
  
}


- (PiwikTransactionBuilder*)addItemWithName:(NSString*)name price:(NSUInteger)price quantity:(NSUInteger)quantity {
  
  return [self addItemWithName:name sku:nil category:nil price:0 quantity:0];
  
}


- (PiwikTransactionBuilder*)addItemWithName:(NSString*)name
                                        sku:(NSString*)sku
                                   category:(NSString*)category
                                      price:(NSUInteger)price
                                   quantity:(NSUInteger)quantity {
  
  PiwikTransactionItem *item = [PiwikTransactionItem itemWithName:name sku:sku category:category price:price quantity:quantity];
  [_items addObject:item];
  
  return self;
  
}


- (PiwikTransaction*)build {
  
  return [PiwikTransaction transactionWithIdentifier:self.identifier
                                               total:self.total
                                                 tax:self.tax
                                            shipping:self.shipping
                                            discount:self.discount
                                               items:self.items];
  
}

@end
