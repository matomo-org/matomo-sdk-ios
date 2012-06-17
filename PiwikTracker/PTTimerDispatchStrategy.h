//
//  PTTimerDispatchStrategy.h
//
//  Created by Mattias Levin on 5/15/12.
//  Copyright (c) 2012 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiwikTracker.h"

/**
 This class implement a strategy to automatically initiate a dispatch after a certain time interval.
 */
@interface PTTimerDispatchStrategy : NSObject

/**
 Create a new instance the the PTTimerDispatchStrategy
 @param errorBlock An error block that will be run when the strategy is not able to manage an error returned from the SDK internally
 @return a new instance the the PTTimerDispatchStrategy
 */
+ (PTTimerDispatchStrategy*)strategyWithErrorBlock:(void(^)(NSError* error))errorBlock;

/**
 The time interval between the dispatches.
 */
@property (nonatomic) NSTimeInterval timeInteraval; 

/**
 Start and stop the timer.
 */
@property (nonatomic) BOOL startDispatchTimer;

@end
