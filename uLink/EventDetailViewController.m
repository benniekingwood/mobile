//
//  EventDetailViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/26/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "EventDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMacros.h"
#import "UserProfileButton.h"
#import "UserProfileViewController.h"
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import "DataCache.h"
#import "ActivityIndicatorView.h"
#import "SuccessNotificationView.h"
#import "AlertView.h"
#import <Pixate/Pixate.h>
@interface EventDetailViewController () {
    UserProfileButton *eventUserImageButton;
    UIActionSheet *optionsActionSheet;
    AlertView *errorAlertView;
    ActivityIndicatorView *activityIndicator;
    SuccessNotificationView *successNotification;
    UIBarButtonItem *optionsButton;
}
- (void)viewUserProfileClick:(UserProfileButton*)sender;
- (void)reportFlag;
@end

@implementation EventDetailViewController
@synthesize eventImageView, eventInfoView, eventUserPicView;
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
    // build user image button
    eventUserImageButton = [UserProfileButton buttonWithType:UIButtonTypeCustom];
    [eventUserImageButton addTarget:self
                             action:@selector(viewUserProfileClick:)
                   forControlEvents:UIControlEventTouchDown];
    eventUserImageButton.frame = CGRectMake(20, 160, 50, 50);
    eventUserImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
    eventUserImageButton.layer.borderWidth = 1.0f;
    [self.view addSubview:eventUserImageButton];
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: @""
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    successNotification = [[SuccessNotificationView alloc] init];
    // add the "Options" button
    UIButton *optionsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    optionsBtn.frame = CGRectMake(0.0, 0.0, 40,40);
    [optionsBtn setTitle:@"e" forState:UIControlStateNormal];
    [optionsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    optionsBtn.styleClass = @"icon icon-large";
    [optionsBtn addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    
    optionsButton = [[UIBarButtonItem alloc] initWithCustomView:optionsBtn];
    self.navigationItem.rightBarButtonItem = optionsButton;
    
    optionsActionSheet = [[UIActionSheet alloc]
                          initWithTitle:nil
                          delegate:self
                          cancelButtonTitle:BTN_CANCEL
                          destructiveButtonTitle:BTN_REPORT_INAPPROPRIATE
                          otherButtonTitles:nil, nil];

}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    eventUserImageButton.user = self.event.user;
    [eventUserImageButton initialize];
    self.eventInfoView.text = self.event.information;
    self.eventUserPicView.image = self.event.user.profileImage;
    self.eventImageView.image = self.event.image;
    // grab the event image from the event cache
    UIImage *eventImage = [UDataCache imageExists:self.event.eventId cacheModel:IMAGE_CACHE_EVENT_MEDIUM];
    if (eventImage == nil) {
        if(![self.event.imageURL isKindOfClass:[NSNull class]] && self.event.imageURL != nil && ![self.event.imageURL isEqualToString:@""] && ![self.event.imageURL isEqualToString:@"<null>"]) {
        // set the key in the cache to let other processes know that this key is in work
        [UDataCache.eventImageMedium setValue:[NSNull null]  forKey:self.event.eventId];
        NSURL *url = [NSURL URLWithString:[URL_EVENT_IMAGE_MEDIUM stringByAppendingString:self.event.imageURL]];
        __block ImageActivityIndicatorView *iActivityIndicator;
        SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
        [imageDownloader downloadImageWithURL:url
                                      options:SDWebImageDownloaderProgressiveDownload
                                     progress:^(NSUInteger receivedSize, long long expectedSize) {
                                         if (!iActivityIndicator)
                                         {
                                             iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
                                             [iActivityIndicator showActivityIndicator:self.eventImageView];
                                         }
                                     }
                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                        if (image && finished)
                                        {
                                            // add the event image to the image cache
                                            [UDataCache.eventImageMedium setValue:image forKey:self.event.eventId];
                                            // set the picture in the view
                                            self.eventImageView.image = image;
                                            [iActivityIndicator hideActivityIndicator:self.eventImageView];
                                            iActivityIndicator = nil;
                                        }
                                    }];
        }
    } else if (![eventImage isKindOfClass:[NSNull class]]){
        self.eventImageView.image = eventImage;
    }
    

    
    self.eventDateTime.text = [self.event.clearDate stringByAppendingFormat:@" %@", self.event.time];
    self.eventUsername.text = self.event.user.username;
    self.eventTitle.text = self.event.title;
    self.eventLocation.text = self.event.location;
}
#pragma mark UIActionSheet Section
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:BTN_REPORT_INAPPROPRIATE]) {
        [self reportFlag];
    }
}
- (void)showActionSheet:(id)sender {
    [optionsActionSheet showInView:self.view];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewUserProfileClick:(UserProfileButton*)sender {
    UserProfileViewController *viewProfileController = [self.storyboard instantiateViewControllerWithIdentifier:CONTROLLER_USER_PROFILE_VIEW_CONTROLLER_ID];
    viewProfileController.user = sender.user;
    [self.navigationController presentViewController:viewProfileController animated:YES completion:nil];
}
- (void)reportFlag {
    @try {
        [activityIndicator showActivityIndicator:self.view];
        NSString *requestData = [@"&data[Flag][event_id]=" stringByAppendingString:self.event.eventId];
        requestData = [requestData stringByAppendingString:@"&data[Flag][inappropriate]=1"];
        requestData = [requestData stringByAppendingString:[@"&data[reporter_user_id]=" stringByAppendingString:UDataCache.sessionUser.userId]];
        requestData = [requestData stringByAppendingString:[@"&data[mobile_auth]=" stringByAppendingString:UDataCache.sessionUser.userId]];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_FLAGS_INSERT_FLAG]]];
        [req setHTTPMethod:HTTP_POST];
        [req setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [req setHTTPShouldHandleCookies:NO];
        [req setTimeoutInterval:15];
        [req setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
        
        // how we stop refresh from freezing the main UI thread
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicator hideActivityIndicator:self.view];
                if ([data length] > 0 && error == nil) {
                    NSError* err;
                    NSDictionary* json = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:kNilOptions
                                          error:&err];
                    NSString *response = (NSString*)[json objectForKey:JSON_KEY_RESPONSE];
                    
                    if([response isEqualToString:@"true"]) {
                        [successNotification setMessage:@"This event was flagged."];
                        [successNotification showNotification:self.view];
                    } else {
                        errorAlertView.message = @"There was a problem flagging this event.  Please try again later or contact help@theulink.com.";
                        [errorAlertView show];
                    }
                } else {
                    errorAlertView.message = @"There was a problem flagging this event.  Please try again later or contact help@theulink.com.";
                    // show alert to user
                    [errorAlertView show];
                }
            });
        }];
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        // show alert to user
        [errorAlertView show];
    }
}
@end
