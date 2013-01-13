//
//  LoginViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/14/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UlinkButton.h"
#import "ActivityIndicatorView.h"
@interface LoginViewController : UIViewController <UITextFieldDelegate> {
IBOutlet UlinkButton *logInButton;
}
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
- (IBAction)loginClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@end
