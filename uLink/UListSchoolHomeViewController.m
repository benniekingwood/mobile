//
//  UListSchoolHomeViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 4/17/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListSchoolHomeViewController.h"
#import "UListHomeViewController.h"
#import "UListSchoolCategoryViewController.h"
#import "ListingDetailViewController.h"
#import "AppDelegate.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "UListMenuCell.h"
#import "Listing.h"
#import "ListingSearchViewController.h"
#import "ImageActivityIndicatorView.h"
#import "ColorConverterUtil.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/SDWebImageDownloader.h>

@interface UListSchoolHomeViewController () {
    UIBarButtonItem *searchButton;
    UIButton *categoryViewButton;
    UIButton *listingViewButton;
    UIView *trendingBg;
    UILabel *categoryHeader;
    UILabel *listingName;
    UILabel *listingDescription;
    UILabel *listingDate;
    CGFloat screenWidth;
    CGFloat screenHeight;
    BOOL isIPhone4;
    UIButton *tags1Button;
    UIButton *tags2Button;
    UIButton *tags3Button;
    UIView *scrollingTagsView;
    Listing *current;
    UILabel *hotCategoryName;
    NSString *mainHotCategoryName;
    NSString *searchTxt;
    BOOL hotCategoryClick;
    BOOL trendingTagClick;
    UIImageView *schoolImageView;
    BOOL activeTagButtons;
    UILabel *listingHeader;
}
- (void) buildCategorySection;
- (void) retreiveTopCategories;
- (void) retreiveRecentListings;
- (void) retreiveTrendingTags;
- (void) buildRecentListingSection;
- (void) buildTrendingTagsSection;
- (void) buildUListHomeButton;
- (void) categoryClick;
- (void) swipeHandler:(UISwipeGestureRecognizer *)swipe;
- (void) back;
@end

@implementation UListSchoolHomeViewController
@synthesize school;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    self.view.backgroundColor = [UIColor blackColor];
    hotCategoryClick = FALSE;
    trendingTagClick = FALSE;
    searchTxt = nil;
    //  use school short_name here
    self.navigationItem.title = self.school.shortName;
    self.navigationItem.hidesBackButton = YES;
    
    // add swipe gesture to go back to main home view
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [swipeLeft setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:swipeLeft];

    // add the "Search" button
    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchViewController)];
    self.navigationItem.rightBarButtonItem = btnSearch;
    
    // Activate side menu with uList 
    [UAppDelegate activateSideMenu:@"uList"];
    
    // grab the dimensions of the screen
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    isIPhone4 = screenHeight < 568;
    
    
    // build the school image background
    [self buildSchoolImageView];
    
    // build the "hot" or "featured" category section
    [self buildCategorySection];
    // build the recent listing section
    [self buildRecentListingSection];
    // build the trending tags section
    [self buildTrendingTagsSection];
    // build button to navigate back to uList home
    [self buildUListHomeButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateView];
}

- (void)swipeHandler:(UISwipeGestureRecognizer *)swipe {
    NSLog(@"Swipe received.");
    [self back];
}

- (void) back {
    // navigate back to ulist home view
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) buildCategorySection {
    // build main container button view
    categoryViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [categoryViewButton addTarget:self action:@selector(categoryClick) forControlEvents:UIControlEventTouchUpInside];
    categoryViewButton.backgroundColor = [UIColor blackColor];
    if(isIPhone4) {
        categoryViewButton.frame = CGRectMake(15, 20, 290, 50);
    } else {
        categoryViewButton.frame = CGRectMake(15, 20, 290, 100);
    }
    // build header view
    categoryHeader = [[UILabel alloc] initWithFrame:CGRectMake(10,0,320,30)];
    categoryHeader.font = [UIFont fontWithName:FONT_GLOBAL size:17];
    categoryHeader.backgroundColor = [UIColor clearColor];
    categoryHeader.textColor = [UIColor whiteColor];
    categoryHeader.textAlignment = NSTextAlignmentLeft;
    [categoryViewButton addSubview:categoryHeader];
    
    // build category name view label
    hotCategoryName = [[UILabel alloc] init];
    if(isIPhone4) {
        hotCategoryName.frame = CGRectMake(0,20,280,50);
    } else {
        hotCategoryName.frame = CGRectMake(0,20,280,100);
    }
    hotCategoryName.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:36];
    hotCategoryName.backgroundColor = [UIColor clearColor];
    hotCategoryName.textColor = [UIColor whiteColor];
    hotCategoryName.textAlignment = NSTextAlignmentRight;
    hotCategoryName.numberOfLines = 1;
    
    [categoryViewButton addSubview:hotCategoryName];
    [self.view addSubview:categoryViewButton];
    // send request for categories
    [self performSelectorInBackground:@selector(retreiveTopCategories) withObject:self];
}
- (void) buildRecentListingSection {
    // build main container button view
    listingViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [listingViewButton addTarget:self action:@selector(recentListingClick) forControlEvents:UIControlEventTouchUpInside];
    listingViewButton.backgroundColor = [UIColor blackColor];
    if(isIPhone4) {
        listingViewButton.frame = CGRectMake(15, 175, 290, 100);
    } else {
        listingViewButton.frame = CGRectMake(15, 225, 290, 150);
    }
    listingHeader = [[UILabel alloc] initWithFrame:CGRectMake(15,195,290,30)];
    listingHeader.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:17];
    listingHeader.backgroundColor = [UIColor clearColor];
    listingHeader.textColor = [UIColor whiteColor];
    listingHeader.textAlignment = NSTextAlignmentRight;
    listingHeader.text = @"Recent";
    [self.view addSubview:listingHeader];
    
    // build category name view label
    listingName = [[UILabel alloc] init];
    if(isIPhone4) {
        listingName.frame = CGRectMake(0,0,290,25);
    } else {
        listingName.frame = CGRectMake(0,0,290,50);
    }
    listingName.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:38];
    listingName.backgroundColor = [UIColor clearColor];
    listingName.textColor = [UIColor whiteColor];
    listingName.textAlignment = NSTextAlignmentLeft;
    listingName.numberOfLines = 2;
    
    // build listing description
    listingDescription = [[UILabel alloc] init];
    if (isIPhone4)
        listingDescription.frame = CGRectMake(0, 50, 290, 30);
    else
        listingDescription.frame = CGRectMake(0, 100, 290, 30);
    listingDescription.font = [UIFont fontWithName:FONT_GLOBAL size:22];
    listingDescription.backgroundColor = [UIColor clearColor];
    listingDescription.textColor = [UIColor whiteColor];
    listingDescription.textAlignment = NSTextAlignmentLeft;
    listingDescription.numberOfLines = 1;
    
    // build listing date
    listingDate = [[UILabel alloc] init];
    if (isIPhone4)
        listingDate.frame = CGRectMake(0, 100, 290, 20);
    else
        listingDate.frame = CGRectMake(0, 125, 290, 20);
    listingDate.font = [UIFont fontWithName:FONT_GLOBAL size:12];
    listingDate.backgroundColor = [UIColor clearColor];
    listingDate.textColor = [UIColor whiteColor];
    listingDate.textAlignment = NSTextAlignmentLeft;
    listingDate.numberOfLines = 1;
    
    [listingViewButton addSubview:listingName];
    [listingViewButton addSubview:listingDescription];
    [listingViewButton addSubview:listingDate];
    [self.view addSubview:listingViewButton];
    
    // send request for recent listings
    [self performSelectorInBackground:@selector(retreiveRecentListings) withObject:self];
}
- (void) buildTrendingTagsSection {
    trendingBg = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-172, 320, 60)];
    trendingBg.backgroundColor = [UIColor clearColor];
    
    // build the trending label bg view
    UIView *trendingLabelBg = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 100, 30)];
    trendingLabelBg.backgroundColor = [UIColor blackColor];
    // build the trending label hr view
    UIView *trendingLabelHr = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 1.5)];
    trendingLabelHr.backgroundColor = [UIColor blackColor];
    [trendingLabelBg addSubview:trendingLabelHr];
    
    // Build the trending label
    UILabel *trendingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,70,30)];
    trendingLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:15];
    trendingLabel.backgroundColor = [UIColor clearColor];
    trendingLabel.textColor = [UIColor whiteColor];
    trendingLabel.textAlignment = NSTextAlignmentLeft;
    trendingLabel.text = @"#trending";
    [trendingLabelBg addSubview:trendingLabel];
    
    // build the tags label
    UILabel *tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(60,0,50,40)];
    tagsLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:13];
    tagsLabel.backgroundColor = [UIColor clearColor];
    tagsLabel.textColor = [UIColor redColor];
    tagsLabel.textAlignment = NSTextAlignmentLeft;
    tagsLabel.text = @"Tags";
  
    
    [trendingBg addSubview:trendingLabelBg];
    [self.view addSubview:trendingBg];

    
    // scrolling tags view
    scrollingTagsView = [[UIView alloc] initWithFrame:CGRectMake(100, screenHeight-175, 220, 60)];
    //scrollingTagsView.backgroundColor = [UIColor blueColor];
    scrollingTagsView.clipsToBounds = YES;

    // tag1
    tags1Button = [UIButton buttonWithType:UIButtonTypeCustom];
    tags1Button.frame = CGRectMake(320,0,210,60);
    tags1Button.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:13];
    tags1Button.backgroundColor = [UIColor clearColor];
    tags1Button.titleLabel.textColor = [UIColor whiteColor];
    tags1Button.titleLabel.textAlignment = NSTextAlignmentLeft;
    tags1Button.titleLabel.numberOfLines = 0;
    tags1Button.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [scrollingTagsView addSubview:tags1Button];
    // tag2
    tags2Button = [UIButton buttonWithType:UIButtonTypeCustom];
    tags2Button.frame = CGRectMake(320,0,210,60);
    tags2Button.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:13];
    tags2Button.backgroundColor = [UIColor clearColor];
    tags2Button.titleLabel.textColor = [UIColor whiteColor];
    tags2Button.titleLabel.textAlignment = NSTextAlignmentLeft;
    [scrollingTagsView addSubview:tags2Button];
    // tag3
    tags3Button = [UIButton buttonWithType:UIButtonTypeCustom];
    tags3Button.frame = CGRectMake(320,0,210,60);
    tags3Button.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:13];
    tags3Button.backgroundColor = [UIColor clearColor];
    tags3Button.titleLabel.textColor = [UIColor whiteColor];
    tags3Button.titleLabel.textAlignment = NSTextAlignmentLeft;
    [scrollingTagsView addSubview:tags3Button];
    // finally add the scroll view to the main view
    [self.view addSubview:scrollingTagsView];
    
    // send the request off to the server
    [self performSelectorInBackground:@selector(retreiveTrendingTags) withObject:self];
}
- (void) buildUListHomeButton {
    // build main container button view
    UIButton *uListHomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [uListHomeButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    uListHomeButton.backgroundColor = [UIColor colorWithRed:55.0f / 255.0f green:129.0f / 255.0f blue:148.0f / 255.0f alpha:1.0f];
    uListHomeButton.frame = CGRectMake(10, trendingBg.frame.origin.y+trendingBg.frame.size.height, 300, 40);
    
    UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,310,uListHomeButton.frame.size.height)];
    backLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:14];
    backLabel.backgroundColor = [UIColor clearColor];
    backLabel.textColor = [UIColor whiteColor];
    backLabel.textAlignment = NSTextAlignmentCenter;
    backLabel.text = @"Browse Another University";
    [uListHomeButton addSubview:backLabel];
    
    [self.view addSubview:uListHomeButton];
}
- (void) animateTag1:(BOOL)isDefaultTag {
    // if there are no tags (meaning isDefaultTag is true), then just animate the first tag only
    if(isDefaultTag && !activeTagButtons) {
        [UIView animateWithDuration:18.0f
                              delay:0.0f
                            options: (UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveLinear)
                         animations:^{
                             /*CGRect r = [tags1Button frame];
                              r.origin.x -= 150;
                              [tags1Button setFrame: r];*/
                             tags1Button.frame = CGRectMake(-210,0,210,60);
                         }
                         completion:^(BOOL completed) {
                             /*CGRect r = [tags1Button frame];
                              r.origin.x += 320;
                              [tags1Button setFrame: r];*/
                             tags1Button.frame = CGRectMake(320,0,210,60);
                             [self animateTag1:TRUE];
                         }];
    } else {
        [UIView animateWithDuration:18.0f
                              delay:0.0f
                            options: (UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveLinear)
                         animations:^{
                             /*CGRect r = [tags1Button frame];
                             r.origin.x -= 150;
                             [tags1Button setFrame: r];*/
                             tags1Button.frame = CGRectMake(-210,0,210,60);
                         }
                         completion:^(BOOL completed) {
                             /*CGRect r = [tags1Button frame];
                             r.origin.x += 320;
                             [tags1Button setFrame: r];*/
                             tags1Button.frame = CGRectMake(320,0,210,60);

                         }];
        [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(animateTag2) userInfo:FALSE repeats:NO];
    }
}
- (void) animateTag2{
        [UIView animateWithDuration:18.0f
                         delay:0.0f
                         options: (UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveLinear)
                         animations:^{
                             tags2Button.frame = CGRectMake(-210,0,210,60);
                         }
                         completion:^(BOOL completed) {
                             tags2Button.frame = CGRectMake(320,0,210,60);
                         }];
        [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(animateTag3) userInfo:FALSE repeats:NO];
}
- (void) animateTag3 {
        [UIView animateWithDuration:15.0f
                        delay:0.0f
                        options: (UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveLinear)
                         animations:^{
                             tags3Button.frame = CGRectMake(-150,0,210,60);
                         }
                         completion:^(BOOL completed) {
                             tags3Button.frame = CGRectMake(320,0,210,60);
                         }];
    [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(animateTag1:) userInfo:FALSE repeats:NO];

}
- (void)updateView {
    self.navigationItem.title = [self.school.shortName stringByAppendingString:@" uList"];
    
    // Cerwinski - 20130806 - have to explicitly set
    //  user interaction; at some point between entering
    //  the listing results view page, and popping that view (back click)
    //  controller, the school home view controller interaction looks
    //  to be disabled
    [self.view setUserInteractionEnabled:YES];
}

-(void) showSearchViewController {
    [self performSegueWithIdentifier:SEGUE_SHOW_LISTING_SEARCH_VIEW_CONTROLLER sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableCharacterSet *trimSet = [[NSCharacterSet characterSetWithCharactersInString:@"#"] mutableCopy];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:scrollingTagsView.viewForBaselineLayout];
    /* 
     * If the tag buttons are active then we can perform a search.  The only time
     * the buttons would not be active is if there are not tags in the listings for
     * the current school
     */
    if(activeTagButtons) {
        NSLog(@"touch point %f,%f", touchLocation.x, touchLocation.y);
        NSLog(@"Tag1 point: %f, %f:", tags1Button.layer.position.x, tags1Button.layer.position.y);

        if ([tags1Button.layer.presentationLayer hitTest:touchLocation]) {
            //NSLog(@"tag click %@", tags1Button.titleLabel.text);
            searchTxt = [[NSString alloc] initWithString:[tags1Button.titleLabel.text stringByTrimmingCharactersInSet:trimSet]];
        } else if ([tags2Button.layer.presentationLayer hitTest:touchLocation]) {
            //NSLog(@"tag click %@", tags2Button.titleLabel.text);
            searchTxt = [[NSString alloc] initWithString:[tags2Button.titleLabel.text stringByTrimmingCharactersInSet:trimSet]];
        } else if ([tags3Button.layer.presentationLayer hitTest:touchLocation]) {
            //NSLog(@"tag click %@", tags3Button.titleLabel.text);
            searchTxt = [[NSString alloc] initWithString:[tags3Button.titleLabel.text stringByTrimmingCharactersInSet:trimSet]];
        }
        
        // if we have search text, then perform search action on trending tag
        if (searchTxt) {
            NSLog(@"search text: %@", searchTxt);
            trendingTagClick = TRUE;
            [self performSegueWithIdentifier:SEGUE_SHOW_LISTING_SEARCH_VIEW_CONTROLLER sender:self];
        }
    }
}

/*
 * Prepare for seque from Side Menu Bar Table View
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_ULIST_SCHOOL_LISTINGS_VIEW_CONTROLLER])
    {
        UListMenuCell *menuCell = (UListMenuCell*)sender;
        UListSchoolCategoryViewController *categoryViewController = [segue destinationViewController];
        categoryViewController.school = school;
        if(hotCategoryClick) {
            categoryViewController.mainCat = mainHotCategoryName;
            categoryViewController.subCat = hotCategoryName.text;
        } else {
            categoryViewController.mainCat = menuCell.mainCat;
            categoryViewController.subCat = menuCell.subCat;
        }        
    } else if ([[segue identifier] isEqualToString:SEGUE_SHOW_LISTING_SEARCH_VIEW_CONTROLLER]) {
        ListingSearchViewController *searchViewController = [segue destinationViewController];
        searchViewController.school = self.school;
        
        // if user clicks on trending tag, then execute search
        if (trendingTagClick) {
            searchViewController.searchTxt = searchTxt;
            searchViewController.executeSearchOnLoad = TRUE;
        }
    } else if ([[segue identifier] isEqualToString:SEGUE_SHOW_LISTING_DETAIL_VIEW_CONTROLLER]) {
        ListingDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.listing = current;
    }
}

// NOTE: create category view
- (void)performSegue:(NSInteger)item {
    switch (item) {
        case 0:
            [self performSegueWithIdentifier:SEGUE_SHOW_ULIST_SCHOOL_LISTINGS_VIEW_CONTROLLER sender:self];
            break;
        default:
            [self performSegueWithIdentifier:SEGUE_SHOW_ULIST_SCHOOL_LISTINGS_VIEW_CONTROLLER sender:self];
            break;
    }
}
-(void) buildSchoolImageView {
    // add the campus image
    if(isIPhone4) {
        schoolImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 150)];
    } else {
        schoolImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 70, 320, 200)];
    }
    schoolImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:schoolImageView];
    [self loadSchoolImage];
}
-(void) loadSchoolImage {
    NSString *cacheKey = [KEY_SCHOOL_ID_PREPEND stringByAppendingString:self.school.schoolId];
    // grab the school image from the images cache
    UIImage *schoolImage = [UDataCache imageExists:cacheKey cacheModel:IMAGE_CACHE];
    if (schoolImage == nil || [schoolImage isKindOfClass:[NSNull class]]) {
        if(![self.school.imageURL isKindOfClass:[NSNull class]] && self.school.imageURL != nil && ![self.school.imageURL isEqualToString:@""]) {
            // set the key in the cache to let other processes know that this key is in work
            [UDataCache.images setValue:[NSNull null] forKey:cacheKey];
            // lazy load the image from the web
            NSURL *url = [NSURL URLWithString:[URL_SCHOOL_IMAGE stringByAppendingString:self.school.imageURL]];
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
                                                [UDataCache.images setValue:image forKey:cacheKey];
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

/*
 * Retreive the top categories 
 * for this school
 */
- (void) retreiveTopCategories {
    @try {
         __block ImageActivityIndicatorView *iActivityIndicator;
        if (!iActivityIndicator)
        {
            iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
            [iActivityIndicator largeModeOn];
            [iActivityIndicator showActivityIndicator:categoryViewButton];
            categoryViewButton.userInteractionEnabled = NO;
        }
        dispatch_queue_t categoryQueue = dispatch_queue_create(DISPATCH_ULIST_CATEGORY, NULL);
        dispatch_async(categoryQueue, ^{
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER_3737 stringByAppendingString:API_ULIST_CATEGORIES_TOP]]];
            NSString *json = @"{ \"limit\": 1,\"sid\":";
            json = [json stringByAppendingString:self.school.schoolId];
            json = [json stringByAppendingString:@"}"];
            NSData *requestData = [NSData dataWithBytes:[json UTF8String] length:[json length]];
            [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [req setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
            [req setHTTPBody: requestData];
            [req setHTTPMethod:HTTP_POST];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                [iActivityIndicator hideActivityIndicator:categoryViewButton];
                iActivityIndicator = nil;
                categoryViewButton.userInteractionEnabled = YES;
                // if there is valid data
                if (data)
                {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                    if (httpResponse.statusCode==200)
                    {
                        NSError* err;
                        NSArray* json = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:kNilOptions
                                         error:&err];
                        if (json != nil && [json count] > 0) {
                            NSDictionary *category = json[0];
                            NSDictionary *name = [category objectForKey:@"_id"];
                            hotCategoryName.text = (NSString*)[name objectForKey:@"category"];
                            mainHotCategoryName = (NSString*)[name objectForKey:@"main_category"];
                            /* Determine if there are listings, if so we will say "Hot" if not "Featured' for the category header label title
                             */
                            int count = [((NSString*)[category objectForKey:@"count"]) intValue];
                            categoryHeader.text = (count > 0) ? @"Hot Category" : @"Featured Category";
                        }
                        else {
                            // since there are no listings yet..let's default it to For Sale -> Books
                            hotCategoryName.text = @"Books";
                            mainHotCategoryName = @"For Sale";
                            categoryHeader.text = @"Featured Category";
                        }
                    } else {
                        // TODO[future]: if it reaches here, it means we have a server error and we should log
                        hotCategoryName.text = @"Oh no, where's your category?!";
                        [categoryViewButton setUserInteractionEnabled:YES];
                        [categoryViewButton setEnabled:NO];
                    }
                }
            });
            }]; // end sendAsynchronousRequest
        }); // end dispatch_async
    }
    @catch (NSException *exception) {} 
}

/*
 * Retreive the recent listings
 * for this school
 */
- (void) retreiveRecentListings {
    @try {
        
        __block ImageActivityIndicatorView *iActivityIndicator;
        if (!iActivityIndicator)
        {
            iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
            [iActivityIndicator largeModeOn];
            [iActivityIndicator showActivityIndicator:listingViewButton];
            listingViewButton.userInteractionEnabled = NO;
        }
        dispatch_queue_t recentListingQueue = dispatch_queue_create(DISPATCH_ULIST_LISTING, NULL);
        dispatch_async(recentListingQueue, ^{
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER_3737 stringByAppendingString:API_ULIST_LISTINGS_RECENT]]];
            NSString *json = [NSString stringWithFormat:@"{ \"limit\": %i, \"sid\":%@ }", 1, school.schoolId];
            NSData *requestData = [NSData dataWithBytes:[json UTF8String] length:[json length]];
            [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [req setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
            [req setHTTPBody: requestData];
            [req setHTTPMethod:HTTP_POST];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                [iActivityIndicator hideActivityIndicator:listingViewButton];
                iActivityIndicator = nil;
                listingViewButton.userInteractionEnabled = YES;
                // if there is valid data
                if (data)
                {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                    
                    if (httpResponse.statusCode==200)
                    {
                        NSError* err;
                        NSArray* json = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:kNilOptions
                                         error:&err];
                                                
                        if (json != nil && [json count] > 0) {
                            NSDictionary *listing = json[0];
                            current = [[Listing alloc] initWithDictionary:listing];
                            listingName.text = (NSString*)[listing objectForKey:@"title"];
                            listingDescription.text = (NSString*)[listing objectForKey:@"short_description"];
                            
                            NSDateFormatter *df = [[NSDateFormatter alloc] init];
                            [df setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
                            
                            NSDate *created = [NSDate date];
                            created = [df dateFromString:(NSString*)[listing objectForKey:@"created"]];
                            
                            [df setDateFormat:@"yyyy MMM dd"];
                            listingDate.text = [df stringFromDate:created];
                        }
                        else {
                            // show the school image instead
                            [listingViewButton removeFromSuperview];
                            [listingHeader removeFromSuperview];
                            if(isIPhone4) {
                                schoolImageView.frame = CGRectMake(0, 70, 320, 150);
                            } else {
                                schoolImageView.frame = CGRectMake(0, 120, 320, 200);
                            }
                        }
                    } else {
                        // show the school image instead
                        [listingViewButton removeFromSuperview];
                        [listingHeader removeFromSuperview];
                        if(isIPhone4) {
                            schoolImageView.frame = CGRectMake(0, 70, 320, 150);
                        } else {
                            schoolImageView.frame = CGRectMake(0, 120, 320, 200);
                        }
                    }
                }
            });
            }]; // end sendAsynchronousRequest
        }); // end dispatch_async
    }
    @catch (NSException *exception) {}
}

- (void) retreiveTrendingTags {
    @try {
        __block ImageActivityIndicatorView *iActivityIndicator;
        if (!iActivityIndicator)
        {
            iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
            [iActivityIndicator showActivityIndicator:scrollingTagsView];
            scrollingTagsView.userInteractionEnabled = NO;
        }
        dispatch_queue_t trendingTagsQueue = dispatch_queue_create(DISPATCH_ULIST_TOPTAGS, NULL);
        dispatch_async(trendingTagsQueue, ^{
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER_3737 stringByAppendingString:API_ULIST_LISTINGS_TOPTAGS]]];
            NSString *json = @"{ \"limit\": 3,\"sid\":";
            json = [json stringByAppendingString:self.school.schoolId];
            json = [json stringByAppendingString:@"}"];
            NSData *requestData = [NSData dataWithBytes:[json UTF8String] length:[json length]];
            [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [req setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
            [req setHTTPBody: requestData];
            [req setHTTPMethod:HTTP_POST];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                [iActivityIndicator hideActivityIndicator:scrollingTagsView];
                iActivityIndicator = nil;
                scrollingTagsView.userInteractionEnabled = YES;
                // if there is valid data
                if (data)
                {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                    
                    if (httpResponse.statusCode==200)
                    {
                        NSError* err;
                        NSArray* json = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:kNilOptions
                                         error:&err];
                        if (json != nil && [json count] > 0) {
                            // activate the tag buttons since there is data
                            activeTagButtons = YES;
                            for (int idx=0; idx<[json count]; idx++) {
                                NSDictionary *category = json[idx];
                                NSDictionary *tag = [category objectForKey:@"_id"];
                                NSString *tagName = @"#";
                                tagName = [tagName stringByAppendingString:(NSString*)[tag objectForKey:@"tags"]];
                                switch (idx) {
                                    case 0:
                                        [tags1Button setTitle:tagName forState:UIControlStateNormal];
                                        [self animateTag1:FALSE];
                                        break;
                                    case 1:
                                        [tags2Button setTitle:tagName forState:UIControlStateNormal];
                                        break;
                                    case 2:
                                        [tags3Button setTitle:tagName forState:UIControlStateNormal];
                                        break;
                                } // end switch
                            } // end for
                        } else {
                            // set the default tag, and make sure the buttons are not active
                            [tags1Button setTitle:@"#tolistornottolist" forState:UIControlStateNormal];
                            activeTagButtons = NO;
                            [self animateTag1:TRUE];
                        }
                    } else {
                         // set the default tag, and make sure the buttons are not active
                        [tags1Button setTitle:@"#tolistornottolist" forState:UIControlStateNormal];
                        activeTagButtons = NO;
                        [self animateTag1:TRUE];
                    }
                }
            });
            }]; // end sendAsynchronousRequest
        }); // end dispatch_async
    }
    @catch (NSException *exception) {}
}

#pragma mark Actions
-(void) categoryClick {
    hotCategoryClick = TRUE;
    [self performSegueWithIdentifier:SEGUE_SHOW_ULIST_SCHOOL_LISTINGS_VIEW_CONTROLLER sender:self];
}
-(void) recentListingClick {
    //NSLog(@"recent listing click: segueing to detail view controller");
    [self performSegueWithIdentifier:SEGUE_SHOW_LISTING_DETAIL_VIEW_CONTROLLER sender:current];
}
-(void) tagClick:(id)sender {
    NSLog(@"tag click %@", ((UIButton*)sender).titleLabel.text);
}
#pragma mark -
@end
