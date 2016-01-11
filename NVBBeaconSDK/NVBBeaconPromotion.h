//
//  NVBBeaconPromotion.h
//  invibe
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright (c) 2015 Alexandru Chis. All rights reserved.
//

#import <Foundation/Foundation.h>

/***
 *
 * This class represents a promotion setup on the backend
 */

@interface NVBBeaconPromotion : NSObject

@property (nonatomic, retain) NSString* created; //when the promotion was created
@property (nonatomic, retain) NSString* modified; //when the promotion was last modified
@property (nonatomic, retain) NSString* resource_uri; //the uri for this promotion
@property (nonatomic, retain) NSString* title; //promotion title
@property (nonatomic, retain) NSString* event; // which type of event is it associated to
@property (nonatomic, retain) NSString* uri; //the uri for the promotion
@property (nonatomic, retain) NSString* url; //url that will be called
@property (nonatomic, retain) NSString* picture; //picture displayed inside it
@property (nonatomic, retain) NSString* data;
@property (nonatomic, retain) NSString* beaconDescription;
@property (nonatomic, retain) NSString* id;
@property (nonatomic, assign) int is_limited; //if the promotion is limited in terms of how many times it can be shown


+ (instancetype)promotionWithNSDictionary:(NSDictionary *)data;

@end
