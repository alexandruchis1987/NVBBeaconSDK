//
//  NVBBeaconSDK.h
//  NVBBeaconSDK
//
//  Created by An Phan on 1/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NVBLocationManager.h"
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

@end
