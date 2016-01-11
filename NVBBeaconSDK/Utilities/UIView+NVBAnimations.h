//
//  UIView+NVBAnimations.h
//  invibe
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright (c) 2015 Alexandru Chis. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^booleanBlock)(BOOL finished);

@interface UIView (NVBAnimations)
+(void)animateImage:(UIImage *)image fromView:(UIView *)fromView toView:(UIView *)toView completion:(booleanBlock)block;

-(void) animateVerticallyFromBottomWithOption:(UIViewAnimationOptions)animationCurve;
-(void) dismissViewVerticallyToBottomWithOption:(UIViewAnimationOptions)animationCurve;
@end
