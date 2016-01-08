//
//  NVBLocationManager.m
//  NVBBeaconSDK
//
//  Created by An Phan on 1/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import "NVBLocationManager.h"
#import "NVBLogger.h"

@interface NVBLocationManager () <CLLocationManagerDelegate>

@end

@implementation NVBLocationManager

- (instancetype)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 1.0;
        _locationManager.delegate = self;
    }
    
    return self;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Helper methods **

/**
 * Tells the location manager to start updating the user's location
 */
- (void)startLocationUpdate {
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

/**
 * Stops the location manager to update the location
 */
- (void)stopLocationUpdate {
    [self.locationManager stopUpdatingLocation];
}

//*****************************************************************************
#pragma mark -
#pragma mark ** CLLocationManagerDelegate **

/**
 * Tells the delegate that the location manager was unable to retrieve a location value.
 * @param manager The location manager object that was unable to retrieve the location.
 * @param error The error object containing the reason the location or heading could not be retrieved.
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self stopLocationUpdate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationDiscoveryFailed:)]) {
        [self.delegate locationDiscoveryFailed:error];
    }
}

/**
 * Tells the delegate that new location data is available.
 * @param manager The location manager object that generated the update event.
 * @param locations An array of CLLocation objects containing the location data. This array always contains at least one object representing the current location.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self stopLocationUpdate];

    if (self.delegate && [self.delegate respondsToSelector:@selector(locationDetected:)]) {
        [self.delegate locationDetected:locations[0]];
        NVBLog(@"Location: %@", locations[0]);
    }
}

@end
