//
//  ListingDetailViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 6/1/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "ListingDetailViewController.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "ActivityIndicatorView.h"
#import "SuccessNotificationView.h"
#import "AlertView.h"
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>
@interface ListingDetailViewController () {
    UIScrollView *listingPhotosScrollView;
    NSTimer *scrollTimer;
    UIActionSheet *optionsActionSheet;
    AlertView *errorAlertView;
    ActivityIndicatorView *activityIndicator;
    SuccessNotificationView *successNotification;
    UIScrollView *mainScrollView2;
    UIPageControl *pageControl;
    UlinkButton *flagButton;
}
- (void) scrollPages;
- (void) buildListingPhotoView;
- (void) emailLister;
- (void)reportFlag:(NSString*)reportType;
@end

@implementation ListingDetailViewController
@synthesize listing = _listing;
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
    // create the scroll view that has the listing detail information
    mainScrollView2 = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,435)];
    mainScrollView2.delegate = self;
    mainScrollView2.userInteractionEnabled = YES;
    mainScrollView2.scrollEnabled = YES;
    mainScrollView2.alwaysBounceVertical = YES;
    mainScrollView2.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:mainScrollView2 belowSubview:self.contactListerBackground];
    
    // add the top border to the view with the contact listing button
    self.contactListerBackground.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.contactListerBackground.layer.borderWidth = 0.5f;
    // buld the alert, activity, and success notification views
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: @""
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    successNotification = [[SuccessNotificationView alloc] init];
    
    // add the background view for the title
    UILabel *titleBg = [[UILabel alloc] initWithFrame:CGRectMake(0, 108, 320, 54)];
    titleBg.backgroundColor = [UIColor colorWithRed:(30.0 / 255.0) green:(30.0 / 255.0) blue:(34.0 / 255.0) alpha: 1];
    [mainScrollView2 addSubview:titleBg];
    
    // build the page control
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 98, 320, 36)];
    pageControl.currentPage = 0;
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:(255.0 / 255.0) green:(146.0 / 255.0) blue:(23.0 / 255.0) alpha: 1];
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [mainScrollView2 addSubview:pageControl];
    
    // create the scroll view for the listing photos
    listingPhotosScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,108)];
    listingPhotosScrollView.delegate = self;
    listingPhotosScrollView.pagingEnabled = YES;
    listingPhotosScrollView.showsHorizontalScrollIndicator = NO;
    listingPhotosScrollView.userInteractionEnabled = YES;
    listingPhotosScrollView.scrollEnabled = YES;
    
    // build up the photos at the top of the view
    [self buildListingPhotoView];
    
    // create the contact lister button and add its target action
    [self.contactListerButton createOrangeButton:self.contactListerButton];
    [self.contactListerButton addTarget:self action:@selector(emailLister) forControlEvents:UIControlEventTouchUpInside];
    
    // create the flag button and add its target action
    flagButton = [UlinkButton buttonWithType:UIButtonTypeCustom];
    [flagButton setTitle:@"Flag" forState:UIControlStateNormal];
    flagButton.frame = CGRectMake(226.0, 170.0, 80.0, 27.0);
    [flagButton setImageEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
    [(UlinkButton*)flagButton createRedButton:flagButton];
    [flagButton addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView2 addSubview:flagButton];
    
    // initialize the options sheet for when the user clicks the flag button
    optionsActionSheet = [[UIActionSheet alloc]
                          initWithTitle:nil
                          delegate:self
                          cancelButtonTitle:BTN_CANCEL
                          destructiveButtonTitle:BTN_REPORT_INAPPROPRIATE
                          otherButtonTitles:BTN_REPORT_MISCATEGORIZED, BTN_REPORT_SPAM, nil];
    
    // load the listing data onto the view
    // listing title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 103, 320, 50)];
    title.numberOfLines = 2;
    title.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:17];
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentLeft;
    title.text = self.listing.title;
    [mainScrollView2 addSubview:title];
    
    // start building the username label
    UILabel *username = [[UILabel alloc] init];
    username.textColor = [UIColor blackColor];
    username.backgroundColor = [UIColor clearColor];
    username.textAlignment = NSTextAlignmentLeft;
    username.text = self.listing.username;
    
    // price (if available)
    if(self.listing.price > 0) {
        // add the price format with the username below it
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 250, 50)];
        price.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:36];
        price.textColor = [UIColor colorWithRed:(19.0 / 255.0) green:(122.0 / 255.0) blue:(188.0 / 255.0) alpha: 1];
        price.backgroundColor = [UIColor clearColor];
        price.textAlignment = NSTextAlignmentLeft;
        NSNumber *myDoubleNumber = [NSNumber numberWithDouble:self.listing.price];
        price.text = [@"$" stringByAppendingString:[myDoubleNumber stringValue]];
        [mainScrollView2 addSubview:price];
        username.font = [UIFont fontWithName:FONT_GLOBAL size:16];
        username.frame = CGRectMake(20, 190, 200, 50);
    } else {
        username.frame = CGRectMake(20, 170, 200, 50);
        // add the username, make it a bit larger since there is no price
        username.font = [UIFont fontWithName:FONT_GLOBAL size:26];
    }
    // finally add the username to the view
    [mainScrollView2 addSubview:username];
    
    // location
    UILabel *location = [[UILabel alloc] init];
    location.textColor = [UIColor blackColor];
    location.backgroundColor = [UIColor clearColor];
    location.textAlignment = NSTextAlignmentLeft;
    location.font = [UIFont fontWithName:FONT_GLOBAL size:14];
    location.frame = CGRectMake(20, 205, 280, 50);
    location.numberOfLines = 2;
    location.lineBreakMode = NSLineBreakByWordWrapping;
    NSString *locText = self.listing.location.street;
    if ([locText isEqualToString:EMPTY_STRING]) {
        locText = self.listing.location.city;
    } else {
        locText = [locText stringByAppendingString:@","];
        if(![self.listing.location.city isEqualToString:EMPTY_STRING]) {
            locText = [locText stringByAppendingString:self.listing.location.city];
        }
    }
    locText = [locText stringByAppendingString:@" "];
    locText = [locText stringByAppendingString:self.listing.location.state];
    locText = [locText stringByAppendingString:@" "];
    locText = [locText stringByAppendingString:self.listing.location.zip];
    location.text = locText;
    [mainScrollView2 addSubview:location];
    
    // divider line
    UIImageView *divider = [[UIImageView alloc] initWithFrame:CGRectMake(0, 245, 320, 20)];
    divider.image = [UIImage imageNamed:@"mobile-dotted-divider"];
    divider.alpha = ALPHA_MED;
    [mainScrollView2 addSubview:divider];
    
    // description Header
    UILabel *descriptionHeader =[[UILabel alloc] initWithFrame:CGRectMake(20, 260, 280, 30)];
    descriptionHeader.textColor = [UIColor blackColor];
    descriptionHeader.backgroundColor = [UIColor clearColor];
    descriptionHeader.textAlignment = NSTextAlignmentLeft;
    descriptionHeader.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:17];
    descriptionHeader.text = @"description";
    [mainScrollView2 addSubview:descriptionHeader];
    
    // description 
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20, 290, 280, 250)];
    description.textColor = [UIColor blackColor];
    description.backgroundColor = [UIColor clearColor];
    description.textAlignment = NSTextAlignmentLeft;
    description.font = [UIFont fontWithName:FONT_GLOBAL size:12];
    description.text = self.listing.listDescription;
    description.lineBreakMode = NSLineBreakByWordWrapping;
    description.numberOfLines = 1000000;
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(280, 4000);
    
    CGSize expectedLabelSize = [self.listing.listDescription sizeWithFont:description.font
                                constrainedToSize:maximumLabelSize
                                lineBreakMode:description.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = description.frame;
    newFrame.size.height = expectedLabelSize.height;
    description.frame = newFrame;
    [mainScrollView2 addSubview:description];
    // now we need to check to see if we need to resize the content size of the main scroll view
    
    // if the description height is now greater than 100 pixels, we will take the current content size of the main scroll view and add the desciption height - 100 to it.
    if(description.frame.size.height > 100.0f) { 
        mainScrollView2.contentSize = CGSizeMake(320, description.frame.size.height+400);
    }
}

-(void)viewWillAppear:(BOOL)animated {
    if(pageControl.numberOfPages == 1) {
        pageControl.alpha = ALPHA_ZERO;
    } else {
        pageControl.alpha = ALPHA_HIGH;
        // initialize the scroller if it's not already initilialized
        if(!scrollTimer) {
            // since there are more than one page initialize the auto scroll timer
            // enable timer after each 2 seconds for scrolling.
            scrollTimer = [NSTimer scheduledTimerWithTimeInterval:AUTO_SCROLL_LISTING_PIC_TIME target:self selector:@selector(scrollPages) userInfo:nil repeats:YES];
        }
    }
    
    // We want the view to be on top every time the it is shown
    [listingPhotosScrollView setContentOffset:CGPointMake(0,0) animated:NO];
    pageControl.currentPage = 0;
}

- (void) viewWillDisappear:(BOOL)animated {
    if(scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
    }
}
- (void) buildListingPhotoView {
    [listingPhotosScrollView removeFromSuperview];
    pageControl.numberOfPages = 0;
    float currentX = 0;
    // create the main view for the listing photos
    UIView *listingPhotosView = [[UIView alloc] initWithFrame:CGRectMake(currentX, 0, listingPhotosScrollView.frame.size.width, listingPhotosScrollView.frame.size.height)];
    listingPhotosView.backgroundColor = [UIColor clearColor];
    listingPhotosView.userInteractionEnabled = YES;
    
    // first grab the listing images for the school
    NSMutableDictionary *schoolListingImages = [UDataCache.listingImageMedium objectForKey:[NSString stringWithFormat:@"%d", self.listing.schoolId]];

    // initialize the school listing image cache for the current school
    if(schoolListingImages == nil) {
        schoolListingImages = [[NSMutableDictionary alloc] init];
    }
    
    // first check to see if this listing has images in the medium cache, if it is not, load a default image
    if (self.listing.imageUrls == nil || self.listing.imageUrls.count == 0) {
        UIImageView *dummyFeatureView = [[UIImageView alloc] init];
        dummyFeatureView.frame = CGRectMake(currentX, 0, listingPhotosScrollView.frame.size.width, listingPhotosScrollView.frame.size.height);
        dummyFeatureView.image = [UDataCache.images objectForKey:KEY_DEFAULT_LISTING_IMAGE];
        dummyFeatureView.contentMode = UIViewContentModeScaleAspectFill;
        [listingPhotosView addSubview:dummyFeatureView];
    } else {
        
        /*
         * iterate over the image urls and check to see if there is an image
         * for the url in the listing image cache.  If there ever is a case where there
         * isn't an image, we need to load it in the background with SDwebImage.
         */
        for (NSString *imageURL in self.listing.imageUrls) {
            
            // build the listing photo view
            UIImageView *listingPhotoView = [[UIImageView alloc] init];
            listingPhotoView.frame = CGRectMake(currentX, 0, listingPhotosScrollView.frame.size.width, listingPhotosScrollView.frame.size.height);
            listingPhotoView.contentMode = UIViewContentModeScaleAspectFill;
            [listingPhotosView addSubview:listingPhotoView];
            
            // grab the event image from the event cache
            UIImage *listingImage = [schoolListingImages objectForKey:imageURL];
            if (listingImage == nil) {
                    // set the key in the cache to let other processes know that this key is in work
                    [schoolListingImages setValue:[NSNull null]  forKey:imageURL];
                    NSURL *url = [NSURL URLWithString:[URL_LISTING_IMAGE_MEDIUM stringByAppendingString:imageURL]];
                    __block ImageActivityIndicatorView *iActivityIndicator;
                    SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
                    [imageDownloader downloadImageWithURL:url
                                                  options:SDWebImageDownloaderProgressiveDownload
                                                 progress:^(NSUInteger receivedSize, long long expectedSize) {
                                                     if (!iActivityIndicator)
                                                     {
                                                         iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
                                                         [iActivityIndicator showActivityIndicator:listingPhotoView];
                                                     }
                                                 }
                                                completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                                    if (image && finished)
                                                    {
                                                        // add the event image to the image cache
                                                        [schoolListingImages setValue:image forKey:imageURL];
                                                        // set the picture in the view
                                                        listingPhotoView.image = image;
                                                        [iActivityIndicator hideActivityIndicator:listingPhotoView];
                                                        iActivityIndicator = nil;
                                                    }
                                                }];
            } else if (![listingImage isKindOfClass:[NSNull class]]){
                listingPhotoView.image = listingImage;
            }
            
            // increment currentX
            currentX += 320;
            
            // increment number of pages
            pageControl.numberOfPages++;
        } // end the looping of listing images
        
        // set the school listing images back in the cache
        [UDataCache.listingImageMedium setValue:schoolListingImages forKey:[NSString stringWithFormat:@"%d", self.listing.schoolId]];
    } 
    
    CGRect frame = listingPhotosView.frame;
    frame.size.width = listingPhotosScrollView.frame.size.width*pageControl.numberOfPages;
    listingPhotosView.frame = frame;
    // add the featured events to scroll view
    [listingPhotosScrollView addSubview:listingPhotosView];
    // set this to be 320 x number of pages
    listingPhotosScrollView.contentSize = CGSizeMake(320*pageControl.numberOfPages, listingPhotosScrollView.frame.size.height);
    
    // reset the current page for the page control back to the first page
    pageControl.currentPage = 0;
    
    // add the scroll view to the main view
    [mainScrollView2 addSubview:listingPhotosScrollView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
#pragma mark ScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    // stop timer
    if(scrollTimer != nil) {
        [scrollTimer invalidate];
        scrollTimer = nil;
    }
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = listingPhotosScrollView.frame.size.width;
    int page = floor((listingPhotosScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    
    // start timer
    if(scrollTimer == nil) {
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval:AUTO_SCROLL_LISTING_PIC_TIME target:self selector:@selector(scrollPages) userInfo:nil repeats:YES];
    }
}
#pragma mark -
- (void) scrollPages {
    // get the current offset ( which page is being displayed )
    CGFloat contentOffset = listingPhotosScrollView.contentOffset.x;
    // calculate next page to display
    int nextPage = (int)(contentOffset/listingPhotosScrollView.frame.size.width) + 1 ;
    // if we are not on the last page, we can show the page
    if( nextPage != pageControl.numberOfPages )  {
        [listingPhotosScrollView scrollRectToVisible:CGRectMake(nextPage*listingPhotosScrollView.frame.size.width, 0, listingPhotosScrollView.frame.size.width, listingPhotosScrollView.frame.size.height) animated:YES];
        pageControl.currentPage=nextPage;
    } else {  // else start sliding from the first page
        [listingPhotosScrollView scrollRectToVisible:CGRectMake(0, 0, listingPhotosScrollView.frame.size.width, listingPhotosScrollView.frame.size.height) animated:YES];
        pageControl.currentPage=0;
    }
}

#pragma mark UIActionSheet Section
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex < 3) {
        [self reportFlag:[actionSheet buttonTitleAtIndex:buttonIndex]];
    }
}
- (void)showActionSheet:(id)sender {
    [optionsActionSheet showInView:self.view];
}
#pragma mark -

#pragma mark Actions
/* 
 * This function will flag the listing by sending a request to the server.  The type of flag is 
 * dependent on the button that the user selects when flagging.  It will be stored in our db.
 * If the request was successful, the user will see a success view, otherwise an error alert will 
 * be sent to the user.
 */
- (void)reportFlag:(NSString*)reportType {
    @try {
        [activityIndicator showActivityIndicator:self.view];
        NSString *requestData = [@"&data[Flag][listing_id]=" stringByAppendingString:self.listing._id];
        if([reportType isEqualToString:BTN_REPORT_INAPPROPRIATE]) {
            requestData = [requestData stringByAppendingString:@"&data[Flag][inappropriate]=1"];
        } else if([reportType isEqualToString:BTN_REPORT_MISCATEGORIZED]) {
            requestData = [requestData stringByAppendingString:@"&data[Flag][miscategorized]=1"];
        } else if([reportType isEqualToString:BTN_REPORT_SPAM]) {
            requestData = [requestData stringByAppendingString:@"&data[Flag][spam]=1"];
        }
        
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
                        [successNotification setMessage:@"This listing was flagged."];
                        [successNotification showNotification:self.view];
                    } else {
                        errorAlertView.message = @"There was a problem flagging this listing.  Please try again later or contact help@theulink.com.";
                        [errorAlertView show];
                    }
                } else {
                    errorAlertView.message = @"There was a problem flagging this listing.  Please try again later or contact help@theulink.com.";
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
/**
 * This function will open up the mail client on the phone, and 
 * auto populate the email to field with the reply to data from the 
 * listing model.
 */
- (void) emailLister {
    /* create the URL */
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:?to=%@&subject=%@",
                                                [self.listing.replyTo stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                                [@"uLink Listing Inquiry" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    
    /* load the URL */
    [[UIApplication sharedApplication] openURL:url];
}
- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
    CGRect frame = listingPhotosScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [listingPhotosScrollView scrollRectToVisible:frame animated:YES];
}
#pragma mark -
@end