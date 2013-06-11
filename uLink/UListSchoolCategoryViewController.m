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

@synthesize mainCat, subCat, schoolId, locationManager, uListMapView_;
@synthesize searchResultOfSets, fetchBatch, loading, noMoreResultsAvail, retries;
@synthesize activityIndicatorView = _activityIndicatorView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (void)loadRequest
{
    DataLoader *loader = [[DataLoader alloc] init];
    loader.uListDelegate = self;
    [loader loadUListListingData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /****** Setup Lazy Loading (Initial) **********/
    fetchBatch = 0;
    retries = 0;
    noMoreResultsAvail = NO;
    searchResultOfSets = [[NSMutableArray alloc] init];
    
    // build query string
    // qt=c&mc=main_cat&c=sub_cat&sid=school_id&b=initial_batch
    NSString *query = [[NSString alloc] initWithFormat:@"qt=%@&mc=%@&c=%@&sid=%@&b=%i", @"c", [self.mainCat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], self.subCat, self.schoolId, fetchBatch];
    [UDataCache hydrateUListListingsCache:query];
    /*
    if ([UDataCache.uListListings count] > 0) {
        for (int i = 0; (i<ULIST_LISTING_BATCH_SIZE && i<[UDataCache.uListListings count]) ; i++) {
            NSLog(@"listing object: %@", [UDataCache.uListListings objectAtIndex:i]);
            [self.searchResultOfSets addObject:[UDataCache.uListListings objectAtIndex:i]];
        }
    }
    */
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
    
    // Setting Up Activity Indicator View
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    //self.tableView.tableFooterView = self.activityIndicatorView;
    //[self.activityIndicatorView startAnimating];
    
    /* set up map view */
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.uListMapView_.myLocation.coordinate.latitude
                                                            longitude:self.uListMapView_.myLocation.coordinate.longitude
                                                                 zoom:14];
    uListMapView_ = [GMSMapView  mapWithFrame: CGRectMake(0, 0, 320, 120) camera:camera];
    uListMapView_.myLocationEnabled = YES;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(camera.target.latitude,camera.target.longitude);
    marker.animated = YES;
    marker.title = @"MyLocation";
    marker.snippet = @"Me";
    marker.map = uListMapView_;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.uListMapView_ addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.uListMapView_ removeObserver:self forKeyPath:@"myLocation"];
    [self.searchResultOfSets removeAllObjects];
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
                //retVal = [searchResultOfSets count];
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
        if (indexPath.row >= ((searchResultOfSets.count*2)/3)) {
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
                return cell;
            } else {
                // The currently requested cell is the last cell.
                if (!noMoreResultsAvail) {
                    self.activityIndicatorView.center = cell.center;
                    [cell addSubview:self.activityIndicatorView];
                    [self.activityIndicatorView startAnimating];
                    return cell;
                } else {
                    //[self.activityIndicatorView removeFromSuperview];
                    [self.activityIndicatorView stopAnimating];
                    return ([self getNoMoreResultsCell]);
                }
            }
        } else {
            if (noMoreResultsAvail) {
                [self.activityIndicatorView stopAnimating];
                return ([self getNoMoreResultsCell]);
            }
            else
                [self.tableView reloadData];
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
                return 180.0;
            } else if ([list.type isEqualToString:@"bold"]) {
                return 80.0;
            } else {
                return 60.0;
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]])
    {
        [self.uListMapView_ animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:self.uListMapView_.myLocation.coordinate.latitude
                                                                                 longitude:self.uListMapView_.myLocation.coordinate.longitude
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_LISTING_DETAIL_VIEW_CONTROLLER]) {
        UListListingCell *cell = (UListListingCell *)sender;
        ListingDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.listing = cell.uListListing;
    }
}

@end
