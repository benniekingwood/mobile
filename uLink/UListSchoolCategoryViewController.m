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
#import "UListListingCell.h"
#import <Foundation/Foundation.h>

@interface UListSchoolCategoryViewController () {
    UIView *mapView;
    CGRect mapFrame;
}

@end

@implementation UListSchoolCategoryViewController
@synthesize categoryId, categoryName, locationManager, uListMapView_;

/* Synthesize for lazy loading properties */
@synthesize searchResultOfSets;
@synthesize fetchBatch;
@synthesize loading;
@synthesize noMoreResultsAvail;

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
    noMoreResultsAvail = NO;
    searchResultOfSets = [[NSMutableArray alloc] init];
    if ([UDataCache.uListListings count] > 0) {
        for (int i = 0; i<10 ; i++) {
            [self.searchResultOfSets addObject:[UDataCache.uListListings objectAtIndex:i]];
        }
    }
    [self loadRequest];
    /****** End Lazy Loading ***********/
    
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
    self.searchResultOfSets = nil;
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
            // If data source is yet empty, then return 0 cell.
            // If data source is not empty, then return one more cell space.
            // (for displaying the "Loading More..." text)
            if (searchResultOfSets.count == 0) {
                retVal =  0;
            } else {
                retVal = ([searchResultOfSets count]+1);
            }
            //retVal = [UDataCache.uListListings count];
            break;
    }
    NSLog(@"number of rows in section retVal: %i", retVal);
    return retVal;
}

/*
 * Custom create table view cells for map and listingss
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    UITableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // map section
    if (section == 0) {
        static NSString *CellIdentifier = CELL_SELECT_ULIST_MAP;
        //cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UListListingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // add google maps to cell view
        mapView = uListMapView_;
        cell.frame = CGRectMake(0, 0, 320, 120);
        [cell.contentView addSubview:mapView];
    } else {
        static NSString *CellIdentifier = CELL_SELECT_ULIST_LISTING_CELL;
        //cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UListListingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // If scrolled beyond two thirds of the table, load next batch of data.
        if (indexPath.row >= (searchResultOfSets.count /3 *2)) {
            if (!loading) {
                NSLog(@"at 2/3 of page.. loading next 10 results");
                loading = YES;
                // loadRequest is the method that loads the next batch of data.
                // This needs your implementation to load the data into searchResultOfSets
                [self loadRequest];
            }
        }
        
        // Only starts populating the table if data source is not empty.
        if (searchResultOfSets.count != 0) {
            // If the currently requested cell is not the last one, display normal data.
            // Else dispay @"Loading More..." or @"(No More Results Available)"
            if (indexPath.row < searchResultOfSets.count) {
                cell.textLabel.text = ((Listing*)[searchResultOfSets objectAtIndex:indexPath.row]).title;
                return cell;
            } else {
                // The currently requested cell is the last cell.
                if (!noMoreResultsAvail) {
                    // If there are results available, display @"Loading More..." in the last cell

                    cell.textLabel.text = @"Loading More...";
                    cell.textLabel.font = [UIFont systemFontOfSize:18];
                    cell.textLabel.textColor = [UIColor colorWithRed:0.65f
                                                               green:0.65f
                                                                blue:0.65f
                                                               alpha:1.00f];
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    return cell;
                } else {
                    // If there are no results available, display @"(No More Results Available)" in the last cell
                    cell.textLabel.font = [UIFont systemFontOfSize:16];
                    cell.textLabel.text = @"(No More Results Available)";
                    cell.textLabel.textColor = [UIColor colorWithRed:0.65f
                                                               green:0.65f
                                                                blue:0.65f
                                                               alpha:1.00f];
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    return cell;
                }
            }
        } else {
            [self.tableView reloadData];
        }
        
        /*
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        Listing *list = [UDataCache.uListListings objectAtIndex:indexPath.row];
        ((UListListingCell*)cell).uListListing = list;
        ((UListListingCell*)cell).textLabel.text = list.title;
        */
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    if (section == 0) {
        return 120.0;
    } else {
        return 50.0;
    }
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    if (section == 0) {
        /* if we select the map, then expand map to display larger */
    } else {
        
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


@end
