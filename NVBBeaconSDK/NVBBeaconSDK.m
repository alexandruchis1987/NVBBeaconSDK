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

+ (void)setClientId:(NSString *)clientId andClientSecret:(NSString*)clientSecret; {
    if (clientId.length == 0) {
        DDLogDebug(@"'Client Id' should not be empty.");
    }
    if (clientSecret.length == 0) {
        DDLogDebug(@"'Client Secret' should not be empty.");
    }
    
    NSAssert([clientId length] > 0, @"'Client Id' should not be nil.");
    NSAssert([clientSecret length] > 0, @"'Client Id' should not be nil.");
    
    
    [[NVBDataStore sharedInstance] registerWithClientId:clientId andClientSecret:clientSecret andCompletionBlock:^(BOOL success, NSString *error) {
        if (success)
        {
            //to be taken out new
            [Parse setApplicationId:@"MJb510v5gLlSDUe1Xa5nEXUHSEW2nRELancVGJWi" clientKey:@"2hmUm0BlQCvu4PM6am8wCu2HABPYbgdfsI9ouQid"];
            
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            
            [currentInstallation setDeviceTokenFromData:[[NVBBeaconSDK sharedNVBBeaconSDK] deviceToken]];
            currentInstallation.channels = @[@"global"];
            [currentInstallation saveInBackground];

            [[NVBBeaconMonitoringService sharedInstance] startServices];
            
        }
        else
        {
            DDLogError(error);
        }
    }];

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

    [[self sharedNVBBeaconSDK] setDeviceToken:deviceToken];
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
