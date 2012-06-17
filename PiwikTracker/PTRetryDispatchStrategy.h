//
//  PTRetryDispatchStrategy.h
//
//  Created by Mattias Levin on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiwikTracker.h"

/**
 This class implement a strategy to automatically perform repeated dispatch retries (until a specified limit) if a dispatch fails.
 */
@interface PTRetryDispatchStrategy : NSObject


/**
 Create a new instance the the PTRetryDispatchStrategy
 @param errorBlock An error block that will be run when the strategy is not able to manage an error returned from the SDK internally
 @return a new instance the the PTRetryDispatchStrategy
 */
+ (PTRetryDispatchStrategy*)strategyWithErrorBlock:(void(^)(NSError* error))errorBlock;


/**
 The maximum number of retries the strategy should perform.
 */
@property (nonatomic) NSInteger maxNumberOfRetries;

/**
 The time interval between the dispatches.
 */
@property (nonatomic) NSTimeInterval retryTimeInterval;


@end
