//
//  PiwikTransactionItem.h
//  PiwikTracker
//
//  Created by Mattias Levin on 19/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 An item added to a transaction.
 @see PiwikTransaction
 */
@interface PiwikTransactionItem : NSObject


/**
 The name of the item.
 */
@property (readonly) NSString *name;

/**
 The unique SKU of the item,
 */
@property (readonly) NSString *sku;

/**
 Item category.
 */
@property (readonly) NSString *category;

/**
 Item price.
 */
@property (readonly) NSUInteger price;

/**
 Item quantity.
 */
@property (readonly) NSUInteger quantity;


/**
 Create an item to be added to a transaction.
 
 @param name The name of the item
 @param sku The unique SKU of the item
 @param category The category of the added item
 @param price The price
 @param quantity The quantity of the product in the transaction
 @return A transaction item
 @See PiwikTransactionBuilder
 @see PiwikTransaction
 */
+ (instancetype)itemWithName:(NSString*)name
                         sku:(NSString*)sku
                    category:(NSString*)category
                       price:(NSUInteger)price
                    quantity:(NSUInteger)quantity;


@end
