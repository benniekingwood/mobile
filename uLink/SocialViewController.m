//
//  SocialViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/13/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SocialViewController.h"
#import "DataCache.h"
#import "AppMacros.h"
#import "ActivityIndicatorView.h"
#import "SuccessNotificationView.h"
#import "AlertView.h"
@interface SocialViewController ()
{
    AlertView *errorAlertView;
    NSString *defaultValidationMsg;
    ActivityIndicatorView *activityIndicator;
    SuccessNotificationView *successNotification;
    NSHashTable *validationErrors;
}
- (void) refreshTweetsCache;
@end

@implementation SocialViewController
@synthesize twitterEnabledSwitch;
@synthesize twitterUserNameTextField;
@synthesize saveButton;
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
	self.saveButton.enabled = FALSE;
    self.twitterUserNameTextField.clearsOnBeginEditing = NO;
    self.twitterUserNameTextField.delegate = self;
    self.twitterUserNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.twitterUserNameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.twitterUserNameTextField.text = UDataCache.sessionUser.twitterUsername;
    self.twitterEnabledSwitch.on = UDataCache.sessionUser.twitterEnabled;
    defaultValidationMsg = @"To enable this feature please enter your Twitter username.";
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: defaultValidationMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    successNotification = [[SuccessNotificationView alloc] init];
    validationErrors = [[NSHashTable alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.saveButton.enabled = TRUE;
    BOOL retVal = NO;
    if([string isEqualToString:@""]) {
        retVal = YES;
    } else {
        retVal = self.twitterUserNameTextField.text.length < 255;
    }
    return retVal;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.twitterUserNameTextField isFirstResponder] && [touch view] != self.twitterUserNameTextField) {
        [self.twitterUserNameTextField  resignFirstResponder];
    } 
    [super touchesBegan:touches withEvent:event];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)twitterEnabledChange:(UISwitch *)sender {
    self.saveButton.enabled = TRUE;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // reset the custom Alert view
    [errorAlertView resetAlert:defaultValidationMsg];
}
- (void)validateField:(int)tag {
    if (tag == kTextFieldTwitterUsername) {
        if (self.twitterEnabledSwitch.isOn && self.twitterUserNameTextField.text.length < 1) {
            [validationErrors addObject:defaultValidationMsg];
        } else {
            [validationErrors removeObject:defaultValidationMsg];
        }
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField.tag == kTextFieldTwitterUsername) {
        [self validateField:kTextFieldTwitterUsername];
    }
}
- (void) refreshTweetsCache {
    [UDataCache hydrateTweetsCache];
}
- (IBAction)saveClick:(id)sender {
    [self.view endEditing:YES];
    @try {
        [self validateField:kTextFieldTwitterUsername];
        if([validationErrors count] > 0) {
            
            errorAlertView.message = @"";
            for (NSString *error in validationErrors) {
                errorAlertView.message = [errorAlertView.message stringByAppendingString:error];
            }
            [errorAlertView show];
            return;
        }
        [activityIndicator showActivityIndicator:self.view];
        self.saveButton.enabled = FALSE;
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t updateSocialQueue = dispatch_queue_create(DISPATCH_UPDATE_SOCIAL, NULL);
        dispatch_async(updateSocialQueue, ^{
            NSString *requestData = [@"data[User][twitter_username]=" stringByAppendingString:self.twitterUserNameTextField.text];
            if(self.twitterEnabledSwitch.on) {
                requestData = [requestData stringByAppendingString:@"&data[User][twitter_enabled]=1"];
            } else {
                requestData = [requestData stringByAppendingString:@"&data[User][twitter_enabled]=0"]; 
            }
            requestData = [requestData stringByAppendingString:[@"&data[User][id]=" stringByAppendingString:UDataCache.sessionUser.userId]];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_USERS_UPDATE_SOCIAL]]];
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
                            // set new user information in UserCache
                            UDataCache.sessionUser.twitterEnabled = self.twitterEnabledSwitch.isOn;
                            UDataCache.sessionUser.twitterUsername = self.twitterUserNameTextField.text;
                            [successNotification showNotification:self.view];
                            /*
                             * Since it was successful, we need to refresh the tweets cache 
                             * since the user updated their information
                             */
                            [self performSelectorInBackground:@selector(refreshTweetsCache) withObject:self];
                        } else {
                            self.saveButton.enabled = TRUE;
                            if (response != nil && [response isEqualToString:@""] ) {
                                errorAlertView.message = response;
                            } else {
                                errorAlertView.message = @"There was a problem updating your account.  Please try again later or contact help@theulink.com.";
                            }
                            [errorAlertView show];
                        }
                    } else {
                        self.saveButton.enabled = TRUE;
                        errorAlertView.message = @"There was a problem updating your account.  Please try again later or contact help@theulink.com.";
                        // show alert to user
                        [errorAlertView show];
                    }
                });
            }];
        });
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        self.saveButton.enabled = TRUE;
        // show alert to user
        [errorAlertView show];
    }
}
@end
