//
//  SuccessNotificationView.m
//  uLink
//
//  Created by Bennie Kingwood on 12/11/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SuccessNotificationView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMacros.h"
@interface SuccessNotificationView() 
    - (void) hideNotification:(UIView*)view;
@end
@implementation SuccessNotificationView {
    UILabel *backgroundOverlay;
    UILabel *messageLabel;
    UIView *mainView;
    UIImageView *successImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mainView = [[UIView alloc] initWithFrame:CGRectMake(35, 50, 250, 100)];
        mainView.layer.borderWidth = 0.1f;
        mainView.layer.borderColor = [UIColor whiteColor].CGColor;
        mainView.layer.cornerRadius = 10;
        mainView.layer.masksToBounds = YES;
        backgroundOverlay = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 250, 100)];
        backgroundOverlay.backgroundColor = [UIColor blackColor];
        backgroundOverlay.alpha = 0.8;
        successImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success-check.png"]];
        successImageView.frame = CGRectMake(10, 15, 70, 70);
        messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,0, 100, 100)];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor=[UIColor clearColor];
        messageLabel.font = [UIFont fontWithName:FONT_GLOBAL size:16.0f];
        messageLabel.shadowColor = [UIColor blackColor];
        messageLabel.shadowOffset = CGSizeMake(0.0f, -0.5f);
        messageLabel.numberOfLines = 3;
        messageLabel.adjustsFontSizeToFitWidth = YES;
        messageLabel.text = @"Updated.";
        [mainView addSubview:backgroundOverlay];
        [mainView addSubview:successImageView];
        [mainView addSubview:messageLabel];
    }
    return self;
}
- (void) showNotification:(UIView*)view {
    view.userInteractionEnabled = NO;
    [view addSubview:mainView];
    [UIView animateWithDuration:0.2
                          delay: 0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         mainView.alpha = ALPHA_HIGH;
                     }
                     completion:^ (BOOL finished){
                         [self hideNotification:view];
                     }];
}
- (void) hideNotification:(UIView*)view {
    view.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.2
                          delay: 2.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         mainView.alpha = ALPHA_ZERO;
                     }
                     completion:^ (BOOL finished){
                         [mainView removeFromSuperview];
                     }];
}
- (void)setMessage:(NSString *)text {
    messageLabel.text = text;
}
@end
