//
//  ListingSearchViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 6/12/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "ListingSearchViewController.h"
#import "AppMacros.h"

@interface ListingSearchViewController ()
{
    UISearchBar *searchBar;
    UIView *modalOverlay;
}
-(void)showSearchView;
-(void)hideSearchView;
-(void)buildSearchBar;
-(void)executeSearch;
@end

@implementation ListingSearchViewController

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
	// Do any additional setup after loading the view.
    // set the title of the navigation bar
    self.navigationItem.title = @"Search";

    // create the search bar
    [self buildSearchBar];
    
    // initally show the search view
    [self showSearchView];
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
    // initially have the search bar and modal overlay hidden
   // searchBar.alpha = ALPHA_ZERO;
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
                         // show the search bar, and make show the modal overlay
                         modalOverlay.alpha = ALPHA_MED;
                        // searchBar.alpha = ALPHA_HIGH;
                     }
     ];
    modalOverlay.userInteractionEnabled = YES;
    // disable the scroll view
    //self.tableView.scrollEnabled = NO;
    [searchBar becomeFirstResponder];
}
/**
 * This method will perform all necessary steps to
 * hiding the search bar view
 */
- (void) hideSearchView {
  //  searchBar.alpha = ALPHA_ZERO;
    modalOverlay.alpha = ALPHA_ZERO;
    // re-enable the tableview scroll
   // self.tableView.scrollEnabled = YES;
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

#pragma mark - Search Bar Delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // hide the search view and perform the search
    [self hideSearchView];
    [self executeSearch];
}
#pragma mark -
#pragma mark - Actions
-(void) executeSearch {
    NSLog(@"starting the search");
}
#pragma mark -
@end
