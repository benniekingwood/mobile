//
//  ListingResultsTableView.m
//  ulink
//
//  Created by Bennie Kingwood on 6/15/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "ListingResultsTableViewController.h"
#import "DataCache.h"
#import "AppMacros.h"
#import "DataLoader.h"
#import "UListMapCell.h"
#import "UListListingCell.h"
#import "ListingDetailViewController.h"
@interface ListingResultsTableViewController() {
    UIView *mapView;
    CGRect mapFrame;
    UIButton *closeMap;
    DataLoader *loader;
}
-(void)shrinkMap:(id)sender;
@end

@implementation ListingResultsTableViewController
@synthesize uListMapView_, selectedRowIndex;
@synthesize searchResultOfSets, fetchBatch, loading, noMoreResultsAvail, retries;
@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;
@synthesize moreResultsSpinner = _moreResultsSpinner;
@synthesize initializeSpinner = _initializeSpinner;
@synthesize searchText;
@synthesize mainCat, subCat;
@synthesize queryType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"listing result view did load");
    self.tableView.showsVerticalScrollIndicator = NO;
    loader = [[DataLoader alloc] init];
    [self setupStrings];
    [self addPullToRefreshHeader];
    
    /****** Setup Lazy Loading (Initial) **********/
    fetchBatch = 0;
    retries = 0;
    // this is now set by the parent view
   // noMoreResultsAvail = NO;
    searchResultOfSets = [[NSMutableArray alloc] init];
    
    self.noMoreResultsAvail = YES;
    self.tableView.separatorColor = [UIColor clearColor];
    //self.tableView.backgroundColor = [UIColor colorWithRed:0.901 green:0.882 blue:0.89 alpha:1.0];
    //self.tableView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.9411 green:0.9372 blue:0.9215 alpha:1.0];
    //self.tabBarController.navigationItem.hidesBackButton = YES;
   // self.navigationItem.leftBarButtonItem = nil;
    mapFrame = CGRectMake(0, 70, 320, 120);
    CGRect mViewFrame;
    mViewFrame.origin.x = 0;
    mViewFrame.origin.y = 0;
    mViewFrame.size = self.tableView.frame.size;
    mapView = [[UIView alloc] initWithFrame:mViewFrame];
    mapView.backgroundColor = [UIColor blackColor];
    mapView.frame = mViewFrame;
    mapView.userInteractionEnabled = YES;
    mapView.clipsToBounds = YES;
    
    // set up spinner when loading initial data
    _initializeSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = self.tableView.frame;
    _initializeSpinner.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    [self.tableView addSubview:_initializeSpinner];
    [_initializeSpinner startAnimating];
    
    // Setup more results spinner (don't activate yet)
    self.moreResultsSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.moreResultsSpinner.hidesWhenStopped = YES;
    
    /* initial map view */
    // GMSUISettings *uListMapSettings = [[GMSUISettings alloc] init];
    // [uListMapSettings setScrollGestures:NO];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.school.latitude doubleValue]                                                            longitude:[self.school.longitude doubleValue] zoom:13];
    uListMapView_ = [GMSMapView  mapWithFrame: CGRectMake(0, 0, 320, 120) camera:camera];
    uListMapView_.myLocationEnabled = YES;
    //uListMapView_.settings = uListMapSettings;
    uListMapView_.camera = camera;
    
    // create closeMap uibarbutton
    closeMap = [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-40, 30, 30, 30)];
    [closeMap setHidden:YES];
    [closeMap addTarget:self action:@selector(shrinkMap:) forControlEvents:UIControlEventTouchUpInside];
    [closeMap setTitle:@"X" forState:UIControlStateNormal];
    [closeMap setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeMap setBackgroundColor:[UIColor orangeColor]];
    [closeMap.titleLabel setFont:[UIFont fontWithName:FONT_GLOBAL_BOLD size:24.0f]];
    [closeMap.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [closeMap.layer setShadowOffset:CGSizeMake(.5f, .5f)];
    [closeMap.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [closeMap.layer setShadowOpacity:0.5f];
    [closeMap.layer setCornerRadius:5.0f];
    [self.tableView addSubview:closeMap];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.uListMapView_ addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];
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
    @try {
        [self.uListMapView_ removeObserver:self forKeyPath:@"myLocation"];
    } @catch (NSException *exception){}
}


- (void)loadRequest
{
    loader.uListDelegate = self;
    [loader loadUListListingData];
}


/* return map to original state */
-(void)shrinkMap:(id)sender {
    if (self.selectedRowIndex && self.selectedRowIndex.section == 0) {
        [self.tableView beginUpdates];
        [closeMap setHidden:YES];
        
        /* remove any observers if they exist */
        @try {
            [self.uListMapView_ removeObserver:self forKeyPath:@"myLocation"];
        } @catch (NSException *exception){}
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.school.latitude doubleValue]                                                            longitude:[self.school.longitude doubleValue] zoom:13];
        uListMapView_ = [GMSMapView  mapWithFrame: CGRectMake(0, 0, 320, 120) camera:camera];
        [self.uListMapView_ addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.selectedRowIndex.row inSection:self.selectedRowIndex.section]] withRowAnimation:UITableViewRowAnimationFade];
        
        /* reset when we close the map view */
        self.selectedRowIndex = nil;
        [self.tableView endUpdates];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_LISTING_DETAIL_VIEW_CONTROLLER]) {
        UListListingCell *cell = (UListListingCell *)sender;
        ListingDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.listing = cell.uListListing;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int retVal = 0;
    switch (section) {
        case 0:
            // Return 1 row for the map view to be displayed
            retVal = 1;
            break;
            
        case 1:
            // Return the number of rows in the section.
            // If data source is yet empty, then return 1 cell (to display no data
            // message).
            // If data source is not empty, then return one more cell space.
            // (for displaying the "Loading More..." text)
            if (searchResultOfSets.count == 0) {
                retVal =  1;
            } else {
                retVal = ([searchResultOfSets count]+1);
            }
            break;
    }
    //NSLog(@"number of rows in section retVal: %i", retVal);
    return retVal;
}

/*
 * Custom create table view cells for map and listingss
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    UITableViewCell *cell = nil;
    
    // map section
    if (section == 0) {
        static NSString *CellIdentifier = CELL_SELECT_ULIST_MAP;
        if (cell == nil) {
            cell = [[UListMapCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        UIView *bottomLine = [[UIView alloc] init];
        
        // add google maps to cell view
        if (selectedRowIndex && selectedRowIndex.row == indexPath.row) {
            cell.frame = CGRectMake(0, 0, 320, 460);
            
            bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 120, 320, 1)];
            bottomLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
            [bottomLine.layer setShadowOffset:CGSizeMake(2.0f, 2.0f)];
            [bottomLine.layer setShadowColor:[[UIColor whiteColor] CGColor]];
            [bottomLine.layer setShadowOpacity:0.5];
        }
        else {
            cell.frame = CGRectMake(0, 0, 320, 120);
            
            bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 120, 320, 1)];
            bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
            [bottomLine.layer setShadowOffset:CGSizeMake(2.0f, 2.0f)];
            [bottomLine.layer setShadowColor:[[UIColor blackColor] CGColor]];
            [bottomLine.layer setShadowOpacity:0.5];
            [bottomLine.layer setShadowRadius:2.0f];
        }
        
        mapView = uListMapView_;
        //cell.clipsToBounds = YES;
        //cell.layer.masksToBounds = YES;
        [cell.contentView addSubview:mapView];
        [cell.contentView addSubview:bottomLine];
    } else {
        static NSString *CellIdentifier = CELL_SELECT_ULIST_LISTING_CELL;
        if (cell == nil) {
            cell = [[UListListingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // If scrolled beyond two thirds of the table, load next batch of data.
        // Make sure that our set data count exceeds the batch size
        if ((indexPath.row >= ((searchResultOfSets.count*2)/3))) {
            if (!loading && !noMoreResultsAvail) {
                NSLog(@"at 2/3 of page.. loading next 10 results");
                loading = YES;
                // loadRequest is the method that loads the next batch of data.
                // This needs your implementation to load the data into searchResultOfSets
                [self loadRequest];
            }
        }
        
        // Only starts populating the table if data source is not empty.
        if (searchResultOfSets.count != 0) {
            if ((indexPath.row < searchResultOfSets.count)) {
                Listing *list = (Listing*)[searchResultOfSets objectAtIndex:indexPath.row];
                ((UListListingCell*)cell).uListListing = list;
                [(UListListingCell*)cell initialize];
                
                // Creates a marker at the listing location (if available)
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake([list.location.latitude doubleValue], [list.location.longitude doubleValue]);
                marker.animated = YES;
                marker.title = list.title;
                marker.snippet = list.shortDescription;
                marker.map = uListMapView_;
                return cell;
            } else {
                // The currently requested cell is the last cell.
                if (!noMoreResultsAvail) {
                    self.moreResultsSpinner.center = cell.center;
                    [cell addSubview:self.moreResultsSpinner];
                    [self.moreResultsSpinner startAnimating];
                    return cell;
                } else {
                    //[self.activityIndicatorView removeFromSuperview];
                    [self.moreResultsSpinner stopAnimating];
                    if ([_initializeSpinner isAnimating]) [_initializeSpinner stopAnimating];
                    return ([self getNoMoreResultsCell]);
                }
            }
        } else {
            if (noMoreResultsAvail) {
                [self.moreResultsSpinner stopAnimating];
                if ([_initializeSpinner isAnimating]) [_initializeSpinner stopAnimating];
                return ([self getNoMoreResultsCell]);
            }
            else {
                //NSLog(@"Reloading listing table data..");
                [self.tableView reloadData];
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    if (section == 0) {
        if (self.selectedRowIndex && self.selectedRowIndex.row == indexPath.row)
            return 460.0; // 480 = full screen
        else
            return 120.0;
    } else {
        /* grab the type of listing to determine the height of the row  */
        if (indexPath.row < searchResultOfSets.count) {
            Listing *list = (Listing*)[searchResultOfSets objectAtIndex:indexPath.row];
            if ([list.type isEqualToString:@"highlight"]) {
                return 285.0;
            } else {
                return 140.0;
            }
        }
        
        /* here, we will return the height to display loading, or no more results.. */
        return 60.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    if (section == 0) {
        /* if we select the map, then expand map to display larger */
        self.selectedRowIndex = indexPath;
        [tableView beginUpdates];
        [closeMap setHidden:NO];
        
        /* remove any observers if they exist */
        @try {
            [self.uListMapView_ removeObserver:self forKeyPath:@"myLocation"];
        } @catch (NSException *exception){}
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.school.latitude doubleValue]                                                            longitude:[self.school.longitude doubleValue] zoom:14];
        uListMapView_ = [GMSMapView  mapWithFrame: CGRectMake(0, 0, 320, 460) camera:camera];
        [self.uListMapView_ addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
    } else {
        UListListingCell *cell = (UListListingCell*)[tableView cellForRowAtIndexPath:indexPath];
        [super performSegueWithIdentifier:SEGUE_SHOW_LISTING_DETAIL_VIEW_CONTROLLER sender:cell];
    }
}

/* This message is sent to the receiver when the value at the specified key path relative to the given object has changed. (i.e user is walking with device) */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]])
    {
        [self.uListMapView_ animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:[self.school.latitude doubleValue]
                                                                                longitude:[self.school.longitude doubleValue]
                                                                                     zoom:self.uListMapView_.camera.zoom]];
    }
}

/* display ulink logo when no more results */
- (UITableViewCell*)getNoMoreResultsCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_SELECT_ULIST_LISTING_CELL];
    UIImageView *endListing = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 320, 56)];
    endListing.contentMode = UIViewContentModeScaleAspectFit;
    endListing.image = [UIImage imageNamed:@"ulink_short_logo.png"];
    [cell addSubview:endListing];
    return cell;
}
#pragma mark -

#pragma mark - Refresh Header Code

- (void)setupStrings{
    self.textPull = @"Pull down to update...";
    self.textRelease = @"Release to update...";
    self.textLoading = @"Updating...";
}

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 270, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentLeft;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"todo_add_an_arrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    27, 44);
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [self.tableView addSubview:refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading || loading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                refreshLabel.text = self.textRelease;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                // User is scrolling somewhere within the header
                refreshLabel.text = self.textPull;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    NSLog(@"Refreshing from the pull down on the the header...");
    
    isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text = self.textLoading;
        refreshArrow.hidden = YES;
        [refreshSpinner startAnimating];
    }];
    
    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
    
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete)];
                     }];
}

- (void)stopLoadingComplete {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

- (void)refresh {
    
    NSLog(@"ListingResultsTableViewController - starting the search");
    [_initializeSpinner startAnimating];
    
    // let's refresh all of our listings
    fetchBatch = 0;
    retries = 0;
    noMoreResultsAvail = NO;
    [searchResultOfSets removeAllObjects];
    NSString *query;
    if (self.queryType == kListingQueryTypeSearch) {
        // qt=s&mc=main_cat&c=sub_cat&sid=school_id&b=initial_batch&t=search_text
        query = [[NSString alloc] initWithFormat:@"qt=s&sid=%@&b=%i&t=%@", self.school.schoolId, self.fetchBatch, self.searchText];
    } else if (self.queryType == kListingQueryTypeSubCategory) {
        /*
         * grab the next batch of listing data (if there is any...)
         */
        query = [[NSString alloc] initWithFormat:@"qt=%@&mc=%@&c=%@&sid=%@&b=%i", @"c", [self.mainCat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], self.subCat, self.school.schoolId, self.fetchBatch];
    } else if (self.queryType == kListingQueryTypeSubCategorySearch) {
        query = [[NSString alloc] initWithFormat:@"qt=s&mc=%@&c=%@&sid=%@&b=%i&t=%@", [self.mainCat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], [self.subCat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], self.school.schoolId, self.fetchBatch, self.searchText];
    }

    [UDataCache hydrateUListListingsCache:query];
    // stop loading
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
    // ensure that the Data loader doesn't try to reload while we are already loading
    self.loading = YES;
    [self loadRequest];

}
#pragma mark -
@end
