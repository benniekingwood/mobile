//
//  ProfileViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/12/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfilePictureViewController.h"
#import "EditProfileViewController.h"
@interface ProfileViewController : UIViewController <ProfilePictureViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *listingButton;
@property (strong, nonatomic) IBOutlet UIButton *eventsButton;
@property (strong, nonatomic) IBOutlet UIButton *snapsButton;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UILabel *eventsCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *snapCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *listingCountLabel;
@end
