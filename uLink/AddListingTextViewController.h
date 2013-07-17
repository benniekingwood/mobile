//
//  AddListingTextViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 7/3/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppMacros.h"
#import "Listing.h"
@interface AddListingTextViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate,UITextViewDelegate>
@property (nonatomic) AddListingTextMode mode;
@property (nonatomic, strong) Listing *listing;
@end
