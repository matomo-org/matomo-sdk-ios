//
//  PTLocationManagerWrapper.m
//  PiwikTracker
//
//  Created by Mattias Levin on 10/13/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "PTLocationManagerWrapper.h"
#if TARGET_OS_IPHONE
#import <CoreLocation/CoreLocation.h>
#endif

#define TARGET_OSX TARGET_OS_IPHONE == 0


#if TARGET_OSX
// The OSX target does nothing

@implementation PTLocationManagerWrapper

- (void)startMonitoringLocationChanges {
}

- (void)stopMonitoringLocationChanges {
}

- (id<PTLocation>)location {
  return nil;
}

@end


#else

@interface PTLocationImpl : NSObject <PTLocation>

- (id)initWithCLLocationCoordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;

@end


@interface PTLocationManagerWrapper () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end


@implementation PTLocationManagerWrapper

- (id)init {
  self = [super init];
  if (self) {
    [self startLocationManager];
  }
  return self;
}


- (void)startMonitoringLocationChanges {
  [self.locationManager startMonitoringSignificantLocationChanges];
}


- (void)stopMonitoringLocationChanges {
  [self.locationManager stopMonitoringSignificantLocationChanges];
}


- (id<PTLocation>)location {  
  CLLocation *location = self.locationManager.location;
  return [[PTLocationImpl alloc] initWithCLLocationCoordinate:location.coordinate];
}

- (void)startLocationManager {
  
  if (self.locationManager) {
    
    if ([CLLocationManager locationServicesEnabled] &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
      
      self.locationManager = [[CLLocationManager alloc] init];
      self.locationManager.delegate = self;
      
    }
    
  }
  
}


#pragma mark - core location delegate methods

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray*)locations {
  // Do nothing right now
}


- (void)locationManager:(CLLocationManager*)manager monitoringDidFailForRegion:(CLRegion*)region withError:(NSError*)error {
  // Do nothing
}


@end


@implementation PTLocationImpl

- (id)initWithCLLocationCoordinate:(CLLocationCoordinate2D)coordinate {
  self = [super init];
  if (self) {
    _latitude = coordinate.latitude;
    _longitude = coordinate.longitude;
  }
  return self;
}

@end


#endif

