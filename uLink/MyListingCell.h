//
//  MyListingCell.h
//  ulink
//
//  Created by Bennie Kingwood on 5/26/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"
@interface MyListingCell : UITableViewCell
{
    Listing *_listing;
}
@property (nonatomic) Listing *listing;
-(void)initialize;
@end
