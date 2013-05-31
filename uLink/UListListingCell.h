//
//  UListListingCell.h
//  ulink
//
//  Created by Christopher Cerwinski on 5/14/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"

@interface UListListingCell : UITableViewCell
@property (nonatomic, strong) Listing *uListListing;
-(void)initialize;
@end
