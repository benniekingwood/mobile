//
//  PasswordViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/13/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "PasswordViewController.h"
#import "AlertView.h"
#import "ActivityIndicatorView.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "SuccessNotificationView.h"
#import <QuartzCore/QuartzCore.h>
#import "TextUtil.h"
@interface PasswordViewController () {
    AlertView *errorAlertView;
    NSString *currentPassword;
    NSString *newPassword;
    NSString *verifyPassword;
    NSString *autoGenPassMsg;
    NSHashTable *validationErrors;
    ActivityIndicatorView *activityIndicator;
    SuccessNotificationView *successNotification;
    TextUtil *textUtil;
}

@end

@implementation PasswordViewController
@synthesize autoPass;
@synthesize currentPasswordTextField;
@synthesize verifyPasswordTextField;
@synthesize theNewPasswordTextField;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    autoGenPassMsg = @"Your password is auto generated, please change your password to gain full access to uLink.";
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: autoGenPassMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];

    self.currentPasswordTextField.delegate = self;
    self.currentPasswordTextField.tag = kTextFieldPassword;
    self.currentPasswordTextField.secureTextEntry = YES;
    self.currentPasswordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.currentPasswordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.currentPasswordTextField.clearsOnBeginEditing = YES;
    self.theNewPasswordTextField.delegate = self;
    self.theNewPasswordTextField.tag = kTextFieldNewPassword;
    self.theNewPasswordTextField.secureTextEntry = YES;
    self.theNewPasswordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.theNewPasswordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.theNewPasswordTextField.clearsOnBeginEditing = YES;
    self.verifyPasswordTextField.delegate = self;
    self.verifyPasswordTextField.tag = kTextFieldVerifyPassword;
    self.verifyPasswordTextField.secureTextEntry = YES;
    self.verifyPasswordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.verifyPasswordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.verifyPasswordTextField.clearsOnBeginEditing = YES;
    validationErrors = [[NSHashTable alloc] init];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    successNotification = [[SuccessNotificationView alloc] init];
    [successNotification setMessage:@"Password Updated."];
    if(autoPass) {
        // hide the back button if coming from the login screen to reset the password
        self.navigationItem.hidesBackButton = YES;
        [errorAlertView show];
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.weakLabel.alpha = ALPHA_ZERO;
    self.weakLabel.layer.cornerRadius = 5;
    self.mediumLabel.alpha = ALPHA_ZERO;
    self.mediumLabel.layer.cornerRadius = 5;
    self.strongLabel.alpha = ALPHA_ZERO;
    self.strongLabel.layer.cornerRadius = 5;
    textUtil = [TextUtil instance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)showValidationErrors {
    errorAlertView.message = @"";
    if([validationErrors count] > 0) {
        for (NSString *error in validationErrors) {
            errorAlertView.message = [errorAlertView.message stringByAppendingString:error];
        }
        [errorAlertView show];
    }
}
- (void)validateField:(int)tag {
    switch (tag) {
        case kTextFieldNewPassword: {
            if (self.theNewPasswordTextField.text.length < 6) {
                [validationErrors addObject:@"\nYour password must be at least six characters"];
            }else {
                [validationErrors removeObject:@"\nYour password must be at least six characters"];
            }
        }
            break;
        case kTextFieldPassword: {
            if (self.currentPasswordTextField.text.length < 1) {
                [validationErrors addObject:@"\nPlease enter your password"];
            } else {
                [validationErrors removeObject:@"\nPlease enter your password"];
            }
        }
            break;
        case kTextFieldVerifyPassword: {
            if (![self.verifyPasswordTextField.text isEqualToString:self.theNewPasswordTextField.text]) {
                [validationErrors addObject:@"\nYour new and verify passwords must match"];
            } else {
                [validationErrors removeObject:@"\nYour new and verify passwords must match"];
            }
        }
            break;
    }
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.currentPasswordTextField isFirstResponder] && [touch view] != self.currentPasswordTextField) {
        [self.currentPasswordTextField  resignFirstResponder];
    } else if ([self.theNewPasswordTextField isFirstResponder] && [touch view] != self.theNewPasswordTextField) {
        [self.theNewPasswordTextField  resignFirstResponder];
    } else if ([self.verifyPasswordTextField isFirstResponder] && [touch view] != self.verifyPasswordTextField) {
        [self.verifyPasswordTextField  resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldNewPassword: 
            newPassword = self.theNewPasswordTextField.text;
            break;
        case kTextFieldPassword:
            currentPassword = self.currentPasswordTextField.text;
            break;
        case kTextFieldVerifyPassword:
            verifyPassword  = self.verifyPasswordTextField.text;
            break;
    }

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldNewPassword:
            [self validateField:kTextFieldNewPassword];
            self.theNewPasswordTextField.text = newPassword;
            break;
        case kTextFieldPassword:
            [self validateField:kTextFieldPassword];
            self.currentPasswordTextField.text = currentPassword;
            break;
        case kTextFieldVerifyPassword:
            [self validateField:kTextFieldVerifyPassword];
            self.verifyPasswordTextField.text = verifyPassword;
            break;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL retVal = NO;
    self.navigationItem.rightBarButtonItem.enabled = TRUE;
    if(textField.tag == kTextFieldNewPassword) {
        switch ([textUtil evaluatePasswordStrength:[textField.text stringByReplacingCharactersInRange:range withString:string]]) {
            case kWeakStrength:
                self.weakLabel.alpha = ALPHA_HIGH;
                self.mediumLabel.alpha = ALPHA_ZERO;
                self.strongLabel.alpha = ALPHA_ZERO;
                break;
            case kMediumStrength:
                self.weakLabel.alpha = ALPHA_HIGH;
                self.mediumLabel.alpha = ALPHA_HIGH;
                self.strongLabel.alpha = ALPHA_ZERO;
                break;
            case kStrongStrength:
                self.weakLabel.alpha = ALPHA_HIGH;
                self.mediumLabel.alpha = ALPHA_HIGH;
                self.strongLabel.alpha = ALPHA_HIGH;
                break;
            case kNoStrength:
                self.weakLabel.alpha = ALPHA_ZERO;
                self.mediumLabel.alpha = ALPHA_ZERO;
                self.strongLabel.alpha = ALPHA_ZERO;
                break;
        }
    }
    
    if([string isEqualToString:@""]) {
        retVal = YES;
    } else {
        retVal = textField.text.length < 255;
    }
    return retVal;
}
- (BOOL) textFieldShouldClear:(UITextField *)textField {
    if(textField.tag == kTextFieldNewPassword) {
        self.weakLabel.alpha = ALPHA_ZERO;
        self.mediumLabel.alpha = ALPHA_ZERO;
        self.strongLabel.alpha = ALPHA_ZERO;
    }
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // reset the custom Alert view
    [errorAlertView resetAlert:@""];
}
- (IBAction)saveClick:(id)sender {
    @try {
        [self validateField:kTextFieldNewPassword];
        [self validateField:kTextFieldPassword];
        [self validateField:kTextFieldVerifyPassword];
        if([validationErrors count] > 0) {
            errorAlertView.message = @"";
            for (NSString *error in validationErrors) {
                errorAlertView.message = [errorAlertView.message stringByAppendingString:error];
            }
            [errorAlertView show];
            return;
        }
        [activityIndicator showActivityIndicator:self.view];
        self.navigationItem.rightBarButtonItem.enabled = FALSE;
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t passwordQueue = dispatch_queue_create(DISPATCH_UPDATE_PASSWORD, NULL);
        dispatch_async(passwordQueue, ^{
            NSString *requestData = [@"data[User][oldpass]=" stringByAppendingString:self.currentPasswordTextField.text];
            requestData = [requestData stringByAppendingString:[@"&data[User][newpass]=" stringByAppendingString:self.theNewPasswordTextField.text]];
            requestData = [requestData stringByAppendingString:[@"&data[User][newconfirmpass]=" stringByAppendingString:self.verifyPasswordTextField.text]];
            requestData = [requestData stringByAppendingString:[@"&data[User][id]=" stringByAppendingString:UDataCache.sessionUser.userId]];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_USERS_UPDATE_PASSWORD]]];
            [req setHTTPMethod:HTTP_POST];
            [req setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [activityIndicator hideActivityIndicator:self.view];
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        NSString *response = (NSString*)[json objectForKey:JSON_KEY_RESPONSE];
                        NSString* result = (NSString*)[json objectForKey:JSON_KEY_RESULT];
                        if([result isEqualToString:@"true"]) {
                            // set new password in UserCache
                            UDataCache.sessionUser.password = currentPassword;
                            // clear text fields
                            self.theNewPasswordTextField.text = @"";
                            self.currentPasswordTextField.text = @"";
                            self.verifyPasswordTextField.text = @"";
                            currentPassword = @"";
                            newPassword = @"";
                            verifyPassword = @"";
                            if (autoPass) {
                                // after animation completes dismiss
                                [self.navigationController popViewControllerAnimated:YES];
                            } else {
                                [successNotification showNotification:self.view];
                                self.weakLabel.alpha = ALPHA_ZERO;
                                self.mediumLabel.alpha = ALPHA_ZERO;
                                self.strongLabel.alpha = ALPHA_ZERO;
                            }
                        } else {
                            if (response != nil) {
                                // remove HTML line breaks from response
                                NSString *filteredResponse = [response stringByReplacingOccurrencesOfString: @"<br />" withString:@"\n"];
                                errorAlertView.message = filteredResponse;
                            } else {
                                errorAlertView.message = @"There was a problem updating your password.  Please try again later or contact help@theulink.com.";
                            }
                            [errorAlertView show];
                            self.navigationItem.rightBarButtonItem.enabled = TRUE;
                        }
                    } else {
                        errorAlertView.message = @"There was a problem updating your password.  Please try again later or contact help@theulink.com.";
                        // show alert to user
                        [errorAlertView show];
                        self.navigationItem.rightBarButtonItem.enabled = TRUE;
                    }
                });
            }];
        });
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = TRUE;
        // show alert to user
        [errorAlertView show];
    }
}
@end
