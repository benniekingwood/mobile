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
@end
