//
//  PiwikTransactionBuilder.h
//  PiwikTracker
//
//  Created by Mattias Levin on 19/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiwikTransaction.h"


/**
 A transaction builder for building Piwik ecommerce transactions.
 A transaction contains information about the transaction as will as the items included in the transaction.
 */
@interface PiwikTransactionBuilder : NSObject


/**
 Create an ecommerce transaction builder.
 
 Items included in the transaction must be added separately one by one.
 
 @param identifier A unique identifier
 @param total The sub total of the order (excluding shipping cost)
 @param tax The total tax
 @param shipping The total shipping cost
 @param discount The offered discount
 @return A transaction builder instance
 @see addItemWithName:sku:category:price:quantity:
 */
+ (instancetype)builderWithTransactionIdentifier:(NSString*)identifier
                                           total:(NSUInteger)total
                                             tax:(NSUInteger)tax
                                        shipping:(NSUInteger)shipping
                                        discount:(NSUInteger)discount;

/**
 Create an ecommerce transaction builder.
 
 This is a convenience method for creating a builder with only the transaction identity and total.
 
 @param identifier A unique identifier
 @param total The sub total of the order (excluding shipping cost)
 @return A transaction builder instance
 @see builderWithTransactionIdentifier:total
 */
+ (instancetype)builderWithTransactionIdentifier:(NSString*)identifier total:(NSUInteger)total;


/**
 Add an item to the transaction builder.
 
 @param name The name of the item
 @param sku The unique SKU of the item
 @param category The category of the added item
 @param price The price
 @param quantity The quantity of the product in the transaction
 @return A transaction builder instance
 */
- (PiwikTransactionBuilder*)addItemWithName:(NSString*)name
                                        sku:(NSString*)sku
                                   category:(NSString*)category
                                      price:(NSUInteger)price
                                   quantity:(NSUInteger)quantity;

/**
 Add an item to the transaction builder.
 
 This is a convenience method for adding an item with only a name, price and quantity.
 
 @param name The name of the item
 @param price The price
 @param quantity The quantity of the product in the transaction
 @return A transaction builder instance
 */
- (PiwikTransactionBuilder*)addItemWithName:(NSString*)name price:(NSUInteger)price quantity:(NSUInteger)quantity;



/**
 Create a transaction from the builder.
 @return A PiwikTranaction instance
 */
- (PiwikTransaction*)build;


@end
