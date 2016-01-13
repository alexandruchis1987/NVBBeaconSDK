//
//  NVBBeaconSDK.h
//  NVBBeaconSDK
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright © 2016 Alex. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NVBHTTPClient.h"

@interface NVBBeaconSDK : NSObject



///--------------------------------------
/// @name Shared NVBBeaconSDK
///--------------------------------------

/**
 A shared instance of `NVBBeaconSDK` that should be used for all logging.
 
 @return An shared singleton instance of `NVBBeaconSDK`.
 */
+ (instancetype)sharedNVBBeaconSDK;

/**
 Sets the clientKey of your application.
 
 @param clientKey The client key of your NVBBeaconSDK application.
 */
+ (void)setApplicationIdentifier:(NSString *)clientKey;



/*!
 @abstract Starts the entire plaform services. Application Id is checked if it is provided
 */

+ (void) startServices;


/*!
 @abstract Stops the entire plaform services.
 */

+ (void) stopServices;



/*!
 @abstract The current application id that was used to configure NVBBeacons framework.
 */
+ (NSString *)getApplicationId;


/*!
 @abstract Method used for enable debug mode for the library
 */
+ (void)enableDebugMode;


/*!
 @abstract Method which notifies parse that we successfully registered for push notifications
 */

+(void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;


/*!
 @abstract Method which handles the push notification
 */

+ (void) didReceiveRemoteNotification:(NSDictionary *)userInfo;

/*!
 @abstract Method which handles the push notification
 */

+ (void) didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(enum UIBackgroundFetchResult result))completionHandler;






@end
