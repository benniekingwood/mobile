//
//  ListingResultsTableView.h
//  ulink
//
//  Created by Bennie Kingwood on 6/15/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "School.h"
@interface ListingResultsTableViewController : UITableViewController
{
    UIActivityIndicatorView *moreResultsSpinner;
    UIActivityIndicatorView *refreshSpinner;
    UIActivityIndicatorView *initializeSpinner;
    UIView *refreshHeaderView;
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    BOOL isDragging;
    BOOL isLoading;
}
@property (nonatomic) NSString *subCat;
@property (nonatomic) NSString *mainCat;
@property (nonatomic) GMSMapView *uListMapView_;
@property (nonatomic, strong) UIActivityIndicatorView *moreResultsSpinner;
@property (nonatomic, strong) UIActivityIndicatorView *initializeSpinner;
@property (nonatomic) School *school;
@property (nonatomic) NSString *searchText;
@property (nonatomic) int queryType;

/* lazy loading */
@property (strong, nonatomic) NSMutableArray *searchResultOfSets;
@property (nonatomic) int fetchBatch;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL noMoreResultsAvail;
@property (nonatomic) int retries;
@property (nonatomic, strong) NSIndexPath *selectedRowIndex;

/* pull down refresh */
@property (nonatomic, strong) UIView *refreshHeaderView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UIImageView *refreshArrow;
@property (nonatomic, strong) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic) NSString *textPull;
@property (nonatomic) NSString *textRelease;
@property (nonatomic) NSString *textLoading;

- (void)setupStrings;
- (void)addPullToRefreshHeader;
- (void)startLoading;
- (void)stopLoading;
- (void)loadListings:(NSString*)notificationHandler;
@end
