//
//  SubmitSnapshotViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 12/3/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UlinkButton.h"
#import "AFPhotoEditorController.h"
@interface SubmitSnapshotViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate, AFPhotoEditorControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *submitSuccessView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (strong, nonatomic) IBOutlet UIImageView *photoPlaceHolderView;
@property (strong, nonatomic) IBOutlet UITextField *categoryTextField;
@property (strong, nonatomic) IBOutlet UITextView *captionTextView;
- (IBAction)cancelClick:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UlinkButton *takePhotoButton;
@property (strong, nonatomic) IBOutlet UlinkButton *chooseButton;
- (IBAction)nextClick:(id)sender;
@property (nonatomic) BOOL dismissImmediately;
@end
