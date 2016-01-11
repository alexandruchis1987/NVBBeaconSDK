//
//  NVBBecon.m
//  invibe
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright (c) 2015 Alexandru Chis. All rights reserved.
//

#import "NVBBeacon.h"
#import "NVBBeaconPromotion.h"

@implementation NVBBeacon

+ (NVBBeacon *)makeWithBeacon:(CLBeacon *)beacon
{
    return [[NVBBeacon alloc] initWithBeacon:beacon];
}


+(NVBBeacon *)beaconWithDictionary:(NSDictionary *)dict
{
    return [[NVBBeacon alloc] initWithNSDictionary:dict];
}

- (id)initWithNSDictionary:(NSDictionary *)dict
{
    
    self = [super init];
    if (self) {
        @try {
            
            if (dict[@"name"])
                self.name = [dict valueForKey:@"name"];
            if (dict[@"venue"])
                self.venue = [dict valueForKey:@"venue"];
            if (dict[@"id"])
                self.id = [dict valueForKey:@"id"];
            if (dict[@"venue_name"])
                self.venue_name = [dict valueForKey:@"venue_name"];
            if (dict[@"major"])
                self.major =  [dict valueForKey:@"major"];
            if (dict[@"minor"])
                self.minor =  [dict valueForKey:@"minor"];
            
            if ( ([dict valueForKey:@"near_promotion"] != nil) && ([[dict valueForKey:@"near_promotion"] class] != [NSNull class]))
            {
                self.nearPromotion = [NVBBeaconPromotion promotionWithNSDictionary:[dict valueForKey:@"near_promotion"]];
            }
            else
            {
                self.nearPromotion = nil;
            }
            
            if ( ([dict valueForKey:@"far_promotion"] != nil) && ([[dict valueForKey:@"far_promotion"] class] != [NSNull class]))
            {
                self.farPromotion = [NVBBeaconPromotion promotionWithNSDictionary:[dict valueForKey:@"far_promotion"]];
            }
            else
            {
                self.farPromotion = nil;
            }
            
            if ( ([dict valueForKey:@"enter_region_promotion"] != nil) && ([[dict valueForKey:@"enter_region_promotion"] class] != [NSNull class]))
            {
                self.enterPromotion = [NVBBeaconPromotion promotionWithNSDictionary:[dict valueForKey:@"enter_region_promotion"]];
            }
            else
            {
                self.enterPromotion = nil;
            }
            
            if ( ([dict valueForKey:@"immediate_promotion"] != nil) && ([[dict valueForKey:@"immediate_promotion"] class] != [NSNull class]))
            {
                self.immediatePromotion = [NVBBeaconPromotion promotionWithNSDictionary:[dict valueForKey:@"immediate_promotion"]];
            }
            else
            {
                self.immediatePromotion = nil;
            }
            
            if ( ([dict valueForKey:@"exit_region_promotion"] != nil) && ([[dict valueForKey:@"exit_region_promotion"] class] != [NSNull class]))
            {
                self.exitPromotion = [NVBBeaconPromotion promotionWithNSDictionary:[dict valueForKey:@"exit_region_promotion"]];
            }
            else
            {
                self.exitPromotion = nil;
            }
            
            
        }
        @catch (NSException *exception) {
            NSLog (@"Exception NVBBeacon %@ ", exception);
        }
        
        
    }
    
    return self;
}

-(id) initWithBeacon:(CLBeacon*) beacon
{
    if (self = [super init])
    {
        if (beacon != nil)
        {
            self.major = beacon.major;
            self.minor = beacon.minor;
            self.proximity = beacon.proximity;
        }
        else
        {
            NSLog(@" beacon is nil");
        }
    }
    
    return self;
}



#pragma mark Equality Comparator


- (BOOL)isEqual:(id)object
{
    if ((self == nil) || (object == nil))
    {
        return NO;
    }
    else
    {
        return ([[self promoIdentifier] isEqualToString:[((NVBBeacon*) object) promoIdentifier]]);
    }
}

- (NSUInteger)hash {
    
    NSUInteger hash = 0;
    return hash;
}

-(NSString*) beaconIdentifier
{
    //return [NSString stringWithFormat:@"%@%@", self.major, self.minor];
    return [NSString stringWithFormat:@"%@", self.major];
}

-(NSString*) promoIdentifier
{
    return [NSString stringWithFormat:@"%@%@", self.major, self.minor];
}


@end
