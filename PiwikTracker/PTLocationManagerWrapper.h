//
//  PTLocationManagerWrapper.h
//  PiwikTracker
//
//  Created by Mattias Levin on 10/13/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PTLocation;

@interface PTLocationManagerWrapper : NSObject

- (void)startMonitoringLocationChanges;
- (void)stopMonitoringLocationChanges;
- (id<PTLocation>)location;

@end


@protocol PTLocation <NSObject>

@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;

@end