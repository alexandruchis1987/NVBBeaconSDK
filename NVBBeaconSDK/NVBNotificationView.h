//
//  NVBNotificationView.h
//  invibe
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright (c) 2015 Alexandru Chis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVBBeaconPromotion.h"
#import "NVBBeacon.h"
/*
 *
 *
 */


//blocks defining the actions when the user pressed the accept or dismiss button for the promotion
typedef void (^nvbOnNotificationViewDismissal)(void);
typedef void (^nvbOnNotificationSuccessfullRedirection)(void);

/**
 * This class is used to disply a promotion received from the server
 *
 */


@interface NVBNotificationView : UIView

@property (nonatomic, strong) nvbOnNotificationViewDismissal notificationViewDismissActionBlock;
@property (nonatomic, strong) nvbOnNotificationSuccessfullRedirection notificationSuccessfullRedirection;

-(void) updateWithPromotion:(NVBBeacon*)beacon andPromotion:(NVBBeaconPromotion*) beaconPromotion;


@end
