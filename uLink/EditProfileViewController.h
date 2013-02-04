//
//  EditProfileViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/13/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFPhotoEditorController.h"
@protocol EditProfileViewControllerDelegate;
@protocol EditProfileViewControllerDelegate <NSObject>
-(void) updateProfileInformation;
@end
@interface EditProfileViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, AFPhotoEditorControllerDelegate> {
    id<EditProfileViewControllerDelegate> _delegate;
}
@property (nonatomic, assign) id<EditProfileViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)cancelClick:(UIBarButtonItem *)sender;
- (IBAction)saveClick:(id)sender;
@end
