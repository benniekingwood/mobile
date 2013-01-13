//
//  ProfileViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/12/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppMacros.h"
#import "DataCache.h"
@interface ProfileViewController () {
    UIBarButtonItem *settingsButton;
    UIView *profilePicView, *currentProfilePic;
    CGRect proPicFrame;
    ProfilePictureViewController *profilePictureViewController;
}
@end

@implementation ProfileViewController
@synthesize snapCountLabel, eventsCountLabel;
@synthesize containerView;
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
    self.navigationItem.leftBarButtonItem = nil;
    proPicFrame = CGRectMake(0, 70, 320, 320);
    CGRect profilePicViewFrame;
    profilePicViewFrame.origin.x = 0;
    profilePicViewFrame.origin.y = 0;
    profilePicViewFrame.size = self.view.frame.size;
    profilePicView = [[UIView alloc] initWithFrame:profilePicViewFrame];
    profilePicView.backgroundColor = [UIColor blackColor];
    profilePicView.frame = profilePicViewFrame;
    profilePicView.userInteractionEnabled = YES;
    settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ulink-mobile-settings-icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingsViewController)];
    self.snapCountLabel.font = [UIFont fontWithName:FONT_GLOBAL size:60.0f];
    self.snapCountLabel.textAlignment = NSTextAlignmentRight;
    self.eventsCountLabel.font = [UIFont fontWithName:FONT_GLOBAL size:60.0f];
    self.eventsCountLabel.textAlignment = NSTextAlignmentRight;
    
   
    
/*
    profilePictureViewController = [self.storyboard instantiateViewControllerWithIdentifier:CONTROLLER_PROFILE_PICTURE_VIEW_CONTROLLER_ID];
    // make sure that it resizes on rotation automatically
	profilePictureViewController.view.autoresizingMask = self.containerView.autoresizingMask;
    profilePictureViewController.view.frame = CGRectMake(320, 0, 320, 120);
    // adjust the frame to fit in the container view
	//profilePictureViewController.view.frame = self.containerView.bounds;
    
    UILabel *label = [[UILabel alloc]  initWithFrame:CGRectMake(0,0,100, 100)];
    label.backgroundColor = [UIColor yellowColor];
    label.text = @"hellow";
    [profilePictureViewController.view addSubview:label];
    
    [self addChildViewController:profilePictureViewController];
    [self.view addSubview:profilePictureViewController.view];
    [profilePictureViewController didMoveToParentViewController:self]; */
}

-(void)viewWillAppear:(BOOL)animated {
    self.tabBarController.navigationItem.title = @"Me";
    self.tabBarController.navigationItem.rightBarButtonItem = settingsButton;
    self.snapCountLabel.text = [NSString stringWithFormat:@"%i",[UDataCache.sessionUser.snaps count]];
    self.eventsCountLabel.text = [NSString stringWithFormat:@"%i",[UDataCache.sessionUser.events count]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) showSettingsViewController {
    [self performSegueWithIdentifier:SEGUE_SHOW_SETTINGS_VIEW_CONTROLLER sender:self];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// We only support single touches, so anyObject retrieves just that one touch from touches
	UITouch *touch = [touches anyObject];
	
	// animate touched square
	if([touch view] == profilePicView || [touch view] == currentProfilePic) {
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
                         profilePicView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         // Wait one second and then fade in the view
                         [profilePicView removeFromSuperview];
                     }];
}

-(void) showProfilePicture:(UIImage *) profileImage {
    // create and add the profile picture subview
    UIImageView *profilePicLarge = [[UIImageView alloc] initWithImage:profileImage];
    profilePicLarge.frame = proPicFrame;
    currentProfilePic = profilePicLarge;
    currentProfilePic.userInteractionEnabled = YES;
    [profilePicView addSubview:profilePicLarge];
    profilePicView.alpha = 0.0;
    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         profilePicView.alpha = 1.0;
                         [self.view addSubview:profilePicView];
                     }
                     completion:nil];
}

-(void) showEditProfileViewController {
    [self performSegueWithIdentifier:SEGUE_SHOW_EDIT_PROFILE_VIEW_CONTROLLER sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_EDIT_PROFILE_VIEW_CONTROLLER])
    {
        EditProfileViewController *editProfileViewController = [segue destinationViewController];
        // set the profile picture controller as the delegate
        for (UIViewController *childViewController in self.childViewControllers)
        {
            if ([childViewController isKindOfClass:[ProfilePictureViewController class]])
            {
                //found container view controller
                ProfilePictureViewController *profilePicViewController = (ProfilePictureViewController *)childViewController;
                editProfileViewController.delegate = profilePicViewController;
                //do something with your container view viewcontroller
               // [profilePicViewController updateProfileInformation];
                break;
            }
        }

    }
}
/*- (void) updateProfileInfo {
    //ProfilePictureViewController *profilePicViewController = [self.storyboard instantiateViewControllerWithIdentifier:CONTROLLER_PROFILE_PICTURE_VIEW_CONTROLLER];
    for (UIViewController *childViewController in self.childViewControllers)
    {
        if ([childViewController isKindOfClass:[ProfilePictureViewController class]])
        {
            //found container view controller
            ProfilePictureViewController *profilePicViewController = (ProfilePictureViewController *)childViewController;
            
            //do something with your container view viewcontroller
             [profilePicViewController updateProfileInformation];
            break;
        }
    }
   
}*/

@end