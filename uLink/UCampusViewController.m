//
//  UCampusViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/19/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UCampusViewController.h"
#import "AppDelegate.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "ImageActivityIndicatorView.h"
#import "UserProfileViewController.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import "ULinkColorPalette.h"

@interface UCampusViewController () {
    UIScrollView *scroll;
    UIButton *topSnapperProfileButton;
    UIImageView *schoolImageView;
    NSTimer *scrollTimer;
    UIView *campusHome;
    UILabel *topSnapperLabel;
    UILabel *topSnapperUserNameLabel;
    UILabel *schoolLabel;
    UILabel *noSnapperLabel;
    UIImageView *ulinkLogo;
    UILabel *foundedLabel;
    UILabel *studentsLabel;
}
-(void) showCampusEvents:(UIButton *)sender;
-(void) showSocial:(UIButton *)sender;
-(void) showSnapshots:(UIButton *)sender;
-(void) loadTopSnapperImage;
-(void) loadSchoolImage;
-(void) viewUserProfileClick:(UIButton*)sender;
@end
@implementation UCampusViewController
@synthesize pageControl;
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
    self.tabBarController.navigationItem.hidesBackButton = YES;
    
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,screenHeight)];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    // make the contentsize, four times the height of the screen
    scroll.contentSize = CGSizeMake(320,screenHeight*4);
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.userInteractionEnabled = YES;
    scroll.backgroundColor = [UIColor blackColor];

    UIView *splashPicView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight*4)];
    splashPicView.userInteractionEnabled = YES;
    splashPicView.backgroundColor = [UIColor clearColor];
    
    // build the campus home page
    campusHome = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight)];
    campusHome.backgroundColor = [UIColor uLinkDarkGrayColor];
    
    // add the campus image
    schoolImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 0, 200, 200)];
    schoolImageView.contentMode = UIViewContentModeScaleAspectFit;
    [campusHome addSubview:schoolImageView];
    
    // build black label background
    UILabel *campusHomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 160, 280, 100)];
    campusHomeLabel.backgroundColor = [UIColor uLinkGreenColor];
    [campusHome addSubview:campusHomeLabel];
    
    [self buildView];
    
    // finally add the campus home page
    [splashPicView addSubview:campusHome];

    // add the campus events splash image button
    UIButton *campusImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [campusImageButton addTarget:self
                          action:@selector(showCampusEvents:)
               forControlEvents:UIControlEventTouchDown];
    campusImageButton.frame = CGRectMake(0, screenHeight, 320, screenHeight);
    [campusImageButton setImage:[UIImage imageNamed:@"ucla.png"] forState:UIControlStateNormal];
    campusImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    campusImageButton.userInteractionEnabled = YES;
    [splashPicView addSubview:campusImageButton];

    // add events title/sub title
    UILabel *eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, (screenHeight)+50, 320, 40)];
    eventTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:24.0];
    eventTitle.numberOfLines = 1;
    eventTitle.textAlignment = NSTextAlignmentLeft;
    eventTitle.textColor = [UIColor whiteColor];
    eventTitle.backgroundColor = [UIColor clearColor];
    eventTitle.text = @"Campus Events.";
    [splashPicView addSubview:eventTitle];
    UILabel *eventSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, (screenHeight)+95, 310, 40)];
    eventSubTitle.font = [UIFont fontWithName:FONT_GLOBAL size:16.0];
    eventSubTitle.numberOfLines = 2;
    eventSubTitle.textAlignment = NSTextAlignmentLeft;
    eventSubTitle.textColor = [UIColor whiteColor];
    eventSubTitle.backgroundColor = [UIColor clearColor];
    eventSubTitle.text = @"Keep in touch with what's happening on your campus.";
    [splashPicView addSubview:eventSubTitle];
    
    // add the social splash image button
    UIButton *socialImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [socialImageButton addTarget:self
                          action:@selector(showSocial:)
                forControlEvents:UIControlEventTouchDown];
    socialImageButton.frame = CGRectMake(0, screenHeight*2, 320, screenHeight);
    [socialImageButton setImage:[UIImage imageNamed:@"jmu_splash.png"] forState:UIControlStateNormal];
    socialImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    socialImageButton.userInteractionEnabled = YES;
    [splashPicView addSubview:socialImageButton];

    // add social title/sub title
    UILabel *socialTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, (screenHeight*2)+50, 320, 40)];
    socialTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:24.0];
    socialTitle.numberOfLines = 1;
    socialTitle.textAlignment = NSTextAlignmentLeft;
    socialTitle.textColor = [UIColor whiteColor];
    socialTitle.backgroundColor = [UIColor clearColor];
    socialTitle.text = @"Social Media.";
    [splashPicView addSubview:socialTitle];
    UILabel *socialSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, (screenHeight*2)+95, 310, 40)];
    socialSubTitle.font = [UIFont fontWithName:FONT_GLOBAL size:16.0];
    socialSubTitle.numberOfLines = 2;
    socialSubTitle.textAlignment = NSTextAlignmentLeft;
    socialSubTitle.textColor = [UIColor whiteColor];
    socialSubTitle.backgroundColor = [UIColor clearColor];
    socialSubTitle.text = @"What's trending for your school in the social media?";
    [splashPicView addSubview:socialSubTitle];
    
    // add the snapshots splash image button
    UIButton *snapImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [snapImageButton addTarget:self
                        action:@selector(showSnapshots:)
                forControlEvents:UIControlEventTouchDown];
    snapImageButton.frame = CGRectMake(0, screenHeight*3, 320, screenHeight);
    [snapImageButton setImage:[UIImage imageNamed:@"wisc_splash.png"] forState:UIControlStateNormal];
    snapImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    snapImageButton.userInteractionEnabled = YES;
    [splashPicView addSubview:snapImageButton];

    // add snapshots title/sub title
    UILabel *snapTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, (screenHeight*3)+50, 320, 40)];
    snapTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:24.0];
    snapTitle.numberOfLines = 1;
    snapTitle.textAlignment = NSTextAlignmentLeft;
    snapTitle.textColor = [UIColor whiteColor];
    snapTitle.backgroundColor = [UIColor clearColor];
    snapTitle.text = @"Snapshots.";
    [splashPicView addSubview:snapTitle];
    UILabel *snapSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, (screenHeight*3)+95, 310, 40)];
    snapSubTitle.font = [UIFont fontWithName:FONT_GLOBAL size:16.0];
    snapSubTitle.numberOfLines = 2;
    snapSubTitle.textAlignment = NSTextAlignmentLeft;
    snapSubTitle.textColor = [UIColor whiteColor];
    snapSubTitle.backgroundColor = [UIColor clearColor];
    snapSubTitle.text = @"Capture every moment of college, and share them with your school.";
    [splashPicView addSubview:snapSubTitle];

    // add the profile pic view to the scroll view
    [scroll addSubview:splashPicView];
    
    // add the scroll view to the main view
    [self.mainView insertSubview:scroll belowSubview:pageControl];
    
    
    self.mainView.userInteractionEnabled = YES;

    // initialize the page control
    self.pageControl.numberOfPages = 4;
    self.pageControl.currentPage = 0;
    self.pageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    // Register an observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationViewUpdate:) name:NOTIFICATION_UCAMPUS_VIEW_CONTROLLER
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    if(scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
    }
}

-(void) viewWillAppear:(BOOL)animated {
    // initialize the scroller if it's not already initilialized
    if(!scrollTimer) {
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval:AUTO_SCROLL_UCAMPUS_HOME_TIME target:self selector:@selector(scrollPages) userInfo:nil repeats:YES];
    }
    // We want the view to be on top every time the it is shown
    [scroll setContentOffset:CGPointMake(0,0) animated:NO];
    self.pageControl.currentPage = 0;
}

-(void)viewDidAppear:(BOOL)animated {
    // we need this to ensure the tab bar is able to have interactions
    self.navigationController.visibleViewController.view.userInteractionEnabled = YES;
    self.tabBarController.navigationItem.title = @"uCampus";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

// Handle the notification
- (void) notificationViewUpdate:(NSNotification*) notification {
    [self buildView];
}

- (void) buildView {
    
    // build black label background for the school information
    UILabel *schoolInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 290, 220, 100)];
    schoolInfoLabel.backgroundColor = [UIColor uLinkOrangeColor];
    [campusHome addSubview:schoolInfoLabel];
    
    // if there is a top snapper we can show their data
    if(![UDataCache.topSnapper.firstname isKindOfClass:[NSNull class]] && UDataCache.topSnapper.firstname != nil && ![UDataCache.topSnapper.firstname isEqualToString:@""]) {
        noSnapperLabel.alpha = ALPHA_ZERO;
        ulinkLogo.alpha = ALPHA_ZERO;
        [noSnapperLabel removeFromSuperview];
        [ulinkLogo removeFromSuperview];
        [self loadSchoolImage];
        if(!topSnapperLabel) {
            topSnapperLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 170, 160, 50)];
            topSnapperLabel.backgroundColor = [UIColor clearColor];
            topSnapperLabel.text = @"Top Snapper";
            topSnapperLabel.textColor = [UIColor whiteColor];
            topSnapperLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:20.0];
            [campusHome addSubview:topSnapperLabel];
        }
        
        if(topSnapperUserNameLabel) {
            topSnapperUserNameLabel.text = UDataCache.topSnapper.username;
        } else {
            topSnapperUserNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 200, 160, 50)];
            topSnapperUserNameLabel.backgroundColor = [UIColor clearColor];
            topSnapperUserNameLabel.text = UDataCache.topSnapper.username;
            topSnapperUserNameLabel.textColor = [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:ALPHA_MED];
            topSnapperUserNameLabel.font = [UIFont fontWithName:FONT_GLOBAL size:16.0];
            [campusHome addSubview:topSnapperUserNameLabel];
        }
        
        if (topSnapperProfileButton) {
            [topSnapperProfileButton setImage:UDataCache.topSnapper.profileImage forState:UIControlStateNormal];
            [self loadTopSnapperImage];
        } else {
            // add the top snapper's profile button
            topSnapperProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [topSnapperProfileButton addTarget:self
                                        action:@selector(viewUserProfileClick:)
                              forControlEvents:UIControlEventTouchDown];
            topSnapperProfileButton.frame = CGRectMake(60, 170, 80, 80);
            topSnapperProfileButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            topSnapperProfileButton.userInteractionEnabled = YES;
            topSnapperProfileButton.imageView.layer.cornerRadius = 40;
            topSnapperProfileButton.imageView.layer.masksToBounds = YES;
            [topSnapperProfileButton setImage:UDataCache.topSnapper.profileImage forState:UIControlStateNormal];
            [campusHome addSubview:topSnapperProfileButton];
            [self loadTopSnapperImage];
        }
        
        // school name label
        if(schoolLabel) {
             schoolLabel.text = UDataCache.sessionUser.schoolName;
        } else {
            schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 285, 300, 50)];
            schoolLabel.backgroundColor = [UIColor clearColor];
            schoolLabel.text = UDataCache.sessionUser.schoolName;
            schoolLabel.textColor = [UIColor whiteColor];
            schoolLabel.font = [UIFont fontWithName:FONT_GLOBAL size:18.0];
            [campusHome addSubview:schoolLabel];
        }
    } else { // else show label that states there needs to be a top snapper
        // no top snapper label
        if(!noSnapperLabel) {
            noSnapperLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 180, 240, 50)];
            noSnapperLabel.backgroundColor = [UIColor clearColor];
            noSnapperLabel.numberOfLines = 3;
            noSnapperLabel.text = @"Welcome to uCampus, here you will be able to stay up to date with all that is happening on your campus!";
            noSnapperLabel.textColor = [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:ALPHA_MED];
            noSnapperLabel.font = [UIFont fontWithName:FONT_GLOBAL size:13.0];
            [campusHome addSubview:noSnapperLabel];
            
            // add the ulink logo
            ulinkLogo = [[UIImageView alloc] initWithFrame:CGRectMake(60, 0, 200, 200)];
            ulinkLogo.contentMode = UIViewContentModeScaleAspectFit;
            ulinkLogo.image = [UIImage imageNamed:@"logouLinkv2.png"];
            [campusHome addSubview:ulinkLogo];
        }
    }
    
    /*
     * NOTE: For now we are using the top snapper's school info, but we will move it over to use
     * the session user's down the road
     */
    
    if(![UDataCache.topSnapper.school.year isKindOfClass:[NSNull class]] && UDataCache.topSnapper.school.year != nil && ![UDataCache.topSnapper.school.year isEqualToString:@""]) {
        // founded label
        if (foundedLabel) {
            foundedLabel.text = [@"Founded in " stringByAppendingString:UDataCache.topSnapper.school.year];
        } else {
            foundedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 315, 200, 50)];
            foundedLabel.backgroundColor = [UIColor clearColor];
            foundedLabel.text = [@"Founded in " stringByAppendingString:UDataCache.topSnapper.school.year];
            foundedLabel.textColor = [UIColor whiteColor];
            foundedLabel.font = [UIFont fontWithName:FONT_GLOBAL size:18.0];
            [campusHome addSubview:foundedLabel];
        }
    }
    
    if(![UDataCache.topSnapper.school.attendance isKindOfClass:[NSNull class]] && UDataCache.topSnapper.school.attendance != nil && ![UDataCache.topSnapper.school.attendance isEqualToString:@""]) {
        // number of students label
        if (studentsLabel) {
            studentsLabel.text = [UDataCache.topSnapper.school.attendance stringByAppendingString:@" Students"];
        } else {
            studentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 345, 200, 50)];
            studentsLabel.backgroundColor = [UIColor clearColor];
            
            studentsLabel.text = [UDataCache.topSnapper.school.attendance stringByAppendingString:@" Students"];
            studentsLabel.textColor = [UIColor whiteColor];
            studentsLabel.font = [UIFont fontWithName:FONT_GLOBAL size:18.0];
            [campusHome addSubview:studentsLabel];
        }
    }
}


- (void) scrollPages {
    // get the current offset ( which page is being displayed )
    CGFloat contentOffset = scroll.contentOffset.y;
    // calculate next page to display
    int nextPage = (int)(contentOffset/scroll.frame.size.height) + 1 ;
    // if we are not on the last page, we can show the page
    if( nextPage != self.pageControl.numberOfPages )  {
        [scroll scrollRectToVisible:CGRectMake(0, nextPage*scroll.frame.size.height, scroll.frame.size.width, scroll.frame.size.height) animated:YES];
        self.pageControl.currentPage=nextPage;
    } else {  // else start sliding from the first page
        [scroll scrollRectToVisible:CGRectMake(0, 0, scroll.frame.size.width, scroll.frame.size.height) animated:YES];
        self.pageControl.currentPage=0;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    // stop timer
    if(scrollTimer != nil) {
        [scrollTimer invalidate];
        scrollTimer = nil;
    }

    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageHeight = scroll.frame.size.height;
    int page = floor((scroll.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    self.pageControl.currentPage = page;
    
    // start timer
    if(scrollTimer == nil) {
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval:AUTO_SCROLL_UCAMPUS_HOME_TIME target:self selector:@selector(scrollPages) userInfo:nil repeats:YES];
    }
}

- (IBAction)changePage:(UIPageControl *)sender {
    int page = self.pageControl.currentPage;
    CGRect frame = scroll.frame;
    frame.origin.x = 0;
    frame.origin.y = frame.size.height * page;
    [scroll scrollRectToVisible:frame animated:YES];
}

- (void)viewUserProfileClick:(UIButton*)sender {
    UserProfileViewController *viewProfileController = [self.storyboard instantiateViewControllerWithIdentifier:CONTROLLER_USER_PROFILE_VIEW_CONTROLLER_ID];
    viewProfileController.user = UDataCache.topSnapper;
    [self.navigationController presentViewController:viewProfileController animated:YES completion:nil];
}

-(void) showCampusEvents:(UIButton *)sender {
    [self performSegueWithIdentifier:SEGUE_SHOW_CAMPUS_EVENTS_VIEW_CONTROLLER sender:sender];
}
-(void) showSocial:(UIButton *)sender {
    [self performSegueWithIdentifier:SEGUE_SHOW_SOCIAL_VIEW_CONTROLLER sender:sender];
}
-(void) showSnapshots:(UIButton *)sender {
     [self performSegueWithIdentifier:SEGUE_SHOW_SNAPSHOTS_VIEW_CONTROLLER sender:sender];
}

-(void) performSegue:(NSInteger)item {
    switch (item) {
       case 0:
            [self performSegueWithIdentifier:SEGUE_SHOW_CAMPUS_EVENTS_VIEW_CONTROLLER sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:SEGUE_SHOW_SNAPSHOTS_VIEW_CONTROLLER sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:SEGUE_SHOW_SOCIAL_VIEW_CONTROLLER sender:self];
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    scrollTimer = nil;
    topSnapperLabel = nil;
    topSnapperUserNameLabel = nil;
    schoolLabel = nil;
}

#pragma mark Image loading
- (void) loadTopSnapperImage {
    // grab the user's image from the user cache
    UIImage *profileImage = [UDataCache imageExists:UDataCache.topSnapper.userId cacheModel:IMAGE_CACHE_USER_MEDIUM];
    if (profileImage == nil || [profileImage isKindOfClass:[NSNull class]]) {
        if(![UDataCache.topSnapper.userImgURL isKindOfClass:[NSNull class]] && UDataCache.topSnapper.userImgURL != nil && ![UDataCache.topSnapper.userImgURL isEqualToString:@""]) {
            // set the key in the cache to let other processes know that this key is in work
            [UDataCache.userImageMedium setValue:[NSNull null] forKey:UDataCache.topSnapper.userId];
            // lazy load the image from the web
            NSURL *url = [NSURL URLWithString:[URL_USER_IMAGE_MEDIUM stringByAppendingString:UDataCache.topSnapper.userImgURL]];
            __block ImageActivityIndicatorView *activityIndicator;
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            [imageDownloader downloadImageWithURL:url
                                          options:SDWebImageDownloaderProgressiveDownload
                                         progress:^(NSUInteger receivedSize, long long expectedSize) {
                                             if (!activityIndicator)
                                             {
                                                 activityIndicator = [[ImageActivityIndicatorView alloc] init];
                                                 [activityIndicator showActivityIndicator:topSnapperProfileButton.imageView];
                                             }
                                         }
                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                            if (image && finished)
                                            {
                                                // add the user's image to the image cache
                                                [UDataCache.userImageMedium setValue:image forKey:UDataCache.topSnapper.userId];
                                                // set the picture in the view
                                                [topSnapperProfileButton setImage:image forState:UIControlStateNormal];
                                                [activityIndicator hideActivityIndicator:topSnapperProfileButton.imageView];
                                                activityIndicator = nil;
                                            }
                                        }];
        }
    } else if (![profileImage isKindOfClass:[NSNull class]]) {
        [topSnapperProfileButton setImage:profileImage forState:UIControlStateNormal];
    }
    
}
-(void) loadSchoolImage {
    // grab the school image from the images cache
    UIImage *schoolImage = [UDataCache imageExists:KEY_SESSION_USER_SCHOOL cacheModel:IMAGE_CACHE];
    if (schoolImage == nil || [schoolImage isKindOfClass:[NSNull class]]) {
        if(![UDataCache.topSnapper.school.imageURL isKindOfClass:[NSNull class]] && UDataCache.topSnapper.school.imageURL != nil && ![UDataCache.topSnapper.school.imageURL isEqualToString:@""]) {
            // set the key in the cache to let other processes know that this key is in work
            [UDataCache.images setValue:[NSNull null] forKey:UDataCache.topSnapper.school.imageURL];
            // lazy load the image from the web
            NSURL *url = [NSURL URLWithString:[URL_SCHOOL_IMAGE stringByAppendingString:UDataCache.topSnapper.school.imageURL]];
            __block ImageActivityIndicatorView *sActivityIndicator;
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            [imageDownloader downloadImageWithURL:url
                                          options:SDWebImageDownloaderProgressiveDownload
                                         progress:^(NSUInteger receivedSize, long long expectedSize) {
                                             if (!sActivityIndicator)
                                             {
                                                 sActivityIndicator = [[ImageActivityIndicatorView alloc] init];
                                                 [sActivityIndicator showActivityIndicator:schoolImageView];
                                             }
                                         }
                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                            if (image && finished)
                                            {
                                                // add the school's image to the image cache
                                                [UDataCache.images setValue:image forKey:KEY_SESSION_USER_SCHOOL];
                                                // set the picture in the view
                                                schoolImageView.image = image;
                                                [sActivityIndicator hideActivityIndicator:schoolImageView];
                                                sActivityIndicator = nil;
                                            }
                                        }];
        }
    } else if (![schoolImage isKindOfClass:[NSNull class]]) {
        schoolImageView.image = schoolImage;
    }
}
#pragma mark
@end
