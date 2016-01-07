//
//  NVBBeaconSDK.h
//  NVBBeaconSDK
//
//  Created by An Phan on 1/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//

@interface NVBBeaconSDK : NSObject

/**
 Sets the clientKey of your application.
 
 @param clientKey The client key of your NVBBeaconSDK application.
 */
+ (void)setApplicationIdentifier:(NSString *)clientKey;

@end
