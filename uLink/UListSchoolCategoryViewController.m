//
//  UListSchoolCategoryViewController.m
//  ulink
//
//  Created by Christopher Cerwinski on 5/7/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListSchoolCategoryViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AppMacros.h"
#import "DataCache.h"
#import "DataLoader.h"
#import "UListMapCell.h"
#import "UListListingCell.h"
#import "ListingDetailViewController.h"
#import <Foundation/Foundation.h>

@interface UListSchoolCategoryViewController () {
    UIView *mapView;
    CGRect mapFrame;
}

@end

@implementation UListSchoolCategoryViewController

@synthesize mainCat, subCat, school, locationManager, uListMapView_;
@synthesize searchResultOfSets, fetchBatch, loading, noMoreResultsAvail, retries;
@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;
@synthesize moreResultsSpinner = _moreResultsSpinner;
@synthesize initializeSpinner = _initializeSpinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupStrings];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self != nil) {
        [self setupStrings];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self setupStrings];
    }
    return self;
}

- (void)loadRequest
{
    DataLoader *loader = [[DataLoader alloc] init];
    loader.uListDelegate = self;
    [loader loadUListListingData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addPullToRefreshHeader];
    
    /****** Setup Lazy Loading (Initial) **********/
    fetchBatch = 0;
    retries = 0;
    noMoreResultsAvail = NO;
    searchResultOfSets = [[NSMutableArray alloc] init];
    
    // build query string
    // qt=c&mc=main_cat&c=sub_cat&sid=school_id&b=initial_batch
    NSString *query = [[NSString alloc] initWithFormat:@"qt=%@&mc=%@&c=%@&sid=%@&b=%i", @"c", [self.mainCat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], self.subCat, self.school.schoolId, fetchBatch];
    [UDataCache hydrateUListListingsCache:query];
    self.loading = YES;
    [self loadRequest];
    /****** End Lazy Loading ***********/
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.901 green:0.882 blue:0.89 alpha:1.0];
    self.tabBarController.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    mapFrame = CGRectMake(0, 70, 320, 120);
    CGRect mViewFrame;
    mViewFrame.origin.x = 0;
    mViewFrame.origin.y = 0;
    mViewFrame.size = self.view.frame.size;
    mapView = [[UIView alloc] initWithFrame:mViewFrame];
    mapView.backgroundColor = [UIColor blackColor];
    mapView.frame = mViewFrame;
    mapView.userInteractionEnabled = YES;
    
    // set up spinner when loading initial data
    _initializeSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = self.tableView.frame;
    _initializeSpinner.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    [self.tableView addSubview:_initializeSpinner];
    [_initializeSpinner startAnimating];
    
    // Setup more results spinner (don't activate yet)
    self.moreResultsSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.moreResultsSpinner.hidesWhenStopped = YES;

    
    /* set up map view */
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.school.latitude doubleValue]                                                            longitude:[self.school.longitude doubleValue]
                                                                 zoom:14];
    uListMapView_ = [GMSMapView  mapWithFrame: CGRectMake(0, 0, 320, 120) camera:camera];
    uListMapView_.myLocationEnabled = YES;
    uListMapView_.camera = camera;
}



- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.uListMapView_ addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.searchResultOfSets = nil;
    [self.uListMapView_ removeObserver:self forKeyPath:@"myLocation"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        // add google maps to cell view
        mapView = uListMapView_;
        cell.frame = CGRectMake(0, 0, 320, 120);
        [cell.contentView addSubview:mapView];
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

#pragma mark - Table view delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    if (section == 0) {
        return 120.0;
    } else {
        /* grab the type of listing to determine the height of the row  */
        if (indexPath.row < searchResultOfSets.count) {
            Listing *list = (Listing*)[searchResultOfSets objectAtIndex:indexPath.row];
            if ([list.type isEqualToString:@"headline"]) {
                return 220.0;
            } else if ([list.type isEqualToString:@"bold"]) {
                return 140.0;
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
    } else {
        UListListingCell *cell = (UListListingCell*)[tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:SEGUE_SHOW_LISTING_DETAIL_VIEW_CONTROLLER sender:cell];
    }
}

/* This message is sent to the receiver when the value at the specified key path relative to the given object has changed. */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@", keyPath);
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]])
    {
        [self.uListMapView_ animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:[self.school.latitude doubleValue]
                                                                                 longitude:[self.school.longitude doubleValue]
                                                                                      zoom:self.uListMapView_.camera.zoom]];
    }
}

- (UITableViewCell*)getNoMoreResultsCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_SELECT_ULIST_LISTING_CELL];
    cell.textLabel.font = [UIFont systemFontOfSize:10];
    cell.textLabel.text = @"Well, this is embarrassing.. (Get the word out, we need more listings!)";
    cell.textLabel.textColor = [UIColor colorWithRed:0.65f
                                               green:0.65f
                                                blue:0.65f
                                               alpha:1.00f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

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
    
    NSLog(@"refreshing the listings...");
    [_initializeSpinner startAnimating];
    
    // let's refresh all of our listings
    fetchBatch = 0;
    retries = 0;
    noMoreResultsAvail = NO;
    [searchResultOfSets removeAllObjects];
    
    // build query string
    // qt=c&mc=main_cat&c=sub_cat&sid=school_id&b=initial_batch
    NSString *query = [[NSString alloc] initWithFormat:@"qt=%@&mc=%@&c=%@&sid=%@&b=%i", @"c", [self.mainCat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], self.subCat, self.school.schoolId, fetchBatch];
    [UDataCache hydrateUListListingsCache:query];
    //[self loadRequest];

    // stop loading
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
    
    NSLog(@"loading request w/ new data...");
    [self loadRequest];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_LISTING_DETAIL_VIEW_CONTROLLER]) {
        UListListingCell *cell = (UListListingCell *)sender;
        ListingDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.listing = cell.uListListing;
    }
}
@end
