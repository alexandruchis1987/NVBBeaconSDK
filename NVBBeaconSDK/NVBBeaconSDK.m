//
//  NVBBeaconSDK.m
//  NVBBeaconSDK
//
//  Created by An Phan on 1/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import "NVBBeaconSDK.h"

@implementation NVBBeaconSDK

+ (void)setApplicationIdentifier:(NSString *)clientKey {
    if (clientKey.length == 0) {
//        DEBUG_LOG(@"'clientKey' should not be nil.");
        NSLog(@"'clientKey' should not be nil.");
    }
    NSAssert([clientKey length] > 0, @"'clientKey' should not be nil.");
}

@end
