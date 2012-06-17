
//
//  PTCounterDispatchStrategy.h
//
//  Created by Mattias Levin on 1/2/12.
//  Copyright 2012 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiwikTracker.h"

/**
 This class implement a strategy that automatically initiate a dispatch when there are more cached events then a certain trigger value.
 */
@interface PTCounterDispatchStrategy : NSObject


/**
 Create a new instance the the PTCounterDispatchStrategy
 @param errorBlock An error block that will be run when the strategy is not able to manage an error returned from the SDK internally
 @return a new instance the the PTCounterDispatchStrategy
 */
+ (PTCounterDispatchStrategy*)strategyWithErrorBlock:(void(^)(NSError* error))errorBlock;


/**
 The number cached events that will trigger a dispatch. Default value is 10.
 */
@property (nonatomic) NSInteger triggerValue;

@end
