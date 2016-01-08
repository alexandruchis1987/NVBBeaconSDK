//
//  NVBBeaconSDK.m
//  NVBBeaconSDK
//
//  Created by An Phan on 1/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import "NVBBeaconSDK.h"
#import "NVBLogger.h"

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
        NVBLog(@"'clientKey' should not be nil.");
    }
    NSAssert([clientKey length] > 0, @"'clientKey' should not be nil.");
}

@end
