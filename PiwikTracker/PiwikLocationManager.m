//
//  PiwikLocationManager.m
//  PiwikTracker
//
//  Created by Mattias Levin on 10/13/13.
//  Copyright (c) 2013 Mattias Levin. All rights reserved.
//

#import "PiwikLocationManager.h"


@interface PiwikLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL startMonitoringOnNextLocationRequest;
@property (nonatomic) BOOL isMonitorLocationChanges;

@end


@implementation PiwikLocationManager


- (id)init {
  self = [super init];
  if (self) {
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
  }
  return self;
}


- (void)startMonitoringLocationChanges {
  
  // If the app already have permission to track user location start monitoring. Otherwise wait untill the first location is requested
  // Do this to avoid asking for permission directly when the app starts
  // This will allow the app to to ask for permission at a controlled point in the application flow
  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized &&
      [CLLocationManager locationServicesEnabled]) {
    [self _startMonitoringLocationChanges];
  } else {
    self.startMonitoringOnNextLocationRequest = YES;
  }
  
}

- (void)_startMonitoringLocationChanges {
  self.isMonitorLocationChanges = YES;

#if TARGET_OS_IPHONE
  
  // Use significant change location service for iOS
  [self.locationManager startMonitoringSignificantLocationChanges];
  
#else
  
  // User standard service for OSX
  self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
  self.locationManager.distanceFilter = 500; // meters
  [self.locationManager startUpdatingLocation];
  
#endif
  
}


- (void)stopMonitoringLocationChanges {
  self.isMonitorLocationChanges = NO;

#if TARGET_OS_IPHONE
  
  // Use significant change location service for iOS
  [self.locationManager stopMonitoringSignificantLocationChanges];
  
#else
  
  // User standard service for OSX  
  [self.locationManager stopUpdatingLocation];
  
#endif
  
}


- (CLLocation*)location {
  
  if (self.startMonitoringOnNextLocationRequest &&
      !self.isMonitorLocationChanges &&
      [CLLocationManager locationServicesEnabled] &&
      [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted &&
      [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
    
    [self _startMonitoringLocationChanges];
  
  }
  
  // Will return nil if the location monitoring has not been started
  return self.locationManager.location;
  
}


#pragma mark - core location delegate methods

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray*)locations {
  // Do nothing
}


- (void)locationManager:(CLLocationManager*)manager monitoringDidFailForRegion:(CLRegion*)region withError:(NSError*)error {
  // Do nothing
}


@end