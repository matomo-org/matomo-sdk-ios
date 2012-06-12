//
//  PTRetryDispatchDelegate.h
//  PiwikTestApp
//
//  Created by Mattias Levin on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiwikTracker.h"

/**
 This tracker delegate implement a strategy to automatically perform repeated dispatch retries
 if a dispatch fails.
 */
@interface PTRetryDispatchDelegate : NSObject <PiwikTrackerDelegate>

@property (nonatomic) NSInteger maxNumberOfRetries;
@property (nonatomic) NSTimeInterval retryTimeInterval;

@end
