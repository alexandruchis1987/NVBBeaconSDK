//
//  NVBHTTPClient.h
//  NVBBeaconSDK
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>


//to be taken out
// Define respone blocks for networking
//typedef void (^NVBHTTPClientResponseSuccessedBlock)(id response);
//typedef void (^NVBHTTPClientResponseFailedBlock)(NSError *error);
//
//@interface NVBHTTPClient : AFHTTPSessionManager
//
//#pragma mark - Lifecycle methods
//+ (NVBHTTPClient *)sharedNVBHTTPClient;
//
//#pragma mark - API methods
//- (void)testingConnectAPIWithSuccessBlock:(NVBHTTPClientResponseSuccessedBlock)successedBlock
//                              failedBlock:(NVBHTTPClientResponseFailedBlock)failedBlock;

@interface NVBHTTPClient :NSObject

@end
