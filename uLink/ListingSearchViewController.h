//
//  ListingSearchViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 6/12/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "School.h"
@interface ListingSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate>
@property (nonatomic) School *school;
@end
