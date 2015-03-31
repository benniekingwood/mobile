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
#import <SDWebImage/SDWebImageDownloader.h>
#import "ImageActivityIndicatorView.h"
#import "ULinkColorPalette.h"
#import <Pixate/Pixate.h>

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
    
    // build the alert view
    customAlertView = [[AlertView alloc] initWithTitle:@""
                                              message:@""
                                             delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"View Profile Photo", @"Edit Profile",nil];

    // build the scroll view
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,165)];
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
    CGRect proThumbFrame = CGRectMake(110, 20, 100, 100);
    profilePicThumb.frame = proThumbFrame;
    profilePicThumb.layer.cornerRadius = 50;
    profilePicThumb.layer.masksToBounds = YES;
    profilePicThumb.contentMode = UIViewContentModeScaleAspectFill;
    profilePicThumb.layer.borderColor = [UIColor whiteColor].CGColor;
    profilePicThumb.layer.borderWidth = 1.0f;
    [profilePicView addSubview:profilePicThumb];
    
    // create the user's full name label
    CGRect labelFrame = CGRectMake(0, 120, 320, 30 );
    nameLabel = [[UILabel alloc] initWithFrame: labelFrame];
    [profilePicView addSubview:nameLabel];
    
    // create the user's username label
    CGRect usernameFrame = CGRectMake( 0, 142, 320, 30 );
    username = [[UILabel alloc] initWithFrame: usernameFrame];
    [profilePicView addSubview: username];
    
    // add the bio
    bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(340, 10, 280, 100)];
    bioLabel.numberOfLines = 0;
    bioLabel.lineBreakMode = NSLineBreakByWordWrapping;
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
    
    // finally set the styles for this view
    self.view.styleClass = @"profile-pic-view";
    nameLabel.styleClass = @"name";
    username.styleClass = @"username";
    bioLabel.styleClass = @"bio";
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
    if(![UDataCache.sessionUser.firstname isKindOfClass:[NSNull class]] && ![UDataCache.sessionUser.firstname isEqualToString:@""]) {
        [nameLabel setText:[UDataCache.sessionUser.firstname stringByAppendingFormat:@" %@", UDataCache.sessionUser.lastname]];
    } else {
        [nameLabel setText:@"Your Name"];
    }
    profilePicThumb.image = UDataCache.sessionUser.profileImage;
    // grab the user's image from the user cache
    UIImage *profileImage = [UDataCache imageExists:UDataCache.sessionUser.userId cacheModel:IMAGE_CACHE_USER_MEDIUM];
    if (profileImage == nil) {
        if(![UDataCache.sessionUser.userImgURL isKindOfClass:[NSNull class]] && UDataCache.sessionUser.userImgURL != nil && ![UDataCache.sessionUser.userImgURL isEqualToString:@""]) {
            // set the key in the cache to let other processes know that this key is in work
            [UDataCache.userImageMedium setValue:[NSNull null] forKey:UDataCache.sessionUser.userId];
            // lazy load the image from the web
            NSURL *url = [NSURL URLWithString:[URL_USER_IMAGE_MEDIUM stringByAppendingString:UDataCache.sessionUser.userImgURL]];
            __block ImageActivityIndicatorView *activityIndicator;
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            [imageDownloader downloadImageWithURL:url
                                      options:SDWebImageDownloaderProgressiveDownload
                                     progress:^(NSUInteger receivedSize, long long expectedSize) {
                                         if (!activityIndicator)
                                         {
                                              activityIndicator = [[ImageActivityIndicatorView alloc] init];
                                             [activityIndicator showActivityIndicator:profilePicThumb];
                                         }
                                     }
                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                        if (image && finished)
                                        {
                                           // add the user's image to the image cache
                                            [UDataCache.userImageMedium setValue:image forKey:UDataCache.sessionUser.userId];
                                            // set the picture in the view
                                            profilePicThumb.image = image;
                                            [activityIndicator hideActivityIndicator:profilePicThumb];
                                            activityIndicator = nil;
                                        } 
                                    }];
        }
    } else if (![profileImage isKindOfClass:[NSNull class]]){
        profilePicThumb.image = profileImage;
    }
   
    bioLabel.text = (![UDataCache.sessionUser.bio isKindOfClass:[NSNull class]] && ![UDataCache.sessionUser.bio isEqualToString:@""]) ? UDataCache.sessionUser.bio : @"Your bio will be displayed here.  You should edit your profile and tell us your bio!";
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
