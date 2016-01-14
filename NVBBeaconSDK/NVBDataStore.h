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
typedef void(^arrayListBlock)(NSMutableArray* responseArrayList, NSString *error);

@interface NVBDataStore : AFHTTPClient

@property (nonatomic, strong) NSString* applicationId;

+ (NVBDataStore *)sharedInstance;


//methods for session
//-(void) requestTokenWithClientId:(NSString)

//methods used to subscribe to a beacon or unsubscribe from it (used by the push notification system)
-(void)unsubscribeFromInvibe:(NSString*) pubnub withCompletion:(booleanSuccessBlock)completion;
-(void)subscribeToInvibeWithChannel:(NSString*) channel onCompletion:(booleanSuccessBlock)completion;
-(void)syncUnsubscribeFromChannels;


//method which notifies the backend if the accept or decline button was pressed in the promotion view
-(void) notifyCommunicationAPI:(NVBBeaconPromotion*) promotion andBeacon:(NVBBeacon*) beacon andParam:(NSString*) param andState:(NSString*) state onCompletion:(booleanSuccessBlock) completionBlock;

//method with retrieves the defined promotion on the backend for the specified beacon
- (void)getPromotionsWithBeaconId:(NSString*) beaconId onCompletion:(beaconPromotionBlock)completion;

//method which returns the beacons associated with the current client id
- (void)getRegisteredBeacons:(arrayListBlock)completion;

//method which registers with the system
- (void)registerWithClientId:(NSString*)clientId andClientSecret:(NSString*)clientSecret andCompletionBlock: (booleanSuccessBlock)completion;



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


-(void) enableDebugMode;




@end
