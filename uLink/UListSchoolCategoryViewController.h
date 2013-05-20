//
//  UListSchoolCategoryViewController.h
//  ulink
//
//  Created by Christopher Cerwinski on 5/7/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface UListSchoolCategoryViewController : UITableViewController
@property (nonatomic) IBOutlet CLLocationManager *locationManager;
@property (nonatomic) NSString *categoryId;
@property (nonatomic) NSString *categoryName;
@property (nonatomic) GMSMapView *uListMapView_;

// The data source to be displayed in the table (you should store the fetched data in this array)
@property (strong, nonatomic) NSMutableArray *searchResultOfSets;

// The counter of fetch batch.
@property (nonatomic) int fetchBatch;

// Indicates whether the data is already loading.
// Don't load the next batch of data until this batch is finished.
// You MUST set loading = NO when the fetch of a batch of data is completed.
@property (nonatomic) BOOL loading;

// noMoreResultsAvail indicates if there are no more search results.
// Implement noMoreResultsAvail in your app.
// For demo purpsoses here, noMoreResultsAvail = NO.
@property (nonatomic) BOOL noMoreResultsAvail;
@end
