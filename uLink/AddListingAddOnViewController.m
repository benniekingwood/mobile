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
#import "ULinkColorPalette.h"
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>

@interface AddListingAddOnViewController () {
    UIScrollView *scrollView;
    UlinkButton *highlightButton;
    UlinkButton *boldButton;
    UlinkButton *regularButton;
    NSDateFormatter *dateFormatter;
    AlertView *errorAlertView;
    ActivityIndicatorView *activityIndicator;
    UIBarButtonItem *btnDone;
    NSDictionary *paymentConfirmation;
    UIImageView *listView;
    BOOL successfulPayment;
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
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    // set the successfulPayment property to TRUE
    successfulPayment = TRUE;
    // set the nav bar title
	self.navigationItem.title = @"Add Ons";
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d"];
    // make sure the date is not dull
    self.listing.created = (self.listing.created == nil) ? [NSDate date] : self.listing.created;
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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // "pre" connect to the pay pay servers
    // Start out working with the test environment! When you are ready, remove this line to switch to live.
    [PayPalPaymentViewController setEnvironment:PayPalEnvironmentNoNetwork];
    [PayPalPaymentViewController prepareForPaymentUsingClientId:PAYPAL_CLIENT_ID];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // reset the custom Alert view
    [errorAlertView resetAlert:@""];
}
- (void) buildHighlightSection {    
    // build up the header label
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 50)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor blackColor];
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
    
    /* highlight listing header */
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
    header.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:ALPHA_MED];
    
    UILabel *created = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 285, 20)];
    created.backgroundColor = [UIColor clearColor];
    created.text = [dateFormatter stringFromDate:self.listing.created];
    created.textColor = [UIColor whiteColor];
    created.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0];
    created.textAlignment = NSTextAlignmentRight;
    
    /* add labels to header */
    [header addSubview:created];
    
    /* add image to list view background */
    listView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 310, 230)];
    if(self.listing.images != nil && [self.listing.images count] > 0) {
        listView.image = [self.listing.images objectAtIndex:0];
    } else {
        listView.image = [UDataCache.images objectForKey:KEY_DEFAULT_LISTING_IMAGE];
    }
    
    listView.contentMode = UIViewContentModeScaleAspectFill;
    listView.layer.cornerRadius = 0.0f;
    listView.layer.masksToBounds = YES;
    listView.layer.borderWidth = 0.0f;
    listView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    /* add alpha black background to list view */
    UIView *listDetailBG = [[UIView alloc] initWithFrame:CGRectMake(0, 175, 310, 55)];
    listDetailBG.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:ALPHA_MED];
    
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
    shortDesc.text = self.listing.listDescription;
    shortDesc.textColor = [UIColor whiteColor];
    shortDesc.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
    shortDesc.numberOfLines = 1;
    shortDesc.textAlignment = NSTextAlignmentLeft;
    
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(0, 231, 310, 1)];
    div.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
    
    /* create view for listing actions (will include instant reply, etc.) */
    UIView *listingActions = [[UIView alloc] initWithFrame:CGRectMake(0, 230, 310, 35)];
    listingActions.backgroundColor = [UIColor uLinkDarkGrayColor];
    listingActions.layer.masksToBounds = YES;
    listingActions.layer.borderWidth = 0.0f;
    listingActions.layer.cornerRadius = 0.0f;
    listingActions.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    /* add reply to button */
    UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    replyBtn.layer.masksToBounds = YES;
    replyBtn.layer.borderWidth = 0.0f;
    replyBtn.layer.cornerRadius = 0.0f;
    replyBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    replyBtn.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0f];
    //replyBtn.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    replyBtn.backgroundColor = [UIColor uLinkDarkGrayColor];
    [replyBtn setFrame:CGRectMake(0, 0, 310, 36)];
    [replyBtn setTitle:BTN_REPLY forState:UIControlStateNormal];
    [replyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [replyBtn setImage:[UIImage imageNamed:@"ulink-mobile-reply-icon.png"] forState:UIControlStateNormal];
    
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
    [listView addSubview:header];
    [bgView2 addSubview:div];
    [bgView2 addSubview:listingActions];
    //[bgView2 addSubview:header];
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
    headerLabel.textColor = [UIColor blackColor];
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
    UIView *rblistView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 120)];
    rblistView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    rblistView.layer.cornerRadius = 2.0f;
    //listView.layer.masksToBounds = YES;
    rblistView.layer.borderColor = [[UIColor colorWithRed:0.95 green:0.94 blue:0.93 alpha:1.0] CGColor];
    rblistView.layer.borderWidth = 0.5f;
    
    /* highlight listing header */
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
    header.backgroundColor = [UIColor clearColor];
    
    UILabel *created = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 285, 40)];
    created.backgroundColor = [UIColor clearColor];
    created.textColor = [UIColor blackColor];
    created.text = [dateFormatter stringFromDate:self.listing.created];
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
    shortDesc.textColor = [UIColor blackColor];
    shortDesc.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
    shortDesc.numberOfLines = 1;
    shortDesc.textAlignment = NSTextAlignmentLeft;
    
    /* create view for listing actions (will include instant reply, etc.) */
    UIView *listingActions = [[UIView alloc] initWithFrame:CGRectMake(0, 85, 310, 35)];
    listingActions.backgroundColor = [UIColor uLinkDarkGrayColor];
    listingActions.layer.masksToBounds = YES;
    listingActions.layer.borderWidth = 0.0f;
    listingActions.layer.cornerRadius = 0.0f;
    listingActions.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    /* add reply to button */
    UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    replyBtn.layer.masksToBounds = YES;
    replyBtn.layer.borderWidth = 0.0f;
    replyBtn.layer.cornerRadius = 0.0f;
    replyBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    replyBtn.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0f];
    //replyBtn.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    replyBtn.backgroundColor = [UIColor uLinkDarkGrayColor];
    [replyBtn setFrame:CGRectMake(0, 0, 310, 36)];
    [replyBtn setTitle:BTN_REPLY forState:UIControlStateNormal];
    [replyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [replyBtn setImage:[UIImage imageNamed:@"ulink-mobile-reply-icon.png"] forState:UIControlStateNormal];
    
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
    [rblistView addSubview:listingActions];
    [rblistView addSubview:header];
    [rblistView addSubview:uListTitle];
    [rblistView addSubview:shortDesc];
    [bgView addSubview:rblistView];
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
- (void) pay:(NSString*)price {
    // Create a PayPalPayment
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [[NSDecimalNumber alloc] initWithString:price];
    payment.currencyCode = @"USD";
    payment.shortDescription = [@"Listing Add On - " stringByAppendingString:self.listing.type];
    
    // Check whether payment is processable.
    if (!payment.processable) {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
    }
    
    // Start out working with the test environment! When you are ready, remove this line to switch to live.
    [PayPalPaymentViewController setEnvironment:PayPalEnvironmentSandbox];
    
    // Provide a payerId that uniquely identifies a user within the scope of your system,
    // such as an email address or user ID.
    NSString *aPayerId = UDataCache.sessionUser.username;
    
    // Create a PayPalPaymentViewController with the credentials and payerId, the PayPalPayment
    // from the previous step, and a PayPalPaymentDelegate to handle the results.
    PayPalPaymentViewController *paymentViewController;
    paymentViewController = [[PayPalPaymentViewController alloc] initWithClientId:PAYPAL_SANDBOX_CLIENT_ID
                                                                    receiverEmail:PAYPAL_SANDBOX_RECEIVER_EMAIL
                                                                          payerId:aPayerId
                                                                          payment:payment
                                                                         delegate:self];
    
    // Present the PayPalPaymentViewController.
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

-(void) finalizePostListingSuccess {
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

}

#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment {
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
    
    // Dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:^{
        // finalize the success view if necessary
        dispatch_async(dispatch_get_main_queue(), ^{
            if(successfulPayment) {
              [self finalizePostListingSuccess];
            }
        });
    }];
}

- (void)payPalPaymentDidCancel {
    // delete the listing
    [self.listing deleteListing:nil];
    
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:^{
        // re-enable the buttons
        dispatch_async(dispatch_get_main_queue(), ^{
            regularButton.enabled = TRUE;
            highlightButton.enabled = TRUE;
            boldButton.enabled = TRUE;
        });
      
    }];
}
- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
    NSLog(@"%@", completedPayment.confirmation);
    paymentConfirmation = completedPayment.confirmation;
    
    // TODO: Send confirmation to your server; your server should verify the proof of payment,
    // and also post the Listing if the payment was good
    // TEMP work, just verify here for now
    NSDictionary *payment = [paymentConfirmation objectForKey:@"payment"];

    NSString *currencyCode = [payment objectForKey:@"currency_code"];
    if(![currencyCode isEqualToString:@"USD"]) {
        successfulPayment = FALSE;
    }
    NSDictionary *proofOfPayment = [paymentConfirmation objectForKey:@"proof_of_payment"];
    NSDictionary *adaptive = [proofOfPayment objectForKey:@"adaptive_payment"];
    NSDictionary *rest = [proofOfPayment objectForKey:@"rest_api"];
    // if paypal payment
    if(adaptive != nil) {
        NSString *execStatus = [adaptive objectForKey:@"payment_exec_status"];
        if(![execStatus isEqualToString:@"COMPLETED"]) {
            successfulPayment = FALSE;
        }
    } else if(rest != nil) { // else if credit card paymentb 
        NSString *state = [rest objectForKey:@"state"];
        if(![state isEqualToString:@"approved"]) {
            successfulPayment = FALSE;
        }
    }
    
    // if it's not a valid payment, notify the user with error dialog, and delete listing
    if(!successfulPayment) {
        errorAlertView.message = @"There was a problem submitting the payment for your listing.  Please try again later or contact help@theulink.com.";
        [errorAlertView show];
    }
   
}
#pragma mark -

#pragma mark Actions
-(void) highlightButtonClick {
    // set the listing type to be highlighted
    self.listing.type = @"highlight";
    if(self.listing.meta == nil) {
        self.listing.meta = [[NSMutableDictionary alloc] init];
    }
    [self.listing.meta setObject:@"7" forKey:@"duration"];
    // then post the listing, and forward to the paypal controller
    [self postListing];
}
-(void) boldButtonClick {
    // set the listing type to be bold
    self.listing.type = @"bold";
    if(self.listing.meta == nil) {
        self.listing.meta = [[NSMutableDictionary alloc] init];
    }
    [self.listing.meta setObject:@"7" forKey:@"duration"];
    // then post the listing, and forward to the paypal controller
    [self postListing];
}


-(void) postListing {
    @try {
        self.view.userInteractionEnabled = NO;
        [activityIndicator showActivityIndicator:self.view];
        
        NSString *listingJSON = [self.listing getJSON];
        NSLog(@"%@", listingJSON);
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
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t postListingQueue = dispatch_queue_create(DISPATCH_ULIST_LISTING, NULL);
        dispatch_async(postListingQueue, ^{
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
                            // set the new id on the listing
                            self.listing._id = [json objectForKey:@"_id"];
                            // if this is a regular posting
                            if([self.listing.type isEqualToString:@"regular"]) {
                                [self finalizePostListingSuccess];
                            } else {
                                NSString *price;
                                // determine the price
                                if([self.listing.type isEqualToString:@"highlight"]) {
                                    price = @"1.99";
                                } else if ([self.listing.type isEqualToString:@"bold"]) {
                                    price = @"0.75";
                                }
                                [self pay:price];
                            }
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
        regularButton.enabled = TRUE;
        highlightButton.enabled = TRUE;
        boldButton.enabled = TRUE;
        // show alert to user
        [errorAlertView show];
    }
}

-(void) regularButtonClick {
    self.listing.type = @"regular";
    if(self.listing.meta == nil) {
        self.listing.meta = [[NSMutableDictionary alloc] init];
    }
    [self.listing.meta setObject:@"7" forKey:@"duration"];
    [self postListing];
}
- (void) doneClick:(id)sender {
    [UDataCache rehydrateSessionUserListings:NO notification:NOTIFICATION_LISTINGS_ADD_ON_DONE];
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
