//
//  LoginViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/14/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "AlertView.h"
#import "PasswordViewController.h"
#import "DataCache.h"
@interface LoginViewController () {
    AlertView *errorAlertView;
    NSString *currentPassword;
    NSString *defaulValidationMsg;
    NSHashTable *validationErrors;
    ActivityIndicatorView *activityIndicator;
}
- (void)loadSessionUserData:(NSDictionary*)rawData;
@end

@implementation LoginViewController
@synthesize backgroundView;
@synthesize usernameTextField, passwordTextField;
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
	// Do any additional setup after loading the view.
    [logInButton createBlueButton:logInButton];
    defaulValidationMsg = @"";
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: defaulValidationMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    self.usernameTextField.delegate = self;
    self.usernameTextField.tag = kTextFieldUsername;
    self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordTextField.delegate = self;
    self.passwordTextField.tag = kTextFieldPassword;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.passwordTextField.clearsOnBeginEditing = YES;
    validationErrors = [[NSHashTable alloc] init];
    activityIndicator = [[ActivityIndicatorView alloc] init];
}
-(void)viewWillAppear:(BOOL)animated {
    backgroundView.alpha = 1;
    [backgroundView sizeToFit];
    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         backgroundView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){ //task after an animation ends
                         [self performSelector:@selector(animateBackground) withObject:nil afterDelay:0.0];
                     }];
}
-(void)animateBackground {
    [UIView animateWithDuration:15.0
                          delay: 0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = self.backgroundView.frame;
                         frame.origin.x -=50;
                         frame.origin.y += 5;
                         self.backgroundView.frame = frame;
                     }
                     completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)validateField:(int)tag {
    switch (tag) {
        case kTextFieldUsername: {
            if (self.usernameTextField.text.length < 1) {
                [validationErrors addObject:@"\nPlease enter your username"];
            }else {
                [validationErrors removeObject:@"\nPlease enter your username"];
            }
        }
            break;
        case kTextFieldPassword: {
            if (self.passwordTextField.text.length < 1) {
                [validationErrors addObject:@"\nPlease enter your password"];
            } else {
                [validationErrors removeObject:@"\nPlease enter your password"];
            }
        }
        break;
    }
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.passwordTextField isFirstResponder] && [touch view] != self.passwordTextField) {
        [self.passwordTextField  resignFirstResponder];
    } else if ([self.usernameTextField isFirstResponder] && [touch view] != self.usernameTextField) {
        [self.usernameTextField  resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if(textField.tag == kTextFieldPassword) {
        currentPassword = self.passwordTextField.text;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldUsername: [self validateField:kTextFieldUsername];
            break;
        case kTextFieldPassword:
            self.passwordTextField.text = currentPassword;
            [self validateField:kTextFieldPassword];
            break;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL retVal = NO;
    if([string isEqualToString:@""]) {
        retVal = YES;
    } else {
        retVal = textField.text.length < 255;
    }
    return retVal;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_PASSWORD_VIEW_CONTROLLER])
    {
        PasswordViewController *detailViewController = [segue destinationViewController];
        detailViewController.autoPass = TRUE;
    }
    [activityIndicator hideActivityIndicator:self.view];
}
- (IBAction)loginClick:(id)sender {
    @try {
        [self validateField:kTextFieldUsername];
        [self validateField:kTextFieldPassword];
        if([validationErrors count] > 0) {
            errorAlertView.message = @"";
            for (NSString *error in validationErrors) {
                errorAlertView.message = [errorAlertView.message stringByAppendingString:error];
            }
            [errorAlertView show];
            return;
        }
        [activityIndicator showActivityIndicator:self.view];
        
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t signUpQueue = dispatch_queue_create(DISPATCH_SIGNUP, NULL);
        dispatch_async(signUpQueue, ^{
            NSString *requestData = [@"username=" stringByAppendingString:self.usernameTextField.text];
            requestData = [requestData stringByAppendingString:[@"&password=" stringByAppendingString:currentPassword]];
            requestData = [requestData stringByAppendingString:[@"&mobile_login=" stringByAppendingString:@"yes"]];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_USERS_LOG_IN]]];
            [req setHTTPMethod:HTTP_POST];
            [req setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        NSDictionary *response = [json objectForKey:JSON_KEY_RESPONSE];
                        NSString* result = (NSString*)[json objectForKey:JSON_KEY_RESULT];
                        if([result isEqualToString:LOGIN_SUCCESS]) {
                            [self loadSessionUserData:response];
                            [UDataCache hydrateCaches];
                            [NSThread sleepForTimeInterval:SLEEP_TIME_LOGIN];
                            [self performSegueWithIdentifier:SEGUE_SHOW_MAIN_TAB_BAR_VIEW_CONTROLLER sender:self];
                        } else if ([result isEqualToString:LOGIN_AUTOPASS]) {
                            [self performSegueWithIdentifier:SEGUE_SHOW_PASSWORD_VIEW_CONTROLLER sender:self];
                        } else if ([(NSString*)result isEqualToString:LOGIN_INACTIVE]) {
                           errorAlertView.message = @"Your account is inactive, please check your email to complete the activation process or contact help@theulink.com.";
                           [errorAlertView show];
                        } else {
                           errorAlertView.message = @"Invalid login, please try again.";
                           [errorAlertView show];
                        }
                    } else {
                        errorAlertView.message = @"There was a problem with your login.  Please try again later or contact help@theulink.com.";
                        // show alert to user
                        [errorAlertView show];
                    }
                    [activityIndicator hideActivityIndicator:self.view];
                });
            }];
        });
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        // show alert to user
        [errorAlertView show];
    }
}
- (void) loadSessionUserData:(NSDictionary*)rawData {
    UDataCache.sessionUser = [[User alloc] init];
    // set the current password since it's valid
    UDataCache.sessionUser.password = currentPassword;
    [UDataCache.sessionUser hydrateUser:rawData];
}
@end
