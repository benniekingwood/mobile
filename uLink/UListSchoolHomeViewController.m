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

@interface UListSchoolHomeViewController () {
    UIBarButtonItem *searchButton;
    CGFloat screenWidth;
    CGFloat screenHeight;
    BOOL isIPhone4;
}
- (void) buildCategorySection;
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
    NSLog(@"%f", screenHeight);
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
    UIButton *categoryViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [categoryViewButton addTarget:self action:@selector(categoryClick) forControlEvents:UIControlEventTouchUpInside];
    categoryViewButton.backgroundColor = [UIColor darkGrayColor];
    if(isIPhone4) {
        categoryViewButton.frame = CGRectMake(0, 0, 320, 150);
    } else {
        categoryViewButton.frame = CGRectMake(0, 0, 320, 200);
    }
    // build header view
    
    UIView *categoryHeaderBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    categoryHeaderBg.backgroundColor = [UIColor orangeColor];
    UILabel *categoryHeader = [[UILabel alloc] initWithFrame:CGRectMake(10,0,320,30)];
    categoryHeader.font = [UIFont fontWithName:FONT_GLOBAL size:14];
    categoryHeader.backgroundColor = [UIColor clearColor];
    categoryHeader.textColor = [UIColor whiteColor];
    categoryHeader.textAlignment = NSTextAlignmentLeft;
    // determine "Hot" or "Featured"
    if(true) {
        categoryHeader.text = @"Hot Category";
    } else {
        categoryHeader.text = @"Featured Category";
    }
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
    categoryName.text = @"TUTORS";
    categoryName.numberOfLines = 3;
    
    [categoryViewButton addSubview:categoryHeaderBg];
    [categoryViewButton addSubview:categoryName];
    [self.view addSubview:categoryViewButton];
    
    // send request for categories

}
- (void) buildRecentListingSection {
    // build main container button view
    UIButton *listingViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [listingViewButton addTarget:self action:@selector(categoryClick) forControlEvents:UIControlEventTouchUpInside];
    listingViewButton.backgroundColor = [UIColor brownColor];
    if(isIPhone4) {
        listingViewButton.frame = CGRectMake(0, 150, 320, 150);
    } else {
        listingViewButton.frame = CGRectMake(0, 200, 320, 200);
    }
    // build header view
    UIView *listingHeaderBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    listingHeaderBg.backgroundColor = [UIColor purpleColor];
    UILabel *listingHeader = [[UILabel alloc] initWithFrame:CGRectMake(10,0,320,30)];
    listingHeader.font = [UIFont fontWithName:FONT_GLOBAL size:14];
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
    
    // retrieve trends 
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

#pragma mark Actions
-(void) categoryClick {
    
}
#pragma mark -
@end
