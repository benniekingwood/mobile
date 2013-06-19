//
//  UListSchoolCategoryViewController.m
//  ulink
//
//  Created by Christopher Cerwinski on 5/7/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//
//

#import "UListSchoolCategoryViewController.h"
#import "AppMacros.h"
#import "ListingResultsTableViewController.h"

@interface UListSchoolCategoryViewController () {
    UIView *mapView;
    CGRect mapFrame;
    UISearchBar *searchBar;
    UIView *modalOverlay;
    UIButton *closeMap;
    ListingResultsTableViewController *resultsTableViewController;
}
-(void)buildCategoryHeaderView;
-(void)showSearchView;
-(void)hideSearchView;
-(void)buildSearchBar;
-(void)executeSearch;
@end

@implementation UListSchoolCategoryViewController

@synthesize mainCat, subCat, school;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // set the title of the navigation bar 
    self.navigationItem.title = @"Listings";
    // add the "Search" button
    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchView)];
    self.navigationItem.rightBarButtonItem = btnSearch;
    
    // add the category's title header view
    [self buildCategoryHeaderView];
    
    // create the search bar
    [self buildSearchBar];
    
    // initially load the category data
    resultsTableViewController.fetchBatch = 0;
    resultsTableViewController.retries = 0;
    resultsTableViewController.noMoreResultsAvail = NO;
    resultsTableViewController.mainCat = self.mainCat;
    resultsTableViewController.subCat = self.subCat;
    resultsTableViewController.queryType = kListingQueryTypeSubCategory;
    resultsTableViewController.school = self.school;
    [resultsTableViewController loadListings:NOTIFICATION_ULIST_SCHOOL_CATEGORY_VIEW_CONTROLLER];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/** 
 * Cache the current listing data first.  We will re-use
 * this data when/if we re-enter screen.  Caching will be set
 * for 5 minutes initially.  Obviously, cache results before
 * we clear the search result set
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 * This function will build up the category header view
 */
- (void) buildCategoryHeaderView {
    UIView *catHeaderBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    catHeaderBg.backgroundColor = [UIColor blackColor];
    catHeaderBg.alpha = ALPHA_MED;
    catHeaderBg.userInteractionEnabled = NO;
    [self.view addSubview:catHeaderBg];
    UILabel *catTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 310, 18)];
    catTitleLabel.userInteractionEnabled = NO;
    catTitleLabel.font = [UIFont fontWithName:FONT_GLOBAL size:13];
    catTitleLabel.textColor = [UIColor whiteColor];
    catTitleLabel.backgroundColor = [UIColor clearColor];
    catTitleLabel.text = self.subCat;
    [self.view addSubview:catTitleLabel];
}
/**
 * This function will build all of the search bar related
 * views.
 */
- (void) buildSearchBar {
    // build the modal overlay that will show when the user clicks the search button
    modalOverlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    modalOverlay.backgroundColor = [UIColor blackColor];
    modalOverlay.userInteractionEnabled = YES;
    // add a tap gesture recognizer to just the modal overlay that will cancel the search keyboard
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleModalTap:)];
    [modalOverlay addGestureRecognizer:singleFingerTap];
    // now create the search bar
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    searchBar.delegate = self;
    searchBar.showsCancelButton = YES;
    searchBar.placeholder = [@"Search " stringByAppendingString:self.subCat];
    // initially have the search bar and modal overlay hidden
    searchBar.alpha = ALPHA_ZERO;
    modalOverlay.alpha = ALPHA_ZERO;
    [self.view addSubview:modalOverlay];
    [self.view addSubview:searchBar];
}

/**
 * This method will perform all necessary steps to
 * show the search bar view
 */
- (void) showSearchView {
    // scroll to the top of the view
    [UIView animateWithDuration:0.2f
             animations:^{
                 // show the search bar, and make show the modal overlay
                 modalOverlay.alpha = ALPHA_MED;
                 searchBar.alpha = ALPHA_HIGH;
             }
     ];
    modalOverlay.userInteractionEnabled = YES;
    [searchBar becomeFirstResponder];
}
/**
 * This method will perform all necessary steps to 
 * hiding the search bar view 
 */
- (void) hideSearchView {
    searchBar.alpha = ALPHA_ZERO;
    modalOverlay.alpha = ALPHA_ZERO;
    if([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
}

/**
 * This method will handle the tap of the modal overlay.  I will only
 * hide the keyboard for the search bar.
 */
- (void)handleModalTap:(UITapGestureRecognizer *)recognizer {
    [self hideSearchView];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ 
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString:SEGUE_LISTING_RESULTS_VIEW_CONTROLLER_EMBED]) {
        resultsTableViewController = (ListingResultsTableViewController *) [segue destinationViewController];
        resultsTableViewController.noMoreResultsAvail = YES;
    }
}
#pragma mark - Search Bar Delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // hide the search view and perform the search
    [self hideSearchView];
    [self executeSearch];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self hideSearchView];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar {
    modalOverlay.alpha = ALPHA_MED;
    return YES;
}
#pragma mark -
#pragma mark - Actions
-(void) executeSearch {    
    [resultsTableViewController.searchResultOfSets removeAllObjects];
    [resultsTableViewController.tableView reloadData];
    resultsTableViewController.fetchBatch = 0;
    resultsTableViewController.retries = 0;
    resultsTableViewController.noMoreResultsAvail = NO;
    resultsTableViewController.queryType = kListingQueryTypeSubCategorySearch;
    resultsTableViewController.searchText = searchBar.text;
    [resultsTableViewController loadListings:NOTIFICATION_ULIST_SCHOOL_CATEGORY_VIEW_CONTROLLER];
}
#pragma mark -
@end
