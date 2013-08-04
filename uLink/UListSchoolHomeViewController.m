//
//  UListSchoolHomeViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 4/17/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListSchoolHomeViewController.h"
#import "UListSchoolCategoryViewController.h"
#import "AppDelegate.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "UListMenuCell.h"
#import "ListingSearchViewController.h"
#import "ImageActivityIndicatorView.h"
#import "ColorConverterUtil.h"

@interface UListSchoolHomeViewController () {
    UIBarButtonItem *searchButton;
    UIButton *categoryViewButton;
    UILabel *categoryHeader;
    CGFloat screenWidth;
    CGFloat screenHeight;
    BOOL isIPhone4;
    UIButton *tags1Button;
    UIButton *tags2Button;
    UIButton *tags3Button;
}
- (void) buildCategorySection;
- (void) retreiveTopCategories:(UILabel*)categoryName;
- (void) buildRecentListingSection;
- (void) buildTrendingTagsSection;
- (void) categoryClick;
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
    
    self.view.backgroundColor = [UIColor blackColor];
    //  use school short_name here
    self.navigationItem.title = self.school.shortName;
    self.navigationItem.hidesBackButton = YES;

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
    
    // build the "hot" or "featured" category section
    [self buildCategorySection];
    // build the recent listing section
    [self buildRecentListingSection];
    // build the trending tags section
    [self buildTrendingTagsSection];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateView];
}

- (void) buildCategorySection {
    // build main container button view
    categoryViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [categoryViewButton addTarget:self action:@selector(categoryClick) forControlEvents:UIControlEventTouchUpInside];
    categoryViewButton.backgroundColor = [UIColor blackColor];
    if(isIPhone4) {
        categoryViewButton.frame = CGRectMake(0, 0, 320, 150);
    } else {
        categoryViewButton.frame = CGRectMake(0, 0, 320, 200);
    }
    // build header view
    UIView *categoryHeaderBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    categoryHeaderBg.backgroundColor = [UIColor colorWithHexString:@"#990000"];
    categoryHeader = [[UILabel alloc] initWithFrame:CGRectMake(10,0,320,30)];
    categoryHeader.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:14];
    categoryHeader.backgroundColor = [UIColor clearColor];
    categoryHeader.textColor = [UIColor whiteColor];
    categoryHeader.textAlignment = NSTextAlignmentLeft;
    [categoryHeaderBg addSubview:categoryHeader];
    
    // build category name view label
    UILabel *categoryName = [[UILabel alloc] init];
    if(isIPhone4) {
        categoryName.frame = CGRectMake(10,30,300,120);
    } else {
        categoryName.frame = CGRectMake(10,30,300,170);
    }
    categoryName.font = [UIFont fontWithName:FONT_GLOBAL size:40];
    categoryName.backgroundColor = [UIColor clearColor];
    categoryName.textColor = [UIColor whiteColor];
    categoryName.textAlignment = NSTextAlignmentCenter;
    categoryName.numberOfLines = 3;
    
    [categoryViewButton addSubview:categoryHeaderBg];
    [categoryViewButton addSubview:categoryName];
    [self.view addSubview:categoryViewButton];
    
    // send request for categories
    [self retreiveTopCategories:categoryName];

}
- (void) buildRecentListingSection {
    // build main container button view
    UIButton *listingViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [listingViewButton addTarget:self action:@selector(recentListingClick) forControlEvents:UIControlEventTouchUpInside];
    listingViewButton.backgroundColor = [UIColor blackColor];
    if(isIPhone4) {
        listingViewButton.frame = CGRectMake(0, 150, 320, 150);
    } else {
        listingViewButton.frame = CGRectMake(0, 200, 320, 200);
    }
    // build header view
    UIView *listingHeaderBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    listingHeaderBg.backgroundColor = [UIColor colorWithRed:(255.0 / 255.0) green:(146.0 / 255.0) blue:(23.0 / 255.0) alpha: 1];
    UILabel *listingHeader = [[UILabel alloc] initWithFrame:CGRectMake(10,0,320,30)];
    listingHeader.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:14];
    listingHeader.backgroundColor = [UIColor clearColor];
    listingHeader.textColor = [UIColor whiteColor];
    listingHeader.textAlignment = NSTextAlignmentLeft;
    listingHeader.text = @"Recent Listing";
    [listingHeaderBg addSubview:listingHeader];
    
    // build category name view label
    UILabel *listingName = [[UILabel alloc] init];
    if(isIPhone4) {
        listingName.frame = CGRectMake(10,30,300,120);
    } else {
        listingName.frame = CGRectMake(10,30,300,170);
    }
    listingName.font = [UIFont fontWithName:FONT_GLOBAL size:40];
    listingName.backgroundColor = [UIColor clearColor];
    listingName.textColor = [UIColor whiteColor];
    listingName.textAlignment = NSTextAlignmentCenter;
    listingName.text = @"This is the listing title here";
    listingName.numberOfLines = 3;
    
    [listingViewButton addSubview:listingHeaderBg];
    [listingViewButton addSubview:listingName];
    [self.view addSubview:listingViewButton];
    
}
- (void) buildTrendingTagsSection {
    UIView *trendingBg = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-172, 320, 60)];
    trendingBg.backgroundColor = [UIColor darkGrayColor];
    
    // Build the trending label
    UILabel *trendingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,10,100,40)];
    trendingLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:14];
    trendingLabel.backgroundColor = [UIColor clearColor];
    trendingLabel.textColor = [UIColor whiteColor];
    trendingLabel.textAlignment = NSTextAlignmentLeft;
    trendingLabel.text = @"Trending";
    
    // build the tags label
    UILabel *tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(60,0,50,40)];
    tagsLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12];
    tagsLabel.backgroundColor = [UIColor clearColor];
    tagsLabel.textColor = [UIColor redColor];
    tagsLabel.textAlignment = NSTextAlignmentLeft;
    tagsLabel.text = @"Tags";
    
    [trendingBg addSubview:trendingLabel];
    [trendingBg addSubview:tagsLabel];
    [self.view addSubview:trendingBg];

    
    // scrolling tags view
    UIView *scrollingTagsView = [[UIView alloc] initWithFrame:CGRectMake(100, screenHeight-172, 220, 60)];
    scrollingTagsView.backgroundColor = [UIColor blueColor];
    scrollingTagsView.clipsToBounds = YES;

    // tag1
    tags1Button = [UIButton buttonWithType:UIButtonTypeCustom];
    tags1Button.frame = CGRectMake(320,0,100,60);
    tags1Button.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL size:12];
    tags1Button.backgroundColor = [UIColor clearColor];
    tags1Button.titleLabel.textColor = [UIColor whiteColor];
    tags1Button.titleLabel.textAlignment = NSTextAlignmentLeft;
    [tags1Button setTitle:@"#BigTimeStory" forState:UIControlStateNormal];
    [scrollingTagsView addSubview:tags1Button];
    // retrieve tags (3)
    [self.view addSubview:scrollingTagsView];
    // begin the animations after the tags are retrieved
    [self animateTag1];
}
- (void) animateTag1 {
    [UIView animateWithDuration:15.0f
         animations:^{
             tags1Button.frame = CGRectMake(-220,0,100,60);
         }completion:^(BOOL finished){
             tags1Button.frame = CGRectMake(320,0,100,60);
             // WAIT A few seconds then animate again
             [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(animateTag1) userInfo:nil repeats:NO];
             //[self animateTag1:tags1Button];
         }];
}
- (void)updateView {
    self.navigationItem.title = [self.school.shortName stringByAppendingString:@" uList"];
    //self.navigationItem.rightBarButtonItem = searchButton;
}

-(void) showSearchViewController {
    [self performSegueWithIdentifier:SEGUE_SHOW_LISTING_SEARCH_VIEW_CONTROLLER sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if([[item title] isEqualToString:@"uCampus"]) {
        self.navigationItem.title = @"uCampus";
        self.navigationItem.rightBarButtonItem = nil;
        [UAppDelegate activateSideMenu : @"uCampus"];
    } else if([[item title] isEqualToString:@"Me"]) {
        self.navigationItem.title = @"Me";
        [UAppDelegate deactivateSideMenu];
        // Send a notification
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROFILE_VIEW_CONTROLLER object:nil];
    } else if([[item title] isEqualToString:@"uList"]) {
        self.navigationItem.title = @"uList";
        self.navigationItem.rightBarButtonItem = nil;
        [UAppDelegate deactivateSideMenu];
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
        categoryViewController.mainCat = menuCell.mainCat;
        categoryViewController.subCat = menuCell.subCat;
        categoryViewController.school = school;
    } else if ([[segue identifier] isEqualToString:SEGUE_SHOW_LISTING_SEARCH_VIEW_CONTROLLER]) {
        ListingSearchViewController *searchViewController = [segue destinationViewController];
        searchViewController.school = self.school;
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

/*
 * Retreive the top categories 
 * for this school
 */
- (void) retreiveTopCategories:(UILabel*)categoryName {
    @try {
        __block ImageActivityIndicatorView *iActivityIndicator;
        if (!iActivityIndicator)
        {
            iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
            [iActivityIndicator largeModeOn];
            [iActivityIndicator showActivityIndicator:categoryViewButton];
            categoryViewButton.userInteractionEnabled = NO;
        }
        // TODO: Show medium size activity indicator
        dispatch_queue_t categoryQueue = dispatch_queue_create(DISPATCH_ULIST_CATEGORY, NULL);
        dispatch_async(categoryQueue, ^{
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER_3737 stringByAppendingString:API_ULIST_CATEGORIES_TOP]]];
            NSString *json = @"{ \"limit\": 1,\"sid\":";
            json = [json stringByAppendingString:self.school.schoolId];
            json = [json stringByAppendingString:@"}"];
            NSLog(@"%@", json);
            NSData *requestData = [NSData dataWithBytes:[json UTF8String] length:[json length]];
            [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [req setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
            [req setHTTPBody: requestData];
            [req setHTTPMethod:HTTP_POST];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
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
    
                        NSDictionary *category = json[0];
                        NSDictionary *name = [category objectForKey:@"_id"];
                        categoryName.text = (NSString*)[name objectForKey:@"category"];
                        /* Determine if there are listings, if so we will say "Hot" if not "Featured' for the category header label title
                         */
                        int count = [((NSString*)[category objectForKey:@"count"]) intValue];
                        categoryHeader.text = (count > 0) ? @"Hot Category" : @"Featured Category";
                    } else {
                        categoryName.text = @"Oh no, where's your category?!";
                    }
                }
            }]; // end sendAsynchronousRequest
        }); // end dispatch_async
    }
    @catch (NSException *exception) {} 
}


#pragma mark Actions
-(void) categoryClick {
    NSLog(@"category click");
}
-(void) recentListingClick {
    NSLog(@"recent listing click");
}
-(void) tagClick:(id)sender {
    NSLog(@"tag click");
}
#pragma mark -
@end
