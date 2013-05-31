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

@interface UListSchoolCategoryViewController : UITableViewController {
    UIActivityIndicatorView *_activityIndicatorView;
}
@property (nonatomic) IBOutlet CLLocationManager *locationManager;
@property (nonatomic) NSString *subCat;
@property (nonatomic) NSString *mainCat;
@property (nonatomic) NSString *schoolId;
@property (nonatomic) GMSMapView *uListMapView_;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;


@property (strong, nonatomic) NSMutableArray *searchResultOfSets;
@property (nonatomic) int fetchBatch;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL noMoreResultsAvail;
@property (nonatomic) int retries;

@end
