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
 Start the dispatch timer.
 */
- (void)startDispatchTimer;

/**
 Stop the dispatch timer.
 */
- (void)stopDispatchTimer;

/**
 The time interval between the dispatches.
 Default value is 3 minutes of not set.
 */
@property (nonatomic) NSTimeInterval timeInteraval; 

/**
 Is the timer running?
 */
@property (nonatomic) BOOL isRunning;

@end
