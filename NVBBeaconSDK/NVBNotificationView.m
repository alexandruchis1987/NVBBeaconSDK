//
//  NVBNotificationView.m
//  invibe
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright (c) 2015 Alexandru Chis. All rights reserved.
//

#import "NVBNotificationView.h"
#import "UIView+NVBAnimations.h"
#import "UIImageView+AFNetworking.h"
#import "NVBBeacon.h"


@interface NVBNotificationView()
{
    
}

@property (nonatomic, retain) IBOutlet UIButton* btnClose;
@property (nonatomic, retain) IBOutlet UIButton* btnGetItNow;
@property (nonatomic, retain) IBOutlet UILabel* lblSubtitle;
@property (nonatomic, retain) IBOutlet UILabel* lblTitle;
@property (nonatomic, retain) IBOutlet UIImageView* productImage;

@property (nonatomic, strong) NVBBeaconPromotion* beaconPromotion;
@property (nonatomic, strong) NVBBeacon* beacon;

@end



@implementation NVBNotificationView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib
{
    [super awakeFromNib];

    //to be taken out
//    if (IPHONE5_ADJUSTEMENT() > 0)
//    {
//        CGRect frameButton = self.btnGetItNow.frame;
//        frameButton.origin.y += 20;
//        self.btnGetItNow.frame = frameButton;
//        
//    }
    
    //TO BE TAKEN OUT
//    self.lblTitle.font = [UIFont fontWithName:QUICKSAND_BOLD size:21];
//    self.lblSubtitle.font = [UIFont fontWithName:QUICKSAND_REGULAR size:19];
//    self.btnGetItNow.titleLabel.font = [UIFont fontWithName:QUICKSAND_BOLD size:18];

}

-(void) updateWithPromotion:(NVBBeacon*)beacon andPromotion:(NVBBeaconPromotion*) beaconPromotion
{
    self.beaconPromotion = beaconPromotion;
    self.beacon = beacon;
    
    [self.lblSubtitle setText:[NSString stringWithFormat:@"%@!", beaconPromotion.beaconDescription]];
    [self.lblTitle setText:@"Congrats.. You got a gift!"];
    if (beaconPromotion.title != nil)
        [self.lblTitle setText:beaconPromotion.title];
    

    
    if (beaconPromotion.picture != nil)
    {
        if (beaconPromotion.picture.length > 0)
        {
            [self.productImage setImageWithURL:[NSURL URLWithString:beaconPromotion.picture]];
        }
        else
        {
            [self.productImage setImageWithURL:[NSURL URLWithString:beaconPromotion.url]];
        }
    }
    else
    {
        [self.productImage setImageWithURL:[NSURL URLWithString:beaconPromotion.url]];                    
    }
    
        

    
    
    self.btnGetItNow.hidden = NO;
    self.lblSubtitle.hidden = NO;
}


-(IBAction) dismiss:(UIButton*) sender
{
    //TO BE TAKEN OUT
//    if (self.beaconPromotion)
//    {
//        
//        [[NVBProgressView sharedView] showWithMessage:NSLocalizedString(@"Loading...", @"")];
//        [[NVBDataStore sharedInstance] notifyCommunicationAPI:self.beaconPromotion andBeacon:self.beacon andParam:@"accepted" andState:@"false" onCompletion:^(BOOL success, NSString *error) {
//            
//            if (success == NO)
//            {
//                [[NVBProgressView sharedView] showFailureWithMessage:error];
//            }
//            else
//            {
//                [[NVBProgressView sharedView] dismiss];
//            }
//            
//            [self dismissViewVerticallyToBottomWithOption:UIViewAnimationCurveEaseIn];
//            if (self.notificationViewDismissActionBlock)
//            {
//                self.notificationViewDismissActionBlock();
//            }
//            
//        }];
//    }
//    
    
}

-(IBAction) redeemInvite:(UIButton*) sender
{

//    if (self.beaconPromotion)
//    {
//        [[NVBProgressView sharedView] showWithMessage:NSLocalizedString(@"Loading...", @"")];
//        [[NVBDataStore sharedInstance] notifyCommunicationAPI:self.beaconPromotion andBeacon:self.beacon andParam:@"accepted" andState:@"true" onCompletion:^(BOOL success, NSString *error) {
//
//            if (success == NO)
//            {
//                [[NVBProgressView sharedView] showFailureWithMessage:error];
//            }
//            else
//            {
//                [[NVBProgressView sharedView] dismiss];
//            }
//            
//            [self dismissViewVerticallyToBottomWithOption:UIViewAnimationCurveEaseIn];
//            if (self.notificationSuccessfullRedirection)
//            {
//                self.notificationSuccessfullRedirection();
//            }
//
//        
//        }];
//    }
}


-(void) dealloc
{
    self.notificationViewDismissActionBlock = nil;
    self.notificationSuccessfullRedirection = nil;
}

@end
