//
//  NVBLogger.m
//  NVBBeaconSDK
//
//  Created by An Phan on 1/8/16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import "NVBLogger.h"
#import "NVBBeaconSDK.h"

@implementation NVBLogger

+ (instancetype)sharedLogger {
    static NVBLogger *logger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[NVBLogger alloc] init];
    });
    return logger;
}

- (void)logMessageWithFormat:(NSString *)format, ...; {
    if (![NVBBeaconSDK sharedNVBBeaconSDK].isEnableDebugMode) return;
    
    va_list args;
    va_start(args, format);
    va_end(args);
    NSLogv(format, args);
}

@end
