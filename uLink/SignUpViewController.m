//
//  SignUpViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/10/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SignUpViewController.h"
#import "ActivityIndicatorView.h"
#import "AlertView.h"
#import "AppMacros.h"
#import "TextUtil.h"

@interface SignUpViewController (){
    AlertView *errorAlertView;
    NSString *defaulValidationMsg;
    TextUtil *textUtil;
    NSHashTable *validationErrors;
    NSArray *schoolStatuses;
    BOOL pickListVisible;
    NSString *currentPassword;
    ActivityIndicatorView *activityIndicator;
}
-(void)showValidationErrors;
-(void)validateField:(int)tag;
@end

@implementation SignUpViewController
@synthesize signUpSuccessView, backgroundView, schoolId, schoolName;
@synthesize usernameTextField,passwordTextField,emailTextField, schoolStatusPickerView;
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
    signUpSuccessView.alpha = ALPHA_ZERO;
    [createMyAccountButton createBlueButton:createMyAccountButton];
    defaulValidationMsg = @"";
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: defaulValidationMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    self.emailTextField.delegate = self;
    self.emailTextField.tag = kTextFieldEmail;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameTextField.delegate = self;
    self.usernameTextField.tag = kTextFieldUsername;
    self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordTextField.delegate = self;
    self.passwordTextField.tag = kTextFieldPassword;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.schoolStatusTextField.tag = kTextFieldSchoolStatus;
    self.schoolStatusTextField.delegate = self;
    self.schoolStatusTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.schoolStatusTextField.userInteractionEnabled = YES;
    self.schoolStatusTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    validationErrors = [[NSHashTable alloc] init];
    textUtil = [TextUtil instance];
    schoolStatuses = [[NSArray alloc] initWithObjects:@"",SCHOOL_STATUS_CURRENT_STUDENT, SCHOOL_STATUS_ALUMNI, nil];
    pickListVisible = FALSE;
    schoolStatusPickerView.dataSource = self;
    schoolStatusPickerView.delegate = self;
    schoolStatusPickerView.showsSelectionIndicator = YES;
    [schoolStatusPickerView selectRow:0 inComponent:0 animated:NO];
    schoolStatusPickerView.alpha = ALPHA_ZERO;
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
    float newX = self.backgroundView.frame.origin.x-50;
    float newY = self.backgroundView.frame.origin.y+5;
    [UIView animateWithDuration:15.0
                          delay: 0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = self.backgroundView.frame;
                         frame.origin.x = newX;
                         frame.origin.y = newY;
                         self.backgroundView.frame = frame;
                     }
                     completion:nil];
}

- (void)hideSchoolStatusPickerView {
   /* [UIView animateWithDuration:0.2
                          delay: 0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = schoolStatusPickerView.frame;
                         frame.origin.y += 226.0f;
                         schoolStatusPickerView.frame = frame;
                     }
                     completion:nil];*/
    pickListVisible = FALSE;
    schoolStatusPickerView.alpha = ALPHA_ZERO;
}
- (void)showSchoolStatusPickerView {
    /*[UIView animateWithDuration:0.2
                          delay: 0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = schoolStatusPickerView.frame;
                         frame.origin.y -= 226.0f;
                         schoolStatusPickerView.frame = frame;
                     }
                     completion:nil];*/
    pickListVisible = TRUE;
    schoolStatusPickerView.alpha = ALPHA_HIGH;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UIPickerView Section
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [schoolStatuses count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [schoolStatuses objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.schoolStatusTextField.text = [schoolStatuses objectAtIndex:row];
}
#pragma mark

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
        case kTextFieldUsername: {
            if (self.usernameTextField.text.length < 1) {
                [validationErrors addObject:@"\nPlease enter a username"];
            }else {
                [validationErrors removeObject:@"\nPlease enter a username"];
            }
        }
            break;
        case kTextFieldPassword:
        {
            if (self.passwordTextField.text.length < 6) {
                [validationErrors addObject:@"\nYour password must be at least six characters"];
            } else {
                [validationErrors removeObject:@"\nYour password must be at least six characters"];
            }
        }
            break;
        case kTextFieldEmail: {
            if (![textUtil validEmail:self.emailTextField.text]) {
                [validationErrors addObject:@"\nPlease enter a valid email address"];
            } else {
                [validationErrors removeObject:@"\nPlease enter a valid email address"];
            }
        }
            break;
        case kTextFieldSchoolStatus:
        if (self.schoolStatusTextField.text.length < 3) {
            [validationErrors addObject:@"\nPlease enter your school status"];
        } else {
            [validationErrors removeObject:@"\nPlease enter your school status"];
        }
        break;
    }

}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if([touch view] != self.schoolStatusTextField) {
        if(pickListVisible) {
            [self hideSchoolStatusPickerView];
        }
    }
    if ([self.passwordTextField isFirstResponder] && [touch view] != self.passwordTextField) {
        [self.passwordTextField  resignFirstResponder];
    } else if ([self.emailTextField isFirstResponder] && [touch view] != self.emailTextField) {
        [self.emailTextField  resignFirstResponder];
    } else if ([self.usernameTextField isFirstResponder] && [touch view] != self.usernameTextField) {
        [self.usernameTextField  resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if(pickListVisible) {
        [self hideSchoolStatusPickerView];
    }
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if(textField.tag == kTextFieldPassword) {
        currentPassword = self.passwordTextField.text;
    }
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL retVal = YES;
    if(textField.tag == kTextFieldSchoolStatus) {
        if(!pickListVisible) {
            [self showSchoolStatusPickerView];
        }
        if ([self.passwordTextField isFirstResponder]) {
            [self.passwordTextField  resignFirstResponder];
        } else if ([self.emailTextField isFirstResponder]) {
            [self.emailTextField  resignFirstResponder];
        } else if ([self.usernameTextField isFirstResponder]) {
            [self.usernameTextField  resignFirstResponder];
        }
        retVal = NO;
    } else {
        if(pickListVisible) {
            [self hideSchoolStatusPickerView];
        }
    }
    return retVal;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldUsername: [self validateField:kTextFieldUsername];
            break;
        case kTextFieldPassword:
            self.passwordTextField.text = currentPassword;
            [self validateField:kTextFieldPassword];
            break;
        case kTextFieldEmail: [self validateField:kTextFieldEmail];
            break;
        case kTextFieldSchoolStatus: [self validateField:kTextFieldSchoolStatus];
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

-(IBAction)createAccount {
    [self.view endEditing:YES];
    if(pickListVisible) {
        [self hideSchoolStatusPickerView];
    }
    @try {
        [self validateField:kTextFieldUsername];
        [self validateField:kTextFieldEmail];
        [self validateField:kTextFieldPassword];
        [self validateField:kTextFieldSchoolStatus];
        if([validationErrors count] > 0) {
            errorAlertView.message = @"";
            for (NSString *error in validationErrors) {
                errorAlertView.message = [errorAlertView.message stringByAppendingString:error];
            }
            [errorAlertView show];
            return;
        }
        
        [activityIndicator showActivityIndicator:self.view];
        NSString *requestData = [@"data[User][email]=" stringByAppendingString:self.emailTextField.text];
        requestData = [requestData stringByAppendingString:[@"&data[User][username]=" stringByAppendingString:self.usernameTextField.text]];
        requestData = [requestData stringByAppendingString:[@"&data[User][password]=" stringByAppendingString:self.passwordTextField.text]];
        requestData = [requestData stringByAppendingString:[@"&data[User][confirm_password]=" stringByAppendingString:self.passwordTextField.text]];
        requestData = [requestData stringByAppendingString:[@"&data[User][school_id]=" stringByAppendingString:self.schoolId]];
        requestData = [requestData stringByAppendingString:[@"&data[User][school_status]=" stringByAppendingString:self.schoolStatusTextField.text]];
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_USERS_SIGN_UP]]];
        [req setHTTPMethod:HTTP_POST];
        [req setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t signUpQueue = dispatch_queue_create(DISPATCH_SIGNUP, NULL);
        dispatch_async(signUpQueue, ^{
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
                        NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                        if([(NSString*)result isEqualToString:@"true"]) {
                            self.signUpSuccessView.alpha = 1.0;
                        } else {
                            errorAlertView.message = response;
                            [errorAlertView show];
                        }
                    } else {
                        errorAlertView.message = @"There was a problem creating your account.  Please try again later or contact help@theulink.com.";
                        // show alert to user
                        [errorAlertView show];
                    }
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
@end
