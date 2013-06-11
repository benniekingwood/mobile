//
//  ListingDetailViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 6/1/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"
#import "UlinkButton.h"
@interface ListingDetailViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>
{
    Listing *_listing;
}
@property (strong, nonatomic) IBOutlet UILabel *contactListerBackground;
@property (strong, nonatomic) IBOutlet UlinkButton *contactListerButton;
@property(nonatomic, strong) Listing *listing;
@end
