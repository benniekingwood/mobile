//
//  SubmitEventViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/27/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SubmitEventViewController.h"
#import "AlertView.h"
#import "ActivityIndicatorView.h"
#import "SuccessNotificationView.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "TextUtil.h"
#import "EventUtil.h"
#import "PreviewPhotoView.h"
#import "ImageUtil.h"
@interface SubmitEventViewController ()  {
    AlertView *errorAlertView;
    AlertView *customAlertView;
    NSString *defaulValidationMsg;
    NSHashTable *validationErrors;
    BOOL timePickListVisible;
    ActivityIndicatorView *activityIndicator;
    NSString *defaultValidationMsg;
    NSDateFormatter *dateFormatter;
    UIPickerView *timePickerView;
    UIImagePickerController *imagePicker;
    PreviewPhotoView *previewPhotoView;
    UlinkButton *takePhotoButton;
    UlinkButton *chooseButton;
    CGRect floatLocFrame;
    UIImageView *locTextImageBg;
    UIView *modalOverlay;
    BOOL floatLocationVisible;
    UILabel *infoCounter;
    AFPhotoEditorController *photoEditorController;
}
-(void)showValidationErrors;
-(void)validateField:(int)tag;
- (NSMutableURLRequest*) buildDataRequest;
-(void)rehydrateEventCaches;
@end

@implementation SubmitEventViewController
@synthesize overlayPosition;
@synthesize submitSuccessView,navBar, leftNavItem, rightNavItem;
@synthesize timeTextField,titleTextField, dateTextField,eventInfoTextView,locationTextField;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.overlayPosition = CameraActive;
   // self.navBar = @"Submit Event";
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
  
    chooseButton = [UlinkButton buttonWithType:UIButtonTypeCustom];
    //set the button's title
    [chooseButton setTitle:BTN_CHOOSE_PHOTO forState:UIControlStateNormal];
    [chooseButton createDefaultSmallButton:chooseButton];
    chooseButton.backgroundColor = [UIColor grayColor];

    [chooseButton addTarget:self action:@selector(choosePhoto:) forControlEvents:UIControlEventTouchUpInside];
    chooseButton.tag = kButtonChoosePhoto;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        takePhotoButton = [UlinkButton buttonWithType:UIButtonTypeCustom];
        [takePhotoButton createDefaultSmallButton:takePhotoButton];
         takePhotoButton.tag = kButtonTakePhoto;
        [takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [takePhotoButton setTitle:BTN_TAKE_PHOTO forState:UIControlStateNormal];
        takePhotoButton.backgroundColor = [UIColor grayColor];
        takePhotoButton.frame = CGRectMake(685, 8, 230, 30);
        chooseButton.frame = CGRectMake(685, 45, 230, 30);
        [self.overlayFormView addSubview:takePhotoButton];
    } else {
        chooseButton.frame = CGRectMake(685, 18, 230, 30);
    }
   
    [self.overlayFormView addSubview:chooseButton];
    
    
    self.submitSuccessView.alpha = 0.0;
    validationErrors = [[NSHashTable alloc] init];
    defaultValidationMsg = @"";
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: defaultValidationMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    [self hideTimePickerView];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/d/yyyy"];
    
    // event title
    UIFont *textFieldFont = [UIFont fontWithName:FONT_GLOBAL size:18.0f];
    self.titleTextField.placeholder = @"Title";
    self.titleTextField.delegate = self;
    self.titleTextField.tag = kTextFieldEventTitle;
    self.titleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.titleTextField.clearsOnBeginEditing = NO;
    self.titleTextField.font = textFieldFont;
    self.titleTextField.textColor = [UIColor blackColor];
    self.titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    // location
    self.locationTextField.placeholder = @"Location";
    self.locationTextField.delegate = self;
    self.locationTextField.tag = kTextFieldEventLocation;
    self.locationTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.locationTextField.clearsOnBeginEditing = NO;
    self.locationTextField.font = textFieldFont;
    self.locationTextField.textColor = [UIColor blackColor];
    self.locationTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    // date
    self.dateTextField.placeholder = @"MM/DD/YYYY";
    self.dateTextField.tag = kTextFieldEventDate;
    self.dateTextField.delegate = self;
    self.dateTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.dateTextField.userInteractionEnabled = YES;
    self.dateTextField.clearsOnBeginEditing = NO;
    self.dateTextField.font = textFieldFont;
    self.dateTextField.textColor = [UIColor blackColor];
    // time
    self.timeTextField.placeholder = @"Time";
    self.timeTextField.tag = kTextFieldEventTime;
    self.timeTextField.delegate = self;
    self.timeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.timeTextField.userInteractionEnabled = YES;
    self.timeTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    self.timeTextField.clearsOnBeginEditing = NO;
    self.timeTextField.font = textFieldFont;
    self.timeTextField.textColor = [UIColor blackColor];
    
    // info
    self.eventInfoTextView.tag = kTextViewEventInfo;
    self.eventInfoTextView.delegate = self;
    self.eventInfoTextView.secureTextEntry = NO;
    self.eventInfoTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.eventInfoTextView.font = [UIFont fontWithName:FONT_GLOBAL size:12.0f];
    self.eventInfoTextView.textColor = [UIColor blackColor];
    self.eventInfoTextView.backgroundColor = [UIColor clearColor];
    self.eventInfoTextView.returnKeyType = UIReturnKeyDone;
    self.eventInfoTextView.text = @"Event Information";
    
    // TODO: add later, fix counter issue.info counter
    infoCounter = [[UILabel alloc] initWithFrame:CGRectMake(260, 269, 100, 20)];
    infoCounter.backgroundColor = [UIColor clearColor];
    infoCounter.textColor = [UIColor whiteColor];
    infoCounter.font = [UIFont fontWithName:FONT_GLOBAL size:10.0f];
    infoCounter.text = @"750";
  //  [self.view addSubview:infoCounter];
    
    timePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-216, 320, 216)];
    timePickerView.dataSource = self;
    timePickerView.delegate = self;
    timePickerView.showsSelectionIndicator = YES;
    timePickerView.alpha = ALPHA_ZERO;
    [self.view addSubview:timePickerView];
    
    // create bg label for modal
    modalOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 1000)];
    modalOverlay.backgroundColor = [UIColor blackColor];
    modalOverlay.alpha = 0.6;
    // create floating location text box bg
    locTextImageBg = [[UIImageView alloc] initWithFrame:CGRectMake(30, 150, 245, 47)];
    locTextImageBg.image = [UIImage imageNamed:@"ulink_mobile_input_field"];
    floatLocFrame = CGRectMake(38, 150, 229, 47);
}

- (void)viewDidAppear:(BOOL)animated {
    self.navBar.alpha = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideTimePickerView {
    timePickListVisible = FALSE;
    timePickerView.alpha = ALPHA_ZERO;
}
- (void)showTimePickerView {
    timePickListVisible = TRUE;
    CGRect frame = timePickerView.frame;
    frame.origin.y = (self.view.bounds.origin.y+self.view.frame.size.height)-216;
    timePickerView.frame = frame;
    timePickerView.alpha = ALPHA_HIGH;
}

- (void) rehydrateEventCaches {
    [UDataCache rehydrateSessionUser];
}

#pragma mark Image Processing section
-(void) takePhoto:(id) sender {
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void) choosePhoto:(id)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // set the image on the preview image view and show the image view
    if (previewPhotoView == nil) {
        previewPhotoView = [[PreviewPhotoView alloc]initWithFrame:CGRectMake(682.5f, 4, 235, 110)];
    }
    
    previewPhotoView.previewImageView.image = image;
    [previewPhotoView showPreviewPhoto:self.overlayFormView];
    [self dismissViewControllerAnimated:NO completion:^{
        // initialize the aviary filter gallery
        photoEditorController = [[AFPhotoEditorController alloc] initWithImage:previewPhotoView.previewImageView.image];
        [AFPhotoEditorCustomization setOptionValue:[UIColor colorWithRed:35.0f / 255.0f green:85.0f / 255.0f blue:100.0f / 255.0f alpha:1.0f] forKey:@"editor.accentColor"];
        [AFPhotoEditorCustomization setOptionValue:@"Submit" forKey:@"editor"];
        
        [photoEditorController setDelegate:self];
        [self presentViewController:photoEditorController animated:YES completion:nil];
    }];
    [self.view endEditing:YES];
}

#pragma mark

#pragma mark UIPickerView Section
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [UDataCache.times count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [UDataCache.times objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.timeTextField.text = [UDataCache.times objectAtIndex:row];
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
        case kTextFieldEventTitle: {
            if (titleTextField.text.length < 1) {
                [validationErrors addObject:@"\nPlease enter your event title"];
            }else {
                [validationErrors removeObject:@"\nPlease enter your event title"];
            }
        }
            break;
        case kTextFieldEventDate:
        {
            if (![UTextUtil validEventDateFormat:self.dateTextField.text]) {
                [validationErrors addObject:@"\nThe event date must be in MM/DD/YYYY format"];
            } else {
                [validationErrors removeObject:@"\nThe event date must be in MM/DD/YYYY format"];
            }
        }
            break;
        case kTextViewEventInfo: {
            if (eventInfoTextView.text.length < 2 || [self.eventInfoTextView.text isEqualToString:@"Event Information"]) {
                [validationErrors addObject:@"\nPlease enter your event information"];
            } else {
                [validationErrors removeObject:@"\nPlease enter your event information"];
            }
        }
            break;
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if([touch view] != self.timeTextField) {
        if(timePickListVisible) {
            [self hideTimePickerView];
        }
    }
    if ([self.titleTextField isFirstResponder] && [touch view] != self.titleTextField) {
        [self.titleTextField  resignFirstResponder];
    } else if ([self.dateTextField isFirstResponder] && [touch view] != self.dateTextField) {
        [self.dateTextField  resignFirstResponder];
    } else if ([self.eventInfoTextView isFirstResponder] && [touch view] != self.eventInfoTextView) {
        [self.eventInfoTextView  resignFirstResponder];
    }else if ([self.locationTextField isFirstResponder] && [touch view] != self.locationTextField) {
        [self.locationTextField  resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if(timePickListVisible) {
        [self hideTimePickerView];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL retVal = YES;
    if(textField.tag == kTextFieldEventTime) {
        if(!timePickListVisible) {
            [self showTimePickerView];
        }
        if ([self.titleTextField isFirstResponder]) {
            [self.titleTextField  resignFirstResponder];
        } else if ([self.locationTextField isFirstResponder]) {
            [self.locationTextField  resignFirstResponder];
        } else if ([self.eventInfoTextView isFirstResponder]) {
            [self.eventInfoTextView resignFirstResponder];
        } else if ([self.dateTextField isFirstResponder]) {
            [self.dateTextField  resignFirstResponder];
        }
        retVal = NO;
    } else {
        if(timePickListVisible) {
            [self hideTimePickerView];
        }
        if(textField.tag == kTextFieldEventLocation && !floatLocationVisible) {
            [self.locationTextField removeFromSuperview];
            self.locationTextField.frame = floatLocFrame;
            [self.view addSubview:modalOverlay];
            [self.view addSubview:locTextImageBg];
            [self.view addSubview:self.locationTextField];
            floatLocationVisible = TRUE;
        }
    }
    
    return retVal;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if(timePickListVisible) {
        [self hideTimePickerView];
    }
    if ([self.eventInfoTextView.text isEqualToString:@"Event Information"]) {
        self.eventInfoTextView.text = @"";
    }
    return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldEventTitle: [self validateField:kTextFieldEventTitle];
            break;
        case kTextFieldEventDate: [self validateField:kTextFieldEventDate];
            break;
        case kTextFieldEventLocation: {
            floatLocationVisible = FALSE;
            [modalOverlay removeFromSuperview];
            [locTextImageBg removeFromSuperview];
            [self.locationTextField removeFromSuperview];
            self.locationTextField.frame = CGRectMake(45, 34, 229, 47);
            [self.overlayFormView addSubview:self.locationTextField];
        }
            break;
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [self validateField:kTextViewEventInfo];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL retVal = NO;
    BOOL useIncrementedLength = NO;
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    if([text isEqualToString:@""]) {
        retVal = YES;
    } else {
        retVal = self.eventInfoTextView.text.length < 751;
        useIncrementedLength = YES;
    }
   /* if(retVal) {
        if(self.eventInfoTextView.text.length > 600 && self.eventInfoTextView.text.length < 675) {
            infoCounter.textColor = [UIColor orangeColor];
        } else if (self.eventInfoTextView.text.length > 675) {
            infoCounter.textColor = [UIColor redColor];
        } else {
            infoCounter.textColor = [UIColor whiteColor];
        }
        if(useIncrementedLength) {
        infoCounter.text = [NSString stringWithFormat:@"%i", 750-(self.eventInfoTextView.text.length+1)];
        } else {
           infoCounter.text = [NSString stringWithFormat:@"%i", 750-(self.eventInfoTextView.text.length)]; 
        }
    } else {
        infoCounter.text = [NSString stringWithFormat:@"%i", 750-(self.eventInfoTextView.text.length-1)];
    }*/
    return retVal;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL retVal = NO;
    if([string isEqualToString:@""]) {
        retVal = YES;
    } else {
        if (textField.tag == kTextFieldEventDate) {
            retVal = textField.text.length < 10;
        } else {
            retVal = textField.text.length < 51;
        }
    }
    return retVal;
}

#pragma mark Aviary Image Section
- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image {
    [photoEditorController dismissViewControllerAnimated:NO completion:nil];
    previewPhotoView.previewImageView.image = image;
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor {
    [photoEditorController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark

#pragma mark Actions
- (IBAction)cancelClick:(UIBarButtonItem *)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cameraClick:(UIButton *)sender {
    [self.view endEditing:YES];
    if(timePickListVisible) {
        [self hideTimePickerView];
    }
    float newX = self.lowerOverlay.frame.origin.x;
    float overlayFormX = self.overlayFormView.frame.origin.x;
    if(overlayPosition == TimeActive) {
            newX -= 103.0f;
        overlayFormX -=320.0f;
    } else if(overlayPosition == LocationActive) {
        newX -= 210.0f;
        overlayFormX -=640.0f;
    }
    
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = self.lowerOverlay.frame;
                         frame.origin.x = newX;
                         self.lowerOverlay.frame = frame;
                         CGRect frame2 = self.overlayFormView.frame;
                         frame2.origin.x = overlayFormX;
                         self.overlayFormView.frame = frame2;
                     }
                     completion:nil];
   overlayPosition = CameraActive;
}

- (IBAction)timeClick:(UIButton *)sender {
    [self.view endEditing:YES];
    if(timePickListVisible) {
        [self hideTimePickerView];
    }
    float newX = self.lowerOverlay.frame.origin.x;
    float overlayFormX = self.overlayFormView.frame.origin.x;
    if(overlayPosition == CameraActive) {
        newX += 103.0f;
        overlayFormX +=320.0f;
    } else if(overlayPosition == LocationActive) {
        newX -= 106.0f;
        overlayFormX -=320.0f;
    }
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = self.lowerOverlay.frame;
                         frame.origin.x = newX;
                         self.lowerOverlay.frame = frame;
                         CGRect frame2 = self.overlayFormView.frame;
                         frame2.origin.x = overlayFormX;
                         self.overlayFormView.frame = frame2;
                     }
                     completion:nil];
    overlayPosition = (LowerOverlayPosition)TimeActive;
}

- (IBAction)locationClick:(UIButton *)sender {
    [self.view endEditing:YES];
    if(timePickListVisible) {
        [self hideTimePickerView];
    }
    float newX = self.lowerOverlay.frame.origin.x;
    float overlayFormX = self.overlayFormView.frame.origin.x;
    if(overlayPosition == TimeActive) {
        newX += 106.0f;
        overlayFormX +=320.0f;
    } else if(overlayPosition == CameraActive) {
        newX += 210.0f;
        overlayFormX +=640.0f;
    }
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = self.lowerOverlay.frame;
                         frame.origin.x = newX;
                         self.lowerOverlay.frame = frame;
                         CGRect frame2 = self.overlayFormView.frame;
                         frame2.origin.x = overlayFormX;
                         self.overlayFormView.frame = frame2;
                     }
                     completion:nil];
    overlayPosition = LocationActive;
}
- (IBAction)submitClick:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    if(timePickListVisible) {
        [self hideTimePickerView];
    }
    @try {
        [self validateField:kTextFieldEventDate];
        [self validateField:kTextFieldEventTitle];
        [self validateField:kTextViewEventInfo];
        if([validationErrors count] > 0) {
            errorAlertView.message = @"";
            for (NSString *error in validationErrors) {
                errorAlertView.message = [errorAlertView.message stringByAppendingString:error];
            }
            [errorAlertView show];
            return;
        }
        
        [activityIndicator showActivityIndicator:self.view];
        self.rightNavItem.enabled = FALSE;
        
        NSMutableURLRequest *req = [self buildDataRequest];
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
                    
                    NSString* result = (NSString*)[json objectForKey:JSON_KEY_RESULT];
                    if([result isEqualToString:@"true"]) {
                        // for now we will just rehyrdate the snap data
                        [self performSelectorInBackground:@selector(rehydrateEventCaches) withObject:self];
                        // build new event object and set in user session cache
                    /*  TODO: implement once we can retrieve the id after an insert
                     
                        NSDictionary *eventData = [[json objectForKey:JSON_KEY_RESPONSE] objectForKey:@"eventdata"];
                        Event *event = [[Event alloc] init];
                        event.time = self.timeTextField.text;
                        event.title = self.titleTextField.text;
                        event.information = self.eventInfoTextView.text;
                        event.date = [dateFormatter dateFromString:self.dateTextField.text];
                        event.clearDate = [UEventUtil getClearDate:event.date];
                        event.location = self.locationTextField.text;
                        event.image = previewPhotoView.previewImageView.image;
                        event.imageURL = [eventData objectForKey:@"imageURL"];
                        event.eventId = [eventData objectForKey:@"_id"];
                        
                        // add the updated event back to the cache
                        [UDataCache.sessionUser.events addObject:event];
                     
                     */
                        
                        self.navBar.alpha = 1;
                        self.submitSuccessView.alpha = 1.0;
                        self.leftNavItem.style = UIBarButtonItemStyleDone;
                        self.leftNavItem.title = @"Done";
                        self.rightNavItem.enabled = NO;
                    } else {
                        NSString *response = (NSString*)[json objectForKey:JSON_KEY_RESPONSE];
                        if (response != nil) {
                            // remove HTML line breaks from response
                            NSString *filteredResponse = [response stringByReplacingOccurrencesOfString: @"<br />" withString:@"\n"];
                            errorAlertView.message = filteredResponse;
                        } else {
                            errorAlertView.message = @"There was a problem submitting your event.  Please try again later or contact help@theulink.com.";
                        }
                        [errorAlertView show];
                        self.rightNavItem.enabled = TRUE;
                    }
                } else {
                    errorAlertView.message = @"There was a problem submitting your event.  Please try again later or contact help@theulink.com.";
                    // show alert to user
                    [errorAlertView show];
                    self.rightNavItem.enabled = TRUE;
                }
            });
        }];
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        // show alert to user
        [errorAlertView show];
        self.rightNavItem.enabled = TRUE;
    }
}

- (NSMutableURLRequest*) buildDataRequest {    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_EVENTS_INSERT_EVENT]]];
    [req setHTTPMethod:HTTP_POST];
    [req setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [req setHTTPShouldHandleCookies:NO];
    [req setTimeoutInterval:30];
    
    // just some random text that will never occur in the body
    NSString *stringBoundary = @"0xKhTmLbOuNdArY---This_Is_ThE_BoUnDaRyy---pqo";
    
    // header value
    NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",
                                stringBoundary];
    
    // set header
    [req addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
    
    //add body
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[Event][eventTitle]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", self.titleTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[Event][eventDate]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", self.dateTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[Event][eventInfo]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", self.eventInfoTextView.text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[Event][eventLocation]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", self.locationTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[Event][eventTime]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", self.timeTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"mobile_auth"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", @"yes"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"user_id"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", UDataCache.sessionUser.userId] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"school_id"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", UDataCache.sessionUser.schoolId] dataUsingEncoding:NSUTF8StringEncoding]];
    /*
     * This is a kind of work around for now,
     * but if the choose and take photos are disabled,
     * we know there is an image to POST to the API.
     */
    if((takePhotoButton != nil || takePhotoButton.enabled == NO) && chooseButton.enabled == NO) {
        if (previewPhotoView.previewImageView.image != nil) {
            // add image as event image data, and make sure it's compressed
            NSData *imageData = [UImageUtil compressImageToData:previewPhotoView.previewImageView.image];
            if (imageData) {
                [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
                NSString *imageName = @"event";
                imageName = [imageName stringByAppendingFormat:@"%@ %i.jpg\"\r\n",UDataCache.sessionUser.userId, UDataCache.sessionUser.events.count];
                NSString *imageParamData = [@"Content-Disposition: form-data; name=\"data[Event][image]\"; filename=\"" stringByAppendingString:imageName];
                [postBody appendData:[imageParamData dataUsingEncoding:NSUTF8StringEncoding]];
                [postBody appendData:[@"Content-Type: image/jpeg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            // add it to body
            [postBody appendData:imageData];
            [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
       
    // final boundary
    [postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [postBody length]];
    [req setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // add body to post
    [req setHTTPBody:postBody];
    return req;
}
#pragma mark
@end
