//
//  NVBBeaconMonitoringService.h
//  Invibe
//
//  Created by Alexandru Chis on 16/03/14
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@class CoreLocation;

@interface NVBBeaconMonitoringService : NSObject <CBCentralManagerDelegate, CLLocationManagerDelegate>

+ (NVBBeaconMonitoringService *)sharedInstance;

- (void) startServices;

@end
