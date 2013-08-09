//
//  ListingSearchViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 6/12/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "ListingSearchViewController.h"
#import "ListingResultsTableViewController.h"
#import "AppMacros.h"
#import "DataCache.h"

@interface ListingSearchViewController ()
{
    UISearchBar *searchBar;
    UIView *modalOverlay;
    ListingResultsTableViewController *resultsTableViewController;
}
-(void)showSearchView;
-(void)hideSearchView;
-(void)buildSearchBar;
-(void)executeSearch;
@end

@implementation ListingSearchViewController
@synthesize school, executeSearchOnLoad, searchTxt;
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
    // set the title of the navigation bar
    self.navigationItem.title = @"Search";
    
    // create the search bar
    [self buildSearchBar];
    
    // initally show the search view
    if (!executeSearchOnLoad)
        [self showSearchView];
    
    // initialize the listing results table
    resultsTableViewController.school = self.school;
    resultsTableViewController.queryType = kListingQueryTypeSearch;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        
    // if execute search immediately has been set, then perform
    // search with search text provided
    if (executeSearchOnLoad) {
        if (searchTxt) {
            [searchBar setText:searchTxt];
            [self executeSearch];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    searchBar.placeholder = @"Search Listings";
    // initially have the modal overlay hidden
    modalOverlay.alpha = ALPHA_ZERO;
    [self.view addSubview:modalOverlay];
    [self.view addSubview:searchBar];
}

/**
 * This method will perform all necessary steps to
 * show the search bar view
 */
- (void) showSearchView {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         // show the modal overlay
                         modalOverlay.alpha = ALPHA_MED;
                     }
     ];
    if(![searchBar isFirstResponder]) {
        [searchBar becomeFirstResponder];
    }
}
/**
 * This method will perform all necessary steps to
 * hiding the search bar view
 */
- (void) hideSearchView {
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
- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar {
    modalOverlay.alpha = ALPHA_MED;
    return YES;
}
-(BOOL) searchBar:(UISearchBar *)curSearchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL retVal = YES;
    // this is to make sure that the first character is not a space
    if ([curSearchBar.text length] == 0 && [text isEqualToString:@" "]) {
        retVal = NO;
    }
    return retVal;
}
#pragma mark -
#pragma mark - Actions
-(void) executeSearch {
    [resultsTableViewController.searchResultOfSets removeAllObjects];
    [resultsTableViewController.tableView reloadData];
    resultsTableViewController.fetchBatch = 0;
    resultsTableViewController.searchText = searchBar.text;
    [resultsTableViewController loadListings:NOTIFICATION_LISTING_SEARCH_VIEW_CONTROLLER];
}
#pragma mark -
@end
