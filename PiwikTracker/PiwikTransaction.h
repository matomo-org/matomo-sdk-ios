//
//  PiwikTransaction.h
//  PiwikTracker
//
//  Created by Mattias Levin on 19/01/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PiwikTransactionBuilder;


typedef void (^TransactionBuilderBlock)(PiwikTransactionBuilder *builder);


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
 @see PiwikTransactionItem
 */
@property (readonly) NSArray *items;


/**
 Create a transaction using a transaction builder.
 @param block a transaction builder block
 @return a new transaction
 @see PiwikTransactionBuilder
 */
+ (instancetype)transactionWithBuilder:(TransactionBuilderBlock)block;


/**
 Create a transaction from the builder.
 Use the builder method to create a new instance.
 @return a new transaction
 @see transactionWithBuilder:
 */
- (id)initWithBuilder:(PiwikTransactionBuilder*)builder;


@end


