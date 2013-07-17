//
//  AddListingViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 6/22/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"

@interface AddListingViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (strong, nonatomic) IBOutlet UITableViewCell *tagsCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *priceCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *descriptionCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *titleCell;
@property (nonatomic) NSString *mainCategory;
@property (nonatomic) NSString *subCategory;
@property (nonatomic, strong) Listing *listing;
- (IBAction)nextClick:(id)sender;
@end
