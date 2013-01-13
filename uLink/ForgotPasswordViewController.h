//
//  ForgotPasswordViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/9/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UlinkButton.h"
@interface ForgotPasswordViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *forgotSuccessView;
@property (strong, nonatomic) IBOutlet UIView *forgotFormView;
@property (weak, nonatomic) IBOutlet UlinkButton *sendInstructions;
-(IBAction) resetPassword;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@end

