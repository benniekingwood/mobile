//
//  ModalImageView.m
//  uLink
//
//  Created by Bennie Kingwood on 2/3/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "ModalImageView.h"
@interface ModalImageView() {
    UIView *profilePicView;
    UIImageView *currentProfilePic;
}
-(void) hideImage;
-(void) showImage:(UIImage *) profileImage parentView:(UIView*)parentView;
@end
@implementation ModalImageView
@synthesize imageVisible;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) toggleImageView:(UIView *)parentView image:(UIImage *)image {
    if(self.imageVisible) {
        [self hideImage];
    } else {
        [self showImage:image parentView:parentView];
    }
}
-(void) hideImage {
    self.imageVisible = FALSE;
    // Fade out the view right away
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         profilePicView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [profilePicView removeFromSuperview];
                     }];
}

-(void) showImage:(UIImage *) profileImage parentView:(UIView*)parentView{
    self.imageVisible = TRUE;
    if(profilePicView == nil) {
        profilePicView = [[UIView alloc] initWithFrame:parentView.window.bounds];
        profilePicView.backgroundColor = [UIColor blackColor];
        profilePicView.userInteractionEnabled = YES;
        currentProfilePic.userInteractionEnabled = YES;
        currentProfilePic = [[UIImageView alloc] initWithFrame:CGRectMake(0, -44, parentView.window.bounds.size.width, parentView.window.bounds.size.height)];
    } 
    // remove any previous pictures
    for (UIView *view in [profilePicView subviews]) {
        [view removeFromSuperview];
    }
    currentProfilePic.image = profileImage;
    currentProfilePic.contentMode = UIViewContentModeScaleAspectFit;
    profilePicView.alpha = 0.0;
    [profilePicView addSubview:currentProfilePic];
    [parentView addSubview:profilePicView];
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         profilePicView.alpha = 1.0;
                     }
                     completion:nil];
}

@end
