//
//  AddListingAddOnViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 7/11/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"
@interface AddListingAddOnViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *submitSuccessView;
@property (nonatomic, strong) Listing *listing;
@end