//
//  NVBBecon.h
// NVBBeaconSDK
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright (c) 2015 Alexandru Chis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NVBBeaconPromotion.h"

@interface NVBBeacon : NSObject


@property (nonatomic, strong) NSNumber* major; //major identifier for the beacon
@property (nonatomic, strong) NSNumber* minor; //minor identifier for the beacon
@property (nonatomic, assign) CLProximity proximity; // proximity for the beacon
@property (nonatomic, strong) NSString* name; //beacon name
@property (nonatomic, strong) NSString* venue; // venue uri for which this beacon is assigned to
@property (nonatomic, strong) NSString* id; //beacon id
@property (nonatomic, strong) NSString* venue_name; //venue name for which the beacon is assigned to
@property (nonatomic, strong) NSString* uuid; //vendor uuid

@property (nonatomic, strong) NVBBeaconPromotion* enterPromotion; //promotion triggered when entering the region
@property (nonatomic, strong) NVBBeaconPromotion* exitPromotion; //promotion triggered when exiting the region
@property (nonatomic, strong) NVBBeaconPromotion* immediatePromotion; //promotion triggered when being in the immediate vecinity
@property (nonatomic, strong) NVBBeaconPromotion* nearPromotion; //promotion triggered when being in the near vecinity
@property (nonatomic, strong) NVBBeaconPromotion* farPromotion; //promotion triggered when being in the far rea

+ (NVBBeacon *)makeWithBeacon:(CLBeacon *)beacon; //method which turns a CLBeacon object to a local beacon object
+(NVBBeacon *)beaconWithDictionary:(NSDictionary *)dict; // initializer from a json beacon structure

//methods used for equality comparator
-(NSString*) beaconIdentifier;
-(NSString*) promoIdentifier;

- (BOOL)isEqual:(id)object;

@end
