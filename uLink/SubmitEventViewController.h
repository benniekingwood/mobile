//
//  SubmitEventViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/27/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UlinkButton.h"
typedef enum {
    CameraActive, 
    TimeActive, 
    LocationActive
} LowerOverlayPosition;

@interface SubmitEventViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextView *eventInfoTextView;
@property (strong, nonatomic) IBOutlet UITextField *dateTextField;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
- (IBAction)cancelClick:(UIBarButtonItem *)sender;
- (IBAction)cameraClick:(UIButton *)sender;
- (IBAction)timeClick:(UIButton *)sender;
- (IBAction)locationClick:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutlet UITextField *timeTextField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightNavItem;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UIImageView *lowerOverlay;
- (IBAction)submitClick:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leftNavItem;
@property (strong, nonatomic) IBOutlet UIView *submitSuccessView;
@property (nonatomic, assign) LowerOverlayPosition overlayPosition;
@property (strong, nonatomic) IBOutlet UIView *overlayFormView;
@end
