//
//  PreviewPhotoView.m
//  uLink
//
//  Created by Bennie Kingwood on 12/31/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "PreviewPhotoView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMacros.h"
@interface PreviewPhotoView() {
    UIButton *closeButton;
    UIView *parentView;
    UIView *mainView;
    UIColor *defaultBgColor;
}
- (void) initialize;
@end
@implementation PreviewPhotoView
@synthesize previewImageView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        defaultBgColor = [UIColor colorWithRed:142.0f / 255.0f green:142.0f / 255.0f blue:142.0f / 255.0f alpha:1.0f];
        [self initialize];
    }
    return self;
}
- (id)initWithBackgroundColor:(UIColor*)backgroundColor frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        defaultBgColor = backgroundColor;
        [self initialize];
    }
    return self;
}
- (void) initialize {
    mainView = [[UIView alloc] initWithFrame:self.frame];
    mainView.backgroundColor = defaultBgColor;

    CGRect frame = self.frame;
    frame.origin.x = 5;
    frame.origin.y = 5;
    frame.size.width -= 10;
    frame.size.height -=15;
    self.previewImageView = [[UIImageView alloc] initWithFrame:frame];
    self.previewImageView.layer.cornerRadius = 5;
    self.previewImageView.layer.masksToBounds = YES;
    self.previewImageView.layer.borderColor = [[UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.3f] CGColor];
    self.previewImageView.layer.borderWidth = 2.0f;
    self.previewImageView.alpha = ALPHA_ZERO;
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-30, -10, 40, 40)];
    [closeButton setBackgroundColor:[UIColor clearColor]];
    UIImage *resizableButton = [[UIImage imageNamed:@"close-button" ] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [closeButton setImage:resizableButton forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(hidePreviewPhoto) forControlEvents:UIControlEventTouchUpInside];
}

- (void) showPreviewPhoto:(UIView*)view {
    parentView = view;
    [mainView addSubview:self.previewImageView];
    [mainView addSubview:closeButton];
    [view addSubview:mainView];
    [UIView animateWithDuration:0.2
                          delay: 0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         self.previewImageView.alpha = ALPHA_HIGH;
                     }
                     completion:nil];
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = ((UIButton*)subview);
            if(button.tag == kButtonChoosePhoto || button.tag == kButtonTakePhoto) {
                button.enabled = NO;
                button.alpha = ALPHA_ZERO;
            }
        }
    }
}
- (void) hidePreviewPhoto {    
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         self.previewImageView.alpha = ALPHA_ZERO;
                         self.previewImageView.image = nil;
                     }
                     completion:nil];
    [mainView removeFromSuperview];
    for (UIView *subview in parentView.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = ((UIButton*)subview);
            if(button.tag == kButtonChoosePhoto || button.tag == kButtonTakePhoto) {
                button.enabled = YES;
                button.alpha = ALPHA_HIGH;
            }
        }
    }
    // Send notification that the preview photo was closed
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PREVIEW_PHOTO_CLOSED object:nil];
}

@end
