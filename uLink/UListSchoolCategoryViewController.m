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
#import "UListListingCell.h"
#import <Foundation/Foundation.h>

@interface UListSchoolCategoryViewController () {
    UIView *mapView;
    CGRect mapFrame;
}

@end

@implementation UListSchoolCategoryViewController
@synthesize categoryId, categoryName, locationManager, uListMapView_;

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


//- (void) loadView {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    /*
     GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:14];
    uListMapView_ = [GMSMapView  mapWithFrame: CGRectMake(0, 0, 320, 100) camera:camera];
    uListMapView_.myLocationEnabled = YES;
    self.view = uListMapView_;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = uListMapView_;
    */
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
            retVal = 1;
            break;
            
        case 1:
            retVal = [UDataCache.uListListings count];
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
        static NSString *CellIdentifier = @"selectMapCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UListListingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // add google maps to cell view
        mapView = uListMapView_;
        cell.frame = CGRectMake(0, 0, 320, 120);
        [cell.contentView addSubview:mapView];
    } else {
        static NSString *CellIdentifier = @"selectListingCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UListListingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        //@try {
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        Listing *list = [UDataCache.uListListings objectAtIndex:indexPath.row];
        NSLog(@"index: %i, %@", indexPath.row, list);
        
        ((UListListingCell*)cell).uListListing = list;
        ((UListListingCell*)cell).textLabel.text = list.title;
        //((UListListingCell*)cell).listing = [UDataCache.uListListings objectAtIndex:indexPath.row];
        //} @catch (NSException *exception) {}
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
