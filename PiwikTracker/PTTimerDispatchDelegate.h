//
//  PTTimerDispatchObserver.h
//  PiwikTestApp
//
//  Created by Mattias Levin on 5/15/12.
//  Copyright (c) 2012 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiwikTracker.h"

/**
 This tracker delegate implement a strategy to automatically initiate a dispatch after
 a certain time interval.
 */
@interface PTTimerDispatchDelegate : NSObject <PiwikTrackerDelegate>

/**
 The time interval between the dispatches.
 */
@property (nonatomic) NSTimeInterval timeInteraval; 

/**
 Start and stop the timer.
 */
@property (nonatomic) BOOL startDispatchTimer;

@end
