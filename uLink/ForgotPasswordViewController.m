//
//  ForgotPasswordViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/9/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "AppMacros.h"
#import "ActivityIndicatorView.h"
#import "AlertView.h"
#import "TextUtil.h"
@interface ForgotPasswordViewController () {
    AlertView *errorAlertView;
    NSString *needEmailValidationMsg;
    TextUtil *textUtil;
    ActivityIndicatorView *activityIndicator;
}
@end

@implementation ForgotPasswordViewController
@synthesize forgotFormView, forgotSuccessView, sendInstructions;
@synthesize backgroundView, emailTextField;
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
    forgotSuccessView.alpha  = 0.0;
    [sendInstructions createBlueButton:sendInstructions];
    needEmailValidationMsg = @"Please enter your valid email address.";
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: needEmailValidationMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
     self.emailTextField.delegate = self;
    textUtil = [TextUtil instance];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // reset the custom Alert view
    [errorAlertView resetAlert:needEmailValidationMsg];
}
-(IBAction) resetPassword {
    [self.view endEditing:YES];
    @try {
        if (![textUtil validEmail:self.emailTextField.text]) {
            [errorAlertView show];
            return;
        }
        
        [activityIndicator showActivityIndicator:self.view];
        
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t resetPasswordQueue = dispatch_queue_create(DISPATCH_RESETPASSWORD, NULL);
        dispatch_async(resetPasswordQueue, ^{
            NSString *requestData = [@"data[User][email]=" stringByAppendingString:self.emailTextField.text];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_USERS_RESET_PASSWORD]]];
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
                        NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                        if([(NSString*)result isEqualToString:@"true"]) {
                           self.forgotSuccessView.alpha  = 1.00;
                        } else {
                            errorAlertView.message = response;
                            [errorAlertView show];
                        }
                    } else {
                        errorAlertView.message = @"There was a problem resetting your password.  Please try again later or contact help@theulink.com.";
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