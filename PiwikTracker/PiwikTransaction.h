//
//  PiwikTransaction.h
//  PiwikTracker
//
//  Created by Mattias Levin on 19/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 A transaction is a composite object containing transaction information as well as an optional list of items included in the transaction.
 */
@interface PiwikTransaction : NSObject

/**
 A unique transaction identifier.
 */
@property (readonly) NSString *identifier;

/**
 The sub total of the transaction (excluding shipping cost).
 */
@property (readonly) NSUInteger total;

/**
 The total tax.
 */
@property (readonly) NSUInteger tax;

/**
 The total shipping cost
 */
@property (readonly) NSUInteger shipping;

/**
 The total offered discount.
 */
@property (readonly) NSUInteger discount;

/**
 A list of items included in the transaction.
 @PiwikTransactionItem
 */
@property (readonly) NSArray *items;


/**
 Create a single transaction.
 
 User the Piwik transaction builder to create transactions and included items.
 
 @param identifier A unique identifier
 @param total The sub total of the order (excluding shipping cost)
 @param tax The total tax
 @param shipping The total shipping cost
 @para discount The total offered discount
 @see PiwikTransactionBuilder
 @see PiwikTransactionItem
 */
+ (instancetype)transactionWithIdentifier:(NSString*)identifier
                                    total:(NSUInteger)total
                                      tax:(NSUInteger)tax
                                 shipping:(NSUInteger)shipping
                                 discount:(NSUInteger)discount
                                    items:(NSArray*)items;


@end


