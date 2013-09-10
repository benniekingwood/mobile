//
//  SaveListingViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 9/2/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppMacros.h"
#import "Listing.h"

@interface SaveListingViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate,UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate,UINavigationControllerDelegate>
@property (nonatomic) ListingSaveType saveMode;
@property (nonatomic, strong) Listing *listing;
@end
