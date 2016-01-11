//
//  NVBBeaconSDK.h
//  NVBBeaconSDK
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright © 2016 Alex. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NVBHTTPClient.h"
#import "NVBLogger.h"

@interface NVBBeaconSDK : NSObject

@property (nonatomic, getter=isEnableDebugMode) BOOL enableDebugMode;

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


@end
