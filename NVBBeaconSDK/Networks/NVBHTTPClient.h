//
//  NVBHTTPClient.h
//  NVBBeaconSDK
//
//  Created by An Phan on 1/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

// Define respone blocks for networking
typedef void (^NVBHTTPClientResponseSuccessedBlock)(id response);
typedef void (^NVBHTTPClientResponseFailedBlock)(NSError *error);

@interface NVBHTTPClient : AFHTTPSessionManager

#pragma mark - Lifecycle methods
+ (NVBHTTPClient *)sharedNVBHTTPClient;

#pragma mark - API methods
- (void)testingConnectAPIWithSuccessBlock:(NVBHTTPClientResponseSuccessedBlock)successedBlock
                              failedBlock:(NVBHTTPClientResponseFailedBlock)failedBlock;

@end
