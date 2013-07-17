//
//  AddListingAddOnViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 7/11/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "AddListingAddOnViewController.h"
#import "AppMacros.h"
#import <QuartzCore/QuartzCore.h>
#import "DataCache.h"
#import "ColorConverterUtil.h"
#import "UlinkButton.h"
#import "ActivityIndicatorView.h"
#import "AlertView.h"
#import "AddListingSelectCategoryTableViewController.h"
@interface AddListingAddOnViewController () {
    UIScrollView *scrollView;
    UlinkButton *highlightButton;
    UlinkButton *boldButton;
    UlinkButton *regularButton;
    NSDateFormatter *dateFormatter;
    AlertView *errorAlertView;
    ActivityIndicatorView *activityIndicator;
    UIBarButtonItem *btnDone;
}
-(void) buildHighlightSection;
-(void) buildBoldSection;
-(void) highlightButtonClick;
-(void) boldButtonClick;
-(void) regularButtonClick;
@end

@implementation AddListingAddOnViewController
@synthesize submitSuccessView;
@synthesize listing;
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
    // set the nav bar title
	self.navigationItem.title = @"Add Ons";
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d"];
    // build up the scroll view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight)];
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(320, 800);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.userInteractionEnabled = YES;
    
    // build the highlight related views
    [self buildHighlightSection];
    // now build the bold related views
    [self buildBoldSection];
    
    // finally just build up the No Thanks, Just Submit a Regular listing
    CGRect frame  = CGRectMake(20, 600, 280, 50);
    regularButton = [UlinkButton buttonWithType:UIButtonTypeCustom];
    regularButton.frame = frame;
    [regularButton createDefaultButton:regularButton];
    [regularButton setTitle:@"No Thanks, Just Submit" forState:UIControlStateNormal];
    [regularButton addTarget:self action:@selector(regularButtonClick) forControlEvents:UIControlEventTouchDown];
    [scrollView addSubview:regularButton];
    
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: @""
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    
    // add the scrollview to the main view
    [self.view addSubview:scrollView];
    
    // hide the success view
    self.submitSuccessView.alpha = ALPHA_ZERO;
    
    // create the "Done" button, but we won't add it to the view until a succesfull submission
    btnDone = [[UIBarButtonItem alloc]
               initWithTitle:@"Done"
               style:UIBarButtonItemStylePlain
               target:self
               action:@selector(doneClick:)];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // reset the custom Alert view
    [errorAlertView resetAlert:@""];
}
- (void) buildHighlightSection {    
    // build up the header label
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 50)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont fontWithName:FONT_GLOBAL size:14];
    headerLabel.numberOfLines = 2;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.text = @"Highlight your listing to stand out from the rest!  This could be your listing...";
    [scrollView addSubview:headerLabel];
    
    /* create background view */
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 320, 285)];
    bgView.backgroundColor = [UIColor clearColor];
    
    /* background frame */
    UIView *bgView2 = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 265)];
    bgView2.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
    bgView2.layer.borderColor = [[UIColor colorWithRed:0.95 green:0.94 blue:0.93 alpha:1.0] CGColor];
    bgView2.layer.borderWidth = 0.5f;
    bgView2.layer.cornerRadius = 5;
    [bgView2.layer setShadowOffset:CGSizeMake(0,0)];
    [bgView2.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [bgView2.layer setShadowOpacity:0.15];
    
    /* highlight listing header */
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 304, 40)];
    header.backgroundColor = [UIColor clearColor];
    
    UILabel *created = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 285, 40)];
    created.backgroundColor = [UIColor clearColor];
    created.text = [dateFormatter stringFromDate:[NSDate date]];
    created.textColor = [UIColor blackColor];
    created.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0];
    created.textAlignment = NSTextAlignmentRight;
    
    /* add labels to header */
    [header addSubview:created];
    
    /* add image to list view background */
    UIImageView *listView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 40, 310, 200)];
    // TODO: check to see if there is an image for this listing, need to add the image data to
    // the listing model
    listView.image =  [UDataCache.images objectForKey:KEY_DEFAULT_LISTING_IMAGE];
    listView.contentMode = UIViewContentModeScaleAspectFill;
    listView.layer.cornerRadius = 0.5;
    listView.layer.masksToBounds = YES;
    listView.layer.borderWidth = 1.0f;
    listView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    /* add alpha black background to list view */
    UIView *listDetailBG = [[UIView alloc] initWithFrame:CGRectMake(0, 150, 310, 55)];
    listDetailBG.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:ALPHA_MED_HIGH];
    
    /* set title */
    UILabel *uListTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 310, 20)];
    uListTitle.backgroundColor = [UIColor clearColor];
    uListTitle.text = self.listing.title;
    uListTitle.textColor = [UIColor whiteColor];
    uListTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:15.0];
    uListTitle.numberOfLines = 1;
    uListTitle.textAlignment = NSTextAlignmentLeft;
    
    /* add short description */
    UILabel *shortDesc = [[UILabel alloc] initWithFrame:CGRectMake(5, 21, 310, 20)];
    shortDesc.backgroundColor = [UIColor clearColor];
    shortDesc.text = self.listing.shortDescription;
    shortDesc.textColor = [UIColor whiteColor];
    shortDesc.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
    shortDesc.numberOfLines = 1;
    shortDesc.textAlignment = NSTextAlignmentLeft;
    
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(0, 231, 310, 1)];
    div.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
    
    /* create view for listing actions (will include instant reply, etc.) */
    UIView *listingActions = [[UIView alloc] initWithFrame:CGRectMake(0, 230, 310, 36)];
    //listingActions.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    listingActions.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];;
    listingActions.layer.masksToBounds = YES;
    listingActions.layer.borderWidth = 0.0f;
    listingActions.layer.cornerRadius = 5;
    listingActions.layer.borderColor = [[UIColor whiteColor] CGColor];
    listingActions.layer.opacity = ALPHA_LOW;
    
    /* add reply to button */
    UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    replyBtn.layer.masksToBounds = YES;
    replyBtn.layer.borderWidth = 4.0f;
    replyBtn.layer.cornerRadius = 5;
    replyBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    replyBtn.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0f];
    replyBtn.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [replyBtn setFrame:CGRectMake(0, 0, 310, 36)];
    [replyBtn setTitle:BTN_REPLY forState:UIControlStateNormal];
    [replyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [replyBtn setImage:[UIImage imageNamed:@"options.png"] forState:UIControlStateNormal];
    
    // add insets
    CGFloat spacing = 6.0;
    CGSize imageSize = replyBtn.imageView.frame.size;
    CGSize titleSize = replyBtn.titleLabel.frame.size;
    replyBtn.titleEdgeInsets = UIEdgeInsetsMake(
                                                0.0, -(imageSize.width)/2, 0.0,  0.0);
    titleSize = replyBtn.titleLabel.frame.size;
    replyBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0, -((titleSize.width)/2 + spacing), 0.0, 0.0);
    
    /* add to subviews */
    [listingActions addSubview:replyBtn];
    
    /* add subviews */
    [listDetailBG addSubview:shortDesc];
    [listDetailBG addSubview:uListTitle];
    [listView addSubview:listDetailBG];
    [bgView2 addSubview:div];
    [bgView2 addSubview:listingActions];
    [bgView2 addSubview:header];
    [bgView addSubview:bgView2];
    [bgView addSubview:listView];
    [scrollView addSubview:bgView];
    
    // build the button for adding the highlight
    CGRect frame  = CGRectMake(20, 335, 280, 50);
    highlightButton = [UlinkButton buttonWithType:UIButtonTypeCustom];
    highlightButton.frame = frame;
    [highlightButton setTitle:@"Highlight My Listing" forState:UIControlStateNormal];
    [highlightButton createOrangeButton:highlightButton];
    [highlightButton addTarget:self action:@selector(highlightButtonClick) forControlEvents:UIControlEventTouchDown];
    [scrollView addSubview:highlightButton];
}
- (void) buildBoldSection {
    // build up the bolding header label
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 382, 300, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont fontWithName:FONT_GLOBAL size:14];
    headerLabel.numberOfLines = 2;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.text = @"or bold your listing...";
    [scrollView addSubview:headerLabel];
    
    /* bolded and regular listing */
    /* create background view */
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 400, 320, 140)];
    bgView.backgroundColor = [UIColor clearColor];
    
    /* add text view to background view */
    UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 120)];
    listView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    listView.layer.cornerRadius = 5;
    //listView.layer.masksToBounds = YES;
    listView.layer.borderColor = [[UIColor colorWithRed:0.95 green:0.94 blue:0.93 alpha:1.0] CGColor];
    listView.layer.borderWidth = 0.5f;
    [listView.layer setShadowOffset:CGSizeMake(0,0)];
    [listView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [listView.layer setShadowOpacity:0.15];
    
    /* highlight listing header */
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
    header.backgroundColor = [UIColor clearColor];
    
    UILabel *created = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 285, 40)];
    created.backgroundColor = [UIColor clearColor];
    created.textColor = [UIColor blackColor];
    created.text = [dateFormatter stringFromDate:[NSDate date]];
    created.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0];
    created.textAlignment = NSTextAlignmentRight;
    
    /* add labels to header */
    [header addSubview:created];
    
    /* set title */
    UILabel *uListTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 310, 20)];
    uListTitle.backgroundColor = [UIColor clearColor];
    uListTitle.text = self.listing.title;
    uListTitle.textColor = [UIColor blackColor];
    uListTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:15.0];
    uListTitle.numberOfLines = 1;
    uListTitle.textAlignment = NSTextAlignmentLeft;
    
    /* add short description */
    UILabel *shortDesc = [[UILabel alloc] initWithFrame:CGRectMake(5, 45, 310, 30)];
    shortDesc.backgroundColor = [UIColor clearColor];
    shortDesc.text = self.listing.listDescription;
    shortDesc.textColor = [UIColor darkGrayColor];
    shortDesc.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
    shortDesc.numberOfLines = 1;
    shortDesc.textAlignment = NSTextAlignmentLeft;
    
    /* create view for listing actions (will include instant reply, etc.) */
    UIView *listingActions = [[UIView alloc] initWithFrame:CGRectMake(0, 85, 310, 36)];
    //listingActions.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    listingActions.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
    listingActions.layer.masksToBounds = YES;
    listingActions.layer.borderWidth = 2.0f;
    listingActions.layer.cornerRadius = 5;
    listingActions.layer.borderColor = [[UIColor whiteColor] CGColor];
    listingActions.layer.opacity = ALPHA_LOW;
    
    /* add reply to button */
    UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    replyBtn.layer.masksToBounds = YES;
    replyBtn.layer.borderWidth = 4.0f;
    replyBtn.layer.cornerRadius = 5;
    replyBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    replyBtn.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0f];
    replyBtn.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [replyBtn setFrame:CGRectMake(0, 0, 310, 36)];
    [replyBtn setTitle:BTN_REPLY forState:UIControlStateNormal];
    [replyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [replyBtn setImage:[UIImage imageNamed:@"options.png"] forState:UIControlStateNormal];
    
    // add insets
    CGFloat spacing = 6.0;
    CGSize imageSize = replyBtn.imageView.frame.size;
    CGSize titleSize = replyBtn.titleLabel.frame.size;
    replyBtn.titleEdgeInsets = UIEdgeInsetsMake(
                                                0.0, -(imageSize.width)/2, 0.0,  0.0);
    titleSize = replyBtn.titleLabel.frame.size;
    replyBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0, -((titleSize.width)/2 + spacing), 0.0, 0.0);
    
    /* add to subviews */
    [listingActions addSubview:replyBtn];
    [listView addSubview:listingActions];
    [listView addSubview:header];
    [listView addSubview:uListTitle];
    [listView addSubview:shortDesc];
    [bgView addSubview:listView];
    [scrollView addSubview:bgView];
    
    // build the button for adding the bold add on
    CGRect frame  = CGRectMake(20, 538, 280, 50);
    boldButton = [UlinkButton buttonWithType:UIButtonTypeCustom];
    boldButton.frame = frame;
    [boldButton setTitle:@"Bold My Listing" forState:UIControlStateNormal];
    [boldButton createOrangeButton:boldButton];
    [boldButton addTarget:self action:@selector(boldButtonClick) forControlEvents:UIControlEventTouchDown];
    [scrollView addSubview:boldButton];
}

#pragma mark Actions
-(void) highlightButtonClick {
    self.listing.type = @"highlight";
}
-(void) boldButtonClick {
    self.listing.type = @"bold";
}
-(void) regularButtonClick {
    @try {
        self.view.userInteractionEnabled = NO;
        [activityIndicator showActivityIndicator:self.view];
        self.listing.type = @"regular";
        
        NSString *listingJSON = [self.listing getJSON];
        regularButton.enabled = FALSE;
        highlightButton.enabled = FALSE;
        boldButton.enabled = FALSE;

        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER_3737 stringByAppendingString:API_ULIST_LISTINGS]]];
        NSData *requestData = [NSData dataWithBytes:[listingJSON UTF8String] length:[listingJSON length]];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
        [req setHTTPBody: requestData];
        [req setHTTPMethod:HTTP_POST];
       // [req setHTTPBody:[req dataUsingEncoding:NSUTF8StringEncoding]];
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t updateSocialQueue = dispatch_queue_create(DISPATCH_UPDATE_SOCIAL, NULL);
        dispatch_async(updateSocialQueue, ^{
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
                        if(((NSHTTPURLResponse*)response).statusCode == 200) {
                            // TODO: update the user's session listings
                            // move the success view to the front and show it
                            [self.view bringSubviewToFront:self.submitSuccessView];
                            self.submitSuccessView.alpha = ALPHA_HIGH;
                            // show the done button
                            self.navigationItem.rightBarButtonItem = btnDone;
                            // hide the back button
                            self.navigationItem.hidesBackButton = TRUE;
                            // clear the titles
                            self.navigationItem.title = EMPTY_STRING;
                        } else {
                            self.view.userInteractionEnabled = YES;
                            regularButton.enabled = TRUE;
                            highlightButton.enabled = TRUE;
                            boldButton.enabled = TRUE;
                            NSString* errorText = (NSString*)[json objectForKey:@"error"];
                            if (errorText != nil && ![errorText isEqualToString:@""] ) {
                                errorAlertView.message = errorText;
                            } else {
                                errorAlertView.message = @"There was a problem submitting your listing.  Please try again later or contact help@theulink.com.";
                            }
                            [errorAlertView show];
                        }
                    } else {
                        regularButton.enabled = TRUE;
                        highlightButton.enabled = TRUE;
                        boldButton.enabled = TRUE;
                        errorAlertView.message = @"There was a problem submitting your listing.  Please try again later or contact help@theulink.com.";
                        // show alert to user
                        [errorAlertView show];
                    }
                });
            }];
        });
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        // show alert to user
        [errorAlertView show];
    }
}
- (void) doneClick:(id)sender {
    NSArray *viewControllers = self.navigationController.viewControllers;
    AddListingSelectCategoryTableViewController *rootViewController = (AddListingSelectCategoryTableViewController*)[viewControllers objectAtIndex:0];
    rootViewController.dismissImmediately = TRUE;
    [self.navigationController popToRootViewControllerAnimated:NO];
}
#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
