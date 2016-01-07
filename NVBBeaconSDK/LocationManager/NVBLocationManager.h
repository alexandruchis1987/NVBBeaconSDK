//
//  NVBLocationManager.h
//  NVBBeaconSDK
//
//  Created by An Phan on 1/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

/**
 * Talks with the built in GPS.
 */

@protocol NVBLocationManagerDelegate <NSObject>

/**
 Called when location data is received.
 @param location location that was acquired
 */
- (void)locationDetected:(CLLocation *)location;

/**
 Called when location cannot be found.
 @param error error which occured while getting locations.
 */
- (void)locationDiscoveryFailed:(NSError *)error;

@end

@interface NVBLocationManager : NSObject

#pragma mark - Properties
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) id<NVBLocationManagerDelegate> delegate;

#pragma mark - Methods
- (void)startLocationUpdate;
- (void)stopLocationUpdate;

@end
