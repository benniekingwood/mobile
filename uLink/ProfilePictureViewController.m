//
//  ProfilePictureViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/11/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "ProfilePictureViewController.h"
#import "AppMacros.h"
#import <QuartzCore/QuartzCore.h>
#import "DataCache.h"

@interface ProfilePictureViewController () {
    UIScrollView *scroll;
    AlertView *customAlertView;
    UIImageView *profilePicThumb;
    UILabel* nameLabel;
    UILabel* username;
    NSMutableAttributedString *usernameText;
    UILabel *bioLabel;
    NSMutableAttributedString *bioText;
}
@end

@implementation ProfilePictureViewController
@synthesize pageControl, mainView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   
    
    customAlertView = [[AlertView alloc] initWithTitle:@""
                                                                      message:@""
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                            otherButtonTitles:@"View Profile Photo", @"Edit Profile",nil];

    
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,100)];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    scroll.contentSize = CGSizeMake(640, 100);
    scroll.showsHorizontalScrollIndicator = NO;
    
    // create and add the profile picture subview
    CGRect profilePicFrame;
    profilePicFrame.origin.x = 0;
    profilePicFrame.origin.y = 0;
    profilePicFrame.size = scroll.frame.size;
    UIView *profilePicView = [[UIView alloc] initWithFrame:profilePicFrame];
    profilePicView.backgroundColor = [UIColor clearColor];
    profilePicView.frame = profilePicFrame;
    profilePicThumb = [[UIImageView alloc] init];
    CGRect proThumbFrame = CGRectMake(30, 20, 80, 80);
    profilePicThumb.frame = proThumbFrame;
    profilePicThumb.layer.cornerRadius = 5;
    profilePicThumb.layer.masksToBounds = YES;
    [profilePicView addSubview:profilePicThumb];
    // create the user's full name label
    CGRect labelFrame = CGRectMake( 140, 25, 200, 30 );
    nameLabel = [[UILabel alloc] initWithFrame: labelFrame];
    [nameLabel setTextColor: [UIColor whiteColor]];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
     nameLabel.font = [UIFont fontWithName:FONT_GLOBAL size:15.0];
    [profilePicView addSubview:nameLabel];
    // create the user's username label
    CGRect usernameFrame = CGRectMake( 140, 50, 200, 30 );
    username = [[UILabel alloc] initWithFrame: usernameFrame];
    [username setBackgroundColor:[UIColor clearColor]];
    username.font = [UIFont fontWithName:FONT_GLOBAL size:12.0f];
    username.textColor = [UIColor whiteColor];
    
    [profilePicView addSubview: username];
    
    // add the bio
    bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(340, 0, 280, 100)];
    bioLabel.textAlignment = NSTextAlignmentCenter;
    bioLabel.backgroundColor = [UIColor clearColor];
    bioLabel.numberOfLines = 0;
    bioLabel.lineBreakMode = NSLineBreakByWordWrapping;
    bioLabel.textColor = [UIColor whiteColor];
    bioLabel.font = [UIFont fontWithName:FONT_GLOBAL size:11.0f];
    
    [profilePicView addSubview:bioLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame: proThumbFrame];
    [profilePicView addSubview: button];
    [button addTarget: self
               action: @selector(showProfileAlert:)
     forControlEvents: UIControlEventTouchDown];
    // add the profile pic view to the scroll view
    [scroll addSubview:profilePicView];
    
    // add the scroll view to the main view
    [self.mainView addSubview:scroll];
    
    // initialize the page control
    pageControl.numberOfPages = 2;
    pageControl.currentPage = 0;
}

- (void) viewWillAppear:(BOOL)animated {
    [self updateProfileInformation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateProfileInformation {
    [nameLabel setText:[UDataCache.sessionUser.firstname stringByAppendingFormat:@" %@", UDataCache.sessionUser.lastname]];
    profilePicThumb.image = UDataCache.sessionUser.profileImage;
    bioLabel.text = UDataCache.sessionUser.bio;
    username.text = UDataCache.sessionUser.username;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scroll.frame.size.width;
    int page = floor((scroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
  
}

- (IBAction)changePage:(UIPageControl *)sender {
    int page = self.pageControl.currentPage;
    CGRect frame = scroll.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scroll scrollRectToVisible:frame animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // grab the EditProfileViewController from the MainTabBarViewController
    id previousController = [[self.tabBarController viewControllers] objectAtIndex:1];
    switch (buttonIndex) {
        case 1: {
            if ([previousController respondsToSelector:@selector(showProfilePicture:)]) {
                [previousController showProfilePicture:profilePicThumb.image];
            }
        }
            break;
        case 2:
            // navigate to the edit profile form
            if ([previousController respondsToSelector:@selector(showEditProfileViewController)]) {
                [previousController showEditProfileViewController];
            }
            break;
    }
}
- (IBAction)showProfileAlert:(UIButton *)sender {
       [customAlertView show];
}
@end
