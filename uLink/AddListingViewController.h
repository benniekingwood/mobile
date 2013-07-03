//
//  AddListingViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 6/22/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddListingViewController : UITableViewController
@property (nonatomic) NSString *mainCategory;
@property (nonatomic) NSString *subCategory;
- (IBAction)nextClick:(id)sender;
@end
