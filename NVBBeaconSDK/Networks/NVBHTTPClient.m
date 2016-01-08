//
//  NVBHTTPClient.m
//  NVBBeaconSDK
//
//  Created by An Phan on 1/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import "NVBHTTPClient.h"
#import "NVBLogger.h"

static NSString *const kBaseUrl = @"http://jsonplaceholder.typicode.com/";

@implementation NVBHTTPClient

//*****************************************************************************
#pragma mark -
#pragma mark ** Life cycle **
+ (NVBHTTPClient *)sharedNVBHTTPClient {
    static NVBHTTPClient *__sharedNVBHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        __sharedNVBHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    });
    
    return __sharedNVBHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    return self;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** API methods **
- (void)testingConnectAPIWithSuccessBlock:(NVBHTTPClientResponseSuccessedBlock)successedBlock
                              failedBlock:(NVBHTTPClientResponseFailedBlock)failedBlock {
    [self GET:@"posts/1"
   parameters:nil
     progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          
          // Notify succeed
          NVBLog(@"Reponse: %@", responseObject);
          if (successedBlock) {
              successedBlock(responseObject);
          }
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          
          // Notify in case having error
          NVBLog(@"Failure: %@", error);
          if (failedBlock) {
              failedBlock(error);
          }
      }];
}

@end
