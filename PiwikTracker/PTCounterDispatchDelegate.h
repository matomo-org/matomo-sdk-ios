
//
//  PiwikCounterObserver.h
//  PiwikTestApp
//
//  Created by Mattias Levin on 1/2/12.
//  Copyright 2012 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiwikTracker.h"

/**
 This tracker delegate implement a strategy to automatically initiate a dispatch when there are more
 cached events when a certain trigger values.
 */
@interface PTCounterDispatchDelegate : NSObject <PiwikTrackerDelegate>

/**
 The number cached events that will trigger a dispatch. Default value is 10.
 */
@property (nonatomic) NSInteger triggerValue;

@end
