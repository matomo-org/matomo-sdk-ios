//
//  PTLocationManagerWrapper.h
//  PiwikTracker
//
//  Created by Mattias Levin on 10/13/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface PTLocationManagerWrapper : NSObject

- (void)startMonitoringLocationChanges;
- (void)stopMonitoringLocationChanges;
- (CLLocation*)location;

@end

