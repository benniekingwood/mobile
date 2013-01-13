//
//  PasswordViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/13/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UILabel *strongLabel;
@property (strong, nonatomic) IBOutlet UILabel *mediumLabel;
@property (strong, nonatomic) IBOutlet UILabel *weakLabel;
- (IBAction)saveClick:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *theNewPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *verifyPasswordTextField;
@property (nonatomic) BOOL autoPass;
@end
