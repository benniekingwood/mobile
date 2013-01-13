//
//  SignUpViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/10/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UlinkButton.h"
@interface SignUpViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    IBOutlet UlinkButton *createMyAccountButton;
}
@property (strong, nonatomic) IBOutlet UIPickerView *schoolStatusPickerView;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIView *signUpSuccessView;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *schoolStatusTextField;
-(IBAction)createAccount;
@property (nonatomic) NSString *schoolId;
@property (nonatomic) NSString *schoolName;
@end
