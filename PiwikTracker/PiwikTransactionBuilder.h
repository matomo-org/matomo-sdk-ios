//
//  PiwikTransactionBuilder.h
//  PiwikTracker
//
//  Created by Mattias Levin on 19/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PiwikTransaction;


/**
 A transaction builder for building Piwik ecommerce transactions.
 A transaction contains information about the transaction as will as the items included in the transaction.
 */
@interface PiwikTransactionBuilder : NSObject


/**
 A unique transaction identifier.
 */
@property (nonatomic, strong) NSString *identifier;

/**
 The sub total of the transaction (excluding shipping cost).
 */
@property (nonatomic) NSUInteger total;

/**
 The total tax.
 */
@property (nonatomic) NSUInteger tax;

/**
 The total shipping cost
 */
@property (nonatomic) NSUInteger shipping;

/**
 The total offered discount.
 */
@property (nonatomic) NSUInteger discount;

/**
 A list of items included in the transaction.
 @see PiwikTransactionItem
 */
@property (nonatomic, strong) NSMutableArray *items;


/**
 Add a transaction item.
 
 @param name The name of the item
 @param sku The unique SKU of the item
 @param category The category of the added item
 @param price The price
 @param quantity The quantity of the product in the transaction
 */
- (void)addItemWithName:(NSString*)name
                    sku:(NSString*)sku
               category:(NSString*)category
                  price:(NSUInteger)price
               quantity:(NSUInteger)quantity;

/**
 Add a transaction item to the transaction.
 
 @param name The name of the item
 @param price The price
 @param quantity The quantity of the product in the transaction
 @see addItemWithName:sku:category:price:quantity:
 */
- (void)addItemWithName:(NSString*)name price:(NSUInteger)price quantity:(NSUInteger)quantity;


/**
 Build a transaction from the builder.
 @return a new transaction
 */
- (PiwikTransaction*)build;


@end
