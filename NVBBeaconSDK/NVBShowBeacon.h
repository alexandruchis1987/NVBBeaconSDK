//
//  NVBShowBeacon.h
//  Demo
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright (c) 2015 Alexandru Chis. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * This class remembers for which of the proximy states, the promotion view was shown
 *
 */
@interface NVBShowBeacon : NSObject


@property (nonatomic, assign) BOOL hideImmediate; //if the view is hidden for the immediate proximity
@property (nonatomic, assign) BOOL hideNear; //if the view is hidden for the immediate proximity
@property (nonatomic, assign) BOOL hideFar; //if the view is hidden for the immediate proximity

-(void) reset; //we reset the fields, usually when the beacon object is newly detected or some previous actions must be discarded

@end
