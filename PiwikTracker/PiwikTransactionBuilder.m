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


@implementation PiwikTransactionBuilder


- (void)addItemWithName:(NSString*)name price:(NSUInteger)price quantity:(NSUInteger)quantity {
  [self addItemWithName:name sku:nil category:nil price:price quantity:quantity];
}


- (void)addItemWithName:(NSString*)name
                    sku:(NSString*)sku
               category:(NSString*)category
                  price:(NSUInteger)price
               quantity:(NSUInteger)quantity {
  
  PiwikTransactionItem *item = [PiwikTransactionItem itemWithName:name sku:sku category:category price:price quantity:quantity];
  [self.items addObject:item];
}


- (PiwikTransaction*)build {
  
  // Verify that mandatory parameters have been set
  __block BOOL isTransactionValid = self.identifier.length > 0;
  
  [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    PiwikTransactionItem *item = (PiwikTransactionItem*)obj;
    if (!item.isValid) {
      isTransactionValid = NO;
      *stop = YES;
    }
  }];
  
  if (isTransactionValid) {
    return [[PiwikTransaction alloc] initWithBuilder:self];
  } else {
    NSLog(@"Failed to build transaction, missing mandatory parameters");
    return nil;
  }
  
}


@end
