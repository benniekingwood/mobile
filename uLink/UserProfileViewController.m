//
//  UserProfileViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 12/3/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UserProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMacros.h"
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import "DataCache.h"
@interface UserProfileViewController () {
    UIImageView *profilePicThumb;
    UIImageView *profilePicLarge;
    UIView *profilePicViewLarge, *currentProfilePic;
    CGRect proPicFrame;
}
@end
@implementation UserProfileViewController
@synthesize user;
@synthesize bioLabel;
@synthesize nameLabel;
@synthesize usernameLabel;
@synthesize schoolLabel;
@synthesize schoolStatusLabel;
@synthesize gradYearLabel;
@synthesize closeButton;
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
    proPicFrame = CGRectMake(0, 70, 320, 320);
    profilePicLarge = [[UIImageView alloc] initWithFrame:proPicFrame];
    profilePicLarge.contentMode = UIViewContentModeScaleAspectFit;
    CGRect profilePicViewFrame;
    profilePicViewFrame.origin.x = 0;
    profilePicViewFrame.origin.y = 0;
    profilePicViewFrame.size = self.view.frame.size;
    profilePicViewLarge = [[UIView alloc] initWithFrame:profilePicViewFrame];
    profilePicViewLarge.backgroundColor = [UIColor blackColor];
    profilePicViewLarge.frame = profilePicViewFrame;
    profilePicViewLarge.userInteractionEnabled = YES;

    // create and add the profile picture subview
    UIView *profilePicView = [[UIView alloc] initWithFrame:CGRectMake(30, 180, 100, 100)];
    profilePicView.backgroundColor = [UIColor clearColor];
    profilePicThumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    profilePicThumb.layer.cornerRadius = 50;
    profilePicThumb.layer.masksToBounds = YES;
    profilePicThumb.contentMode = UIViewContentModeScaleAspectFill;
    profilePicThumb.layer.borderColor = [UIColor whiteColor].CGColor;
    profilePicThumb.layer.borderWidth = 1.0f;
    [profilePicView addSubview:profilePicThumb];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [profilePicView addSubview: button];
    [button addTarget: self
               action: @selector(showProfilePicture)
     forControlEvents: UIControlEventTouchDown];
    // add the profile pic view to the scroll view
    [self.view addSubview:profilePicView];
}

- (void)viewWillAppear:(BOOL)animated {
    profilePicThumb.image = self.user.profileImage;
    profilePicLarge.image = self.user.profileImage;
    
    // grab the user's image from the user cache
    UIImage *profileImage = [UDataCache imageExists:self.user.userId cacheModel:IMAGE_CACHE_USER_MEDIUM];
    if (profileImage == nil) {
        
        if(![self.user.userImgURL isKindOfClass:[NSNull class]] && self.user.userImgURL != nil && ![self.user.userImgURL isEqualToString:@""]) {
        // set the key in the cache to let other processes know that this key is in work
        [UDataCache.userImageMedium setValue:[NSNull null] forKey:self.user.userId];
        // lazy load the image from the web
        NSURL *url = [NSURL URLWithString:[URL_USER_IMAGE_MEDIUM stringByAppendingString:self.user.userImgURL]];
        __block ImageActivityIndicatorView *iActivityIndicator;
        SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
        [imageDownloader downloadImageWithURL:url
                                      options:SDWebImageDownloaderProgressiveDownload
                                     progress:^(NSUInteger receivedSize, long long expectedSize) {
                                         if (!iActivityIndicator)
                                         {
                                             iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
                                             [iActivityIndicator showActivityIndicator:profilePicThumb];
                                         }
                                     }
                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                        if (image && finished)
                                        {
                                            // add the user's image to the image cache
                                            [UDataCache.userImageMedium setValue:image forKey:self.user.userId];
                                            // set the picture in the view
                                            profilePicThumb.image = image;
                                            profilePicLarge.image = image;
                                            [iActivityIndicator hideActivityIndicator:profilePicThumb];
                                            iActivityIndicator = nil;
                                        }
                                    }];
        }
    } else if (![profileImage isKindOfClass:[NSNull class]]) {
        profilePicThumb.image = profileImage;
        profilePicLarge.image = profileImage;
    }

    // set the username text
    self.usernameLabel.text = self.user.username;
    
    // set the full name text
    if(![self.user.firstname isKindOfClass:[NSNull class]] && ![self.user.firstname isEqualToString:@""]) {
        self.nameLabel.text = [self.user.firstname stringByAppendingFormat:@" %@", self.user.lastname];
    } else {
        self.nameLabel.text = @"uLink User";
    }
    
    // set the bio text
    self.bioLabel.text = (![self.user.bio isKindOfClass:[NSNull class]] && ![self.user.bio isEqualToString:@""]) ? self.user.bio : @"I haven't entered my bio yet, but rest assured when I do it will be amazing.";
    
    // set the school status text
    self.schoolStatusLabel.text = self.user.schoolStatus;
    // set the graduation year text
    if(![self.user.year isKindOfClass:[NSNull class]] && ![self.user.year isEqualToString:@""]) {
        self.gradYearLabel.text = self.user.year;
    } else {
        self.gradYearLabel.text = @"";
    }
    
    // set the school name label text
    if(![self.user.schoolName isKindOfClass:[NSNull class]] && ![self.user.schoolName isEqualToString:@""]) {
        self.schoolLabel.text = self.user.schoolName;
    } else {
        self.schoolLabel.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// We only support single touches, so anyObject retrieves just that one touch from touches
	UITouch *touch = [touches anyObject];
	
	// animate touched square
	if([touch view] == profilePicViewLarge || [touch view] == currentProfilePic) {
        // hide this view again
        [self hideProfilePicture];
    }
}

-(void) hideProfilePicture {
    // Fade out the view right away
    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         profilePicViewLarge.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         // Wait one second and then fade in the view
                         [profilePicViewLarge removeFromSuperview];
                     }];
}

-(void) showProfilePicture {
    // create and add the profile picture subview
    currentProfilePic = profilePicLarge;
    currentProfilePic.userInteractionEnabled = YES;
    [profilePicViewLarge addSubview:profilePicLarge];
    profilePicViewLarge.alpha = 0.0;
    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         profilePicViewLarge.alpha = 1.0;
                         [self.view addSubview:profilePicViewLarge];
                     }
                     completion:nil];
}
- (IBAction)closeClick:(id)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}
@end
