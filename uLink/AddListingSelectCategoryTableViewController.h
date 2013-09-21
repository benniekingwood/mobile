//
//  AddListingSelectCategoryTableViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 6/22/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyListingsViewController.h"

@interface AddListingSelectCategoryTableViewController : UITableViewController
- (IBAction)cancelClick:(UIBarButtonItem *)sender;
@property (nonatomic) BOOL dismissImmediately;
@end
