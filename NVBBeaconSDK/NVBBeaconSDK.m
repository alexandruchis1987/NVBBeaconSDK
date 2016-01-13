//
//  NVBBeaconSDK.m
//  NVBBeaconSDK
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import "NVBBeaconSDK.h"
#import "NVBDataStore.h"
#import "NVBBeaconMonitoringService.h"
#import <Parse/Parse.h>


@implementation NVBBeaconSDK

+ (instancetype)sharedNVBBeaconSDK {
    static NVBBeaconSDK *beaconSDK;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        beaconSDK = [[NVBBeaconSDK alloc] init];
    });
    return beaconSDK;
}

+ (void)setApplicationIdentifier:(NSString *)clientKey {
    if (clientKey.length == 0) {
        NSLog(@"'clientKey' should not be nil.");
    }
    NSAssert([clientKey length] > 0, @"'clientKey' should not be nil.");
    
    NSString *encodedHeader = [NSString stringWithFormat:@"Bearer %@", clientKey];
    [[NVBDataStore sharedInstance] setDefaultHeader:@"Authorization" value:encodedHeader];
}


/*!
 @abstract Starts the entire plaform services. Application Id is checked if it is provided
 */

+ (void) startServices
{
    //Launching the service handling the detection of the beacons and the entire campaign management
    
    //to be taken out
    [[NVBDataStore sharedInstance] startLocationServicesForeground];
    [[NVBBeaconMonitoringService sharedInstance] startServices];
}


/*!
 @abstract Stops the entire plaform services.
 */

+ (void) stopServices
{
    
}



/*!
 @abstract The current application id that was used to configure NVBBeacons framework.
 */
+ (NSString *)getApplicationId
{
    return @"";
}

+ (void)enableDebugMode
{
    [[NVBDataStore sharedInstance] enableDebugMode];
}



#pragma Push Notifications

/////////////////////////////////////////////////////////////////
/*
 * Methods related to push notifications
 */
/////////////////////////////////////////////////////////////////


+(void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    DDLogDebug (@"Successfully reigstered for remote notifications");
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}


+ (void) didReceiveRemoteNotification:(NSDictionary *)userInfo {

    DDLogDebug (@"Successfully reigstered for remote notifications");
    [PFPush handlePush:userInfo];
}

+ (void) didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    DDLogDebug (@"Successfully reigstered for remote notifications");
    [PFPush handlePush:userInfo];
    
}




@end
