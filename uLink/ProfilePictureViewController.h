//
//  ProfilePictureViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/11/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertView.h"
#import "EditProfileViewController.h"

@protocol ProfilePictureViewControllerDelegate;
@protocol ProfilePictureViewControllerDelegate <NSObject>
-(void) showProfilePicture:(UIImage*)profileImage;
-(void) showEditProfileViewController;
@end

@interface ProfilePictureViewController : UIViewController <UIAlertViewDelegate,UIScrollViewDelegate,EditProfileViewControllerDelegate> {
}

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, assign) id<ProfilePictureViewControllerDelegate> delegate;
- (IBAction)showProfileAlert:(UIButton *)sender;
- (IBAction)changePage:(UIPageControl *)sender;
@end



