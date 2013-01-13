//
//  SuggestSchoolViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/10/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SuggestSchoolViewController.h"
#import "AppMacros.h"
#import "ActivityIndicatorView.h"
@interface SuggestSchoolViewController () {
    AlertView *errorAlertView;
    NSString *suggestFailMsg;
    NSString *suggestValidationMsg;
    ActivityIndicatorView *activityIndicator;
}
@end

@implementation SuggestSchoolViewController
@synthesize suggestSuccessView,backgroundView,schoolNameTextField;
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
    suggestSuccessView.alpha = 0.0;
    [submit createBlueButton:submit];
    suggestFailMsg = @"Your suggestion was not submitted. Please try again later.";
    suggestValidationMsg = @"Please enter a school name.";
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                                     message: suggestFailMsg
                                                    delegate:self
                                           cancelButtonTitle:BTN_OK
                                           otherButtonTitles:nil];
    self.schoolNameTextField.delegate = self;
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
        retVal = textField.text.length < 500;
    }
    return retVal;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // reset the custom Alert view
    [errorAlertView resetAlert:suggestFailMsg];
}

-(IBAction)submitSuggestion {
    @try {
        if (self.schoolNameTextField.text.length < 1) {
            errorAlertView.message = suggestValidationMsg;
            [errorAlertView show];
            return;
        }
        
        [activityIndicator showActivityIndicator:self.view];
             
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t suggestionQueue = dispatch_queue_create(DISPATCH_SUGGESTION, NULL);
        dispatch_async(suggestionQueue, ^{
            // do our long running process here
            //[NSThread sleepForTimeInterval:5];

            NSString *requestData = [@"data[School][name]=" stringByAppendingString:self.schoolNameTextField.text];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_SCHOOLS_SUGGESTION]]];
            [req setHTTPMethod:HTTP_POST];
            [req setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
                // do any UI stuff on the main UI thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [activityIndicator hideActivityIndicator:self.view];
                    if ([data length] > 0 && error == nil) {
                        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        if([responseString isEqualToString:@"true"]) {
                            self.suggestSuccessView.alpha = 1.00;
                        } else {
                            [errorAlertView show];
                        }
                    } else {
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
