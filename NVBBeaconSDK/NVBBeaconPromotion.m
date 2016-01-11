//
//  NVBBeaconPromotion.m
//  invibe
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright (c) 2015 Alexandru Chis. All rights reserved.
//

#import "NVBBeaconPromotion.h"

@implementation NVBBeaconPromotion

+ (instancetype)promotionWithNSDictionary:(NSDictionary *)data
{
    return [[NVBBeaconPromotion alloc] initWithNSDictionary:data];
}


- (id)initWithNSDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        data = [self sanitize:data];
        
        @try {
            self.created = data[@"created"];
            self.beaconDescription = data[@"description"];
            self.modified = data[@"modified"];
            self.resource_uri = data[@"resource_uri"];
            self.title = data[@"title"];
            self.event = data[@"event"];
            self.url = data[@"url"];
            self.id = data[@"id"];
            self.picture = data[@"picture"];
            self.is_limited = [data[@"id"] intValue];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception NVBBeaconPromotion %@ ", exception);
        }
        
        
    }
    
    return self;
    
    
}


- (NSDictionary *)sanitize:(NSDictionary *)data
{
    NSMutableDictionary *sanitized = [NSMutableDictionary dictionaryWithCapacity:[data count]];
    for (id key in [data allKeys]) {
        sanitized[key] = ValueOrEmpty(data[key]);
    }
    return [sanitized copy];
}

static inline id ValueOrEmpty(id obj) {
    return ([obj isKindOfClass:[NSNull class]])?@"":obj;
}


@end
