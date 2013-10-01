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
    UIScrollView *scroll;
    UIImageView *profilePicThumb;
    UIImageView *profilePicLarge;
    UIView *profilePicViewLarge, *currentProfilePic;
    CGRect proPicFrame;
    UILabel *bio;
    UILabel* nameLabel;
    UILabel* usernameLabel;
    UILabel *schoolLabel;
    UILabel *schoolStatusLabel;
    UILabel *gradYearLabel;
}
@end
@implementation UserProfileViewController
@synthesize pageControl, user;
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
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,44,320,100)];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    scroll.contentSize = CGSizeMake(640, 100);
    scroll.showsHorizontalScrollIndicator = NO;
    
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
    profilePicViewLarge.userInteractionEnabled = YES;;

    // create and add the profile picture subview
    CGRect profilePicFrame;
    profilePicFrame.origin.x = 0;
    profilePicFrame.origin.y = 0;
    profilePicFrame.size = scroll.frame.size;
    UIView *profilePicView = [[UIView alloc] initWithFrame:profilePicFrame];
    profilePicView.backgroundColor = [UIColor clearColor];
    profilePicView.frame = profilePicFrame;
    CGRect proThumbFrame = CGRectMake(30, 20, 80, 80);
    profilePicThumb = [[UIImageView alloc] initWithFrame:proThumbFrame];
    profilePicThumb.layer.cornerRadius = 40;
    profilePicThumb.layer.masksToBounds = YES;
    profilePicThumb.contentMode = UIViewContentModeScaleAspectFill;
    [profilePicView addSubview:profilePicThumb];
    
    // create the user's full name label
    nameLabel = [[UILabel alloc] initWithFrame: CGRectMake( 140, 25, 200, 30 )];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont fontWithName:FONT_GLOBAL size:(15.0)];
    [profilePicView addSubview: nameLabel];
    
    // create the user's username label
    usernameLabel = [[UILabel alloc] initWithFrame: CGRectMake( 140, 50, 200, 30 )];
    usernameLabel.backgroundColor = [UIColor clearColor];
    usernameLabel.textColor = [UIColor whiteColor];
    usernameLabel.font = [UIFont fontWithName:FONT_GLOBAL size:11.0f];
    [profilePicView addSubview: usernameLabel];
    
    // add the bio
    bio = [[UILabel alloc] initWithFrame:CGRectMake(340, 0, 280, 100)];
    bio.textAlignment = NSTextAlignmentCenter;
    bio.textColor = [UIColor whiteColor];
    bio.backgroundColor = [UIColor clearColor];
    bio.numberOfLines = 2;
    bio.lineBreakMode = NSLineBreakByWordWrapping;
    bio.font = [UIFont fontWithName:FONT_GLOBAL size:11.0f];
    [profilePicView addSubview:bio];
    
    UIButton *button = [[UIButton alloc] initWithFrame:proThumbFrame];
    [profilePicView addSubview: button];
    [button addTarget: self
               action: @selector(showProfilePicture)
     forControlEvents: UIControlEventTouchDown];
    // add the profile pic view to the scroll view
    [scroll addSubview:profilePicView];
    
    // add the scroll view to the main view
    [self.view addSubview:scroll];
    
    // create the user's school  label
    schoolLabel = [[UILabel alloc] initWithFrame: CGRectMake(50, 200, 200, 30 )];
    schoolLabel.textColor = [UIColor whiteColor];
    schoolLabel.backgroundColor = [UIColor clearColor];
    schoolLabel.font = [UIFont fontWithName:FONT_GLOBAL size:(15.0)];
    
    // create the user's school status label
    schoolStatusLabel = [[UILabel alloc] initWithFrame: CGRectMake( 50, 260, 200, 30 )];
    schoolStatusLabel.textColor = [UIColor whiteColor];
    schoolStatusLabel.backgroundColor = [UIColor clearColor];
    schoolStatusLabel.font = [UIFont fontWithName:FONT_GLOBAL size:(15.0)];
    
    // create the user's grad year label
    gradYearLabel = [[UILabel alloc] initWithFrame: CGRectMake( 50, 300, 200, 30 )];
    gradYearLabel.textColor = [UIColor whiteColor];
    gradYearLabel.backgroundColor = [UIColor clearColor];
    gradYearLabel.font = [UIFont fontWithName:FONT_GLOBAL size:(15.0)];
    
   // [self.view addSubview:schoolLabel];
    [self.view addSubview:schoolStatusLabel];
    [self.view addSubview:gradYearLabel];
    
    // initialize the page control
    pageControl.numberOfPages = 2;
    pageControl.currentPage = 0;
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

    
    usernameLabel.text = self.user.username;
    if(![self.user.firstname isKindOfClass:[NSNull class]] && ![self.user.firstname isEqualToString:@""]) {
        nameLabel.text = [self.user.firstname stringByAppendingFormat:@" %@", self.user.lastname];
    } else {
        nameLabel.text = @"uLink User";
    }
    bio.text = (![self.user.bio isKindOfClass:[NSNull class]] && ![self.user.bio isEqualToString:@""]) ? self.user.bio : @"I haven't entered my bio yet, but rest assured when I do it will be amazing.";
    schoolStatusLabel.text = [@"Status: " stringByAppendingFormat:@" %@", self.user.schoolStatus];
    if(![self.user.year isKindOfClass:[NSNull class]] && ![self.user.year isEqualToString:@""]) {
        gradYearLabel.text = [@"Graduation Year: " stringByAppendingFormat:@" %@", self.user.year];
    } else {
        gradYearLabel.text = @"Graduation Year: unknown";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scroll.frame.size.width;
    int page = floor((scroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
}

- (IBAction)closeClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changePage:(UIPageControl *)sender {
    int page = self.pageControl.currentPage;
    CGRect frame = scroll.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scroll scrollRectToVisible:frame animated:YES];
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

@end
