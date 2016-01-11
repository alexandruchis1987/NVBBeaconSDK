//
//  NVBLogger.h
//  NVBBeaconSDK
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright © 2016 Alex. All rights reserved.
//
#import <Foundation/Foundation.h>

#define NVBLog(frmt, ...) \
[[NVBLogger sharedLogger] logMessageWithFormat:(frmt), ##__VA_ARGS__]

@interface NVBLogger : NSObject

///--------------------------------------
/// @name Shared Logger
///--------------------------------------

/**
 A shared instance of `NVBLogger` that should be used for all logging.
 
 @return An shared singleton instance of `NVBLogger`.
 */
+ (instancetype)sharedLogger;

///--------------------------------------
/// @name Logging Messages
///--------------------------------------

/**
 Logs a message to the console log.
 
 @param object Format to use for the log message.
 */
- (void)logMessageWithFormat:(NSString *)format, ...;


@end
