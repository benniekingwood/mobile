//
//  AddListingPhotoViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 7/14/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"
@interface AddListingPhotoViewController : UIViewController <UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) Listing *listing;
@end
