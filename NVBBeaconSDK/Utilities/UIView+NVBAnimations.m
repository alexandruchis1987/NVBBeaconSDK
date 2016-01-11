//
//  UIView+NVBAnimations.m
//  invibe
//
//  Created by Alexandru Chis on 11/01/16.
//  Copyright (c) 2015 Alexandru Chis. All rights reserved.
//

#import "UIView+NVBAnimations.h"
#define IPHONE5_ADJUSTEMENT()  fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 )

@implementation UIView (NVBAnimations)
+(void)animateImage:(UIImage *)image fromView:(UIView *)fromView toView:(UIView *)toView  completion:(booleanBlock)block  {
    NSAssert(fromView.superview == toView.superview, @"from and To View must to have same superview");
    
    UIImageView *animatedImageView = [[UIImageView alloc]initWithImage:image];
    [animatedImageView setFrame:fromView.frame];
    [fromView.superview  addSubview:animatedImageView];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [animatedImageView setFrame:toView.frame];
    } completion:^(BOOL finished) {
        [animatedImageView removeFromSuperview];
        if(block) block(YES);
    }];
 
}

-(void) animateVerticallyFromBottomWithOption:(UIViewAnimationOptions)animationCurve
{
    if ([[[UIApplication sharedApplication] windows] count] > 0)
    {
        UIWindow* mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        
        
        CGRect frame = self.frame;
        frame.size.height += IPHONE5_ADJUSTEMENT();
        frame.origin.y = frame.size.height;
        self.frame = frame;
        
        
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:animationCurve
                         animations:^{
                             CGRect frameShareview = self.frame;
                             frameShareview.origin.y = 0;
                             self.frame = frameShareview;
                         }
                         completion:nil];
        
        
        [mainWindow addSubview:self];
    }
}



-(void) dismissViewVerticallyToBottomWithOption:(UIViewAnimationOptions)animationCurve
{
    
    [UIView animateWithDuration:0.4f
                          delay:0.0f
                        options:animationCurve
                     animations:^{
                         CGRect frameShareview = self.frame;
                         frameShareview.origin.y = frameShareview.size.height;
                         self.frame = frameShareview;
                     }
                     completion:^(BOOL finished)
     {
         [self removeFromSuperview];
     }];
    
    
    
}

@end
