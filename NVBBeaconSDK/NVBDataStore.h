//
//  NVBDataStore.h
//
//  Created by Alex Chis on 28/06/13.
//  Copyright (c) 2013 Alex Chis. All rights reserved.
//


#import "AFNetworking.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "NVBBeacon.h"

typedef void(^booleanSuccessBlock)(BOOL success, NSString *error);
typedef void(^beaconPromotionBlock)(NVBBeacon *beacon, NSString *error);

@interface NVBDataStore : AFHTTPClient

@property (nonatomic, strong) NSOperationQueue* operationsQueue;
@property (nonatomic, strong) NSString* applicationId;


+ (NVBDataStore *)sharedInstance;

- (void)startLocationServicesForeground ;
- (void)startLocationServicesBackground ;
- (void)stopLocationServices;

-(void)unsubscribeFromInvibe:(NSString*) pubnub withCompletion:(booleanSuccessBlock)completion;
-(void)subscribeToInvibeWithChannel:(NSString*) channel onCompletion:(booleanSuccessBlock)completion;
-(void)syncUnsubscribeFromChannels;


-(void) notifyCommunicationAPI:(NVBBeaconPromotion*) promotion andBeacon:(NVBBeacon*) beacon andParam:(NSString*) param andState:(NSString*) state onCompletion:(booleanSuccessBlock) completionBlock;
- (void)getPromotionsWithBeaconId:(NSString*) beaconId onCompletion:(beaconPromotionBlock)completion;


-(void) setApplicationId:(NSString*) applicationId;


/*!
 @abstract Sets the applicationId of your application.
 
 @param applicationId The application id of your NVBBeacons application.
 
 */
+ (void)setApplicationId:(NSString *)applicationId;


/*!
 @abstract The current application id that was used to configure NVBBeacons framework.
 */
+ (NSString *)getApplicationId;





@end
