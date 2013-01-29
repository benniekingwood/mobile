//
//  EditEventViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/13/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "EditEventViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AlertView.h"
#import "ActivityIndicatorView.h"
#import "SuccessNotificationView.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "TextUtil.h"
#import "EventUtil.h"
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import "ImageUtil.h"
@interface EditEventViewController () {
    AlertView *errorAlertView;
    AlertView *customAlertView;
    NSString *defaulValidationMsg;
    NSHashTable *validationErrors;
    BOOL timePickListVisible;
    ActivityIndicatorView *activityIndicator;
    SuccessNotificationView *successNotification;
    NSString *defaultValidationMsg;
    NSDateFormatter *dateFormatter;
    CGPoint svos;
    UIPickerView *timePickerView;
    UIButton *eventPictureButton;
    UIImagePickerController *imagePicker;
    UIActionSheet *photoActionSheet;
    BOOL imageChanged;
}
-(void)showValidationErrors;
-(void)validateField:(int)tag;
- (void) singleTapGestureCaptured:(UITapGestureRecognizer*)gesture;
- (void) deleteEvent;
- (void) popController;
- (void)showActionSheet:(id)sender;
- (NSMutableURLRequest*) buildDataRequest;
@end

@implementation EditEventViewController
@synthesize formView, scrollView,deleteButton, event, saveButton;
@synthesize timeTextField, titleTextField, locationTextField, eventInfoTextView, dateTextField;
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
    validationErrors = [[NSHashTable alloc] init];
	customAlertView = [[AlertView alloc] initWithTitle:@""
                                               message:@"Are you sure you would like delete this event?  This action cannot be undone."
                                              delegate:self
                                     cancelButtonTitle:BTN_CANCEL
                                     otherButtonTitles:BTN_DELETE,nil];
    defaultValidationMsg = @"";
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: defaultValidationMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    successNotification = [[SuccessNotificationView alloc] init];
    [deleteButton createRedButton:deleteButton];
    [successNotification setMessage:@"Event Updated."];
    self.saveButton.enabled = FALSE;
    [self hideTimePickerView];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/d/yyyy"];
    
    // event picture
    eventPictureButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 16, 106, 78)];
    eventPictureButton.layer.cornerRadius = 5;
    eventPictureButton.layer.masksToBounds = YES;
    eventPictureButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [eventPictureButton addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    [formView addSubview:eventPictureButton];
    
    // scroll view
    self.scrollView.contentSize = formView.frame.size;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self.scrollView addSubview:formView];
    
    // event title
    UIFont *textFieldFont = [UIFont fontWithName:FONT_GLOBAL size:18.0f];
    self.titleTextField.placeholder = @"Title";
    self.titleTextField.delegate = self;
    self.titleTextField.tag = kTextFieldEventTitle;
    self.titleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.titleTextField.clearsOnBeginEditing = NO;
    self.titleTextField.font = textFieldFont;
    self.titleTextField.textColor = [UIColor blackColor];
    
    // location
    self.locationTextField.placeholder = @"Location";
    self.locationTextField.delegate = self;
    self.locationTextField.tag = kTextFieldEventLocation;
    self.locationTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.locationTextField.clearsOnBeginEditing = NO;
    self.locationTextField.font = textFieldFont;
    self.locationTextField.textColor = [UIColor blackColor];
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
    
    timePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-216, 320, 216)];
    timePickerView.dataSource = self;
    timePickerView.delegate = self;
    timePickerView.showsSelectionIndicator = YES;
    timePickerView.alpha = ALPHA_ZERO;
    [self.view addSubview:timePickerView];
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        photoActionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:BTN_CANCEL
                       destructiveButtonTitle:nil
                       otherButtonTitles:BTN_TAKE_PHOTO, BTN_CHOOSE_PHOTO, nil];
    } else {
        photoActionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:BTN_CANCEL
                       destructiveButtonTitle:nil
                       otherButtonTitles:BTN_CHOOSE_PHOTO, nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated {
    self.titleTextField.text = self.event.title;
    self.timeTextField.text = self.event.time;
    self.dateTextField.text = [dateFormatter stringFromDate:self.event.date];
    self.locationTextField.text = self.event.location;
    self.eventInfoTextView.text = self.event.information;
    [eventPictureButton setImage:self.event.image forState:UIControlStateNormal];
    // grab the event image from the event cache
    UIImage *eventImage = [UDataCache imageExists:self.event.eventId cacheModel:IMAGE_CACHE_EVENT_MEDIUM];
    if (eventImage == nil) {
        if(self.event.imageURL != nil) {
        // set the key in the cache to let other processes know that this key is in work
        [UDataCache.eventImageMedium setValue:[NSNull null]  forKey:self.event.eventId];
        NSURL *url = [NSURL URLWithString:[URL_EVENT_IMAGE_MEDIUM stringByAppendingString:self.event.imageURL]];
        __block ImageActivityIndicatorView *iActivityIndicator;
        SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
        [imageDownloader downloadImageWithURL:url
                                      options:SDWebImageDownloaderProgressiveDownload
                                     progress:^(NSUInteger receivedSize, long long expectedSize) {
                                         if (!iActivityIndicator)
                                         {
                                             iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
                                             [iActivityIndicator showActivityIndicator:eventPictureButton.imageView];
                                             eventPictureButton.userInteractionEnabled = NO;
                                         }
                                     }
                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                        if (image && finished)
                                        {
                                            // add the event image to the image cache
                                            [UDataCache.eventImageMedium setValue:image forKey:self.event.eventId];
                                            // set the picture in the view
                                            [eventPictureButton setImage:image forState:UIControlStateNormal];
                                            [iActivityIndicator hideActivityIndicator:eventPictureButton.imageView];
                                            iActivityIndicator = nil;
                                            eventPictureButton.userInteractionEnabled = YES;
                                        }
                                    }];
        }
    } else if (![eventImage isKindOfClass:[NSNull class]]){
        [eventPictureButton setImage:eventImage forState:UIControlStateNormal];
    }
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

- (void)showActionSheet:(id)sender {
    [photoActionSheet showInView:self.view];
}

#pragma mark UIActionSheet Section
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:BTN_TAKE_PHOTO]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else if ([buttonTitle isEqualToString:BTN_CHOOSE_PHOTO]) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}
#pragma mark
#pragma mark UIImagePickerView Section
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [eventPictureButton setImage:image forState:UIControlStateNormal];
    imageChanged = TRUE;
    self.saveButton.enabled = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
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
    self.saveButton.enabled = TRUE;
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
            if (eventInfoTextView.text.length < 1) {
                [validationErrors addObject:@"\nPlease enter your event information"];
            } else {
                [validationErrors removeObject:@"\nPlease enter your event information"];
            }
        }
        break;
    }
    
}
- (void) singleTapGestureCaptured:(UITapGestureRecognizer*)gesture {
    CGPoint touchPoint = [gesture locationInView:self.scrollView];
    if ([self.titleTextField isFirstResponder] && !CGRectContainsPoint(self.titleTextField.frame, touchPoint)) {
        [self.titleTextField resignFirstResponder];
    } else if ([self.dateTextField isFirstResponder] && !CGRectContainsPoint(self.dateTextField.frame, touchPoint)) {
        [self.dateTextField  resignFirstResponder];
    } else if ([self.eventInfoTextView isFirstResponder] && !CGRectContainsPoint(self.eventInfoTextView.frame, touchPoint)) {
        [self.eventInfoTextView  resignFirstResponder];
    } else if ([self.locationTextField isFirstResponder] && !CGRectContainsPoint(self.locationTextField.frame, touchPoint)) {
        [self.locationTextField  resignFirstResponder];
    } 
    
    if(!CGRectContainsPoint(timeTextField.frame, touchPoint)) {
        if(timePickListVisible) {
            [self hideTimePickerView];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if(timePickListVisible) {
        [self hideTimePickerView];
    }
    [self.scrollView setContentOffset:svos animated:YES];
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
    }
    
    return retVal;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    svos = self.scrollView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:self.scrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    [self.scrollView setContentOffset:pt animated:YES];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self.scrollView setContentOffset:CGPointMake(0, 200) animated:YES];
    if(timePickListVisible) {
        [self hideTimePickerView];
    }
    return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldEventTitle: [self validateField:kTextFieldEventTitle];
            break;
        case kTextFieldEventDate: [self validateField:kTextFieldEventDate];
            break;
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [self validateField:kTextViewEventInfo];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL retVal = NO;
    self.saveButton.enabled = TRUE;
    if([text isEqualToString:@"\n"]) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [textView resignFirstResponder];
    }
    if([text isEqualToString:@""]) {
        retVal = YES;
    } else {
        retVal = self.eventInfoTextView.text.length < 751;
    }
    return retVal;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL retVal = NO;
    self.saveButton.enabled = TRUE;
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        [self deleteEvent];
    }
}

- (void) popController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) deleteEvent {
    @try {
        [activityIndicator showActivityIndicator:self.view];
        deleteButton.enabled = FALSE;
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t deleteEventQueue = dispatch_queue_create(DISPATCH_DELETE_EVENT, NULL);
        dispatch_async(deleteEventQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_EVENTS_DELETE_EVENT];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:event.eventId];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.userId];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.userId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
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
                            [successNotification setMessage:@"Event Deleted."];
                            [successNotification showNotification:self.view];
                            // delete snapshot from the event cache
                            [UDataCache.sessionUser.events removeObject:event];
                            // remove the old event image since it changed
                            [UDataCache removeImage:event.eventId cacheModel:IMAGE_CACHE_EVENT_MEDIUM];
                            [UDataCache removeImage:event.eventId cacheModel:IMAGE_CACHE_EVENT_THUMBS];
                            // pop the controller
                            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(popController) userInfo:nil repeats:NO];
                        } else {
                            self.deleteButton.enabled = TRUE;
                            if (response != nil && [response isEqualToString:@""] ) {
                                errorAlertView.message = response;
                            } else {
                                errorAlertView.message = @"There was a problem deleting your snapshot.  Please try again later or contact help@theulink.com.";
                            }
                            [errorAlertView show];
                        }
                    } else {
                        self.deleteButton.enabled = TRUE;
                        errorAlertView.message = @"There was a problem deleting your snapshot.  Please try again later or contact help@theulink.com.";
                        // show alert to user
                        [errorAlertView show];
                    }
                });
            }];
        });
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        deleteButton.enabled = TRUE;
        // show alert to user
        [errorAlertView show];
    }
}

- (NSMutableURLRequest*) buildDataRequest {
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_EVENTS_UPDATE_EVENT]]];
    [req setHTTPMethod:HTTP_POST];
    [req setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [req setHTTPShouldHandleCookies:NO];
    [req setTimeoutInterval:11];
    
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
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[Event][eventTime]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", self.timeTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"mobile_auth"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", @"yes"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[Event][imageURL]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", self.event.imageURL] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[Event][_id]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", self.event.eventId] dataUsingEncoding:NSUTF8StringEncoding]];
    /*
     * If the image changed we will add 
     * it to POST to the API.
     */
    if(imageChanged) {
        if (eventPictureButton.imageView.image != nil) {
            // add image as event image data
            NSData *imageData = [UImageUtil compressImageToData:eventPictureButton.imageView.image];
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

#pragma mark Actions
- (IBAction)deleteEventClick:(id)sender {
     [customAlertView show];
}

- (IBAction)saveClick:(id)sender {
    [self.view endEditing:YES];
    [self.scrollView setContentOffset:svos animated:YES];
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
        self.saveButton.enabled = FALSE;

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
                        // remove event from cache
                        [UDataCache.sessionUser.events removeObject:self.event];
                        
                        // update the event object with new data
                        self.event.time = self.timeTextField.text;
                        self.event.title = self.titleTextField.text;
                        self.event.information = self.eventInfoTextView.text;
                        self.event.date = [dateFormatter dateFromString:self.dateTextField.text];
                        self.event.clearDate = [UEventUtil getClearDate:self.event.date];
                        self.event.location = self.locationTextField.text;
                        if(imageChanged) {
                            self.event.image = eventPictureButton.imageView.image;
                            NSDictionary *response = [json objectForKey:JSON_KEY_RESPONSE];
                            self.event.imageURL = [[response objectForKey:@"eventdata"] objectForKey:@"imageURL"];
                            // remove the old event image since it changed
                            [UDataCache removeImage:self.event.eventId cacheModel:IMAGE_CACHE_EVENT_MEDIUM];
                            [UDataCache removeImage:self.event.eventId cacheModel:IMAGE_CACHE_EVENT_THUMBS];
                        }
                       
                        // add the updated event back to the cache
                        [UDataCache.sessionUser.events addObject:self.event];
                        [successNotification showNotification:self.view];
                    } else {
                        NSString *response = (NSString*)[json objectForKey:JSON_KEY_RESPONSE];
                        if (response != nil) {
                            // remove HTML line breaks from response
                            NSString *filteredResponse = [response stringByReplacingOccurrencesOfString: @"<br />" withString:@"\n"];
                            errorAlertView.message = filteredResponse;
                        } else {
                            errorAlertView.message = @"There was a problem updating your event.  Please try again later or contact help@theulink.com.";
                        }
                        [errorAlertView show];
                        self.saveButton.enabled = TRUE;
                    }
                } else { 
                   errorAlertView.message = @"There was a problem updating your event.  Please try again later or contact help@theulink.com.";
                    // show alert to user
                    [errorAlertView show];
                    self.saveButton.enabled = TRUE;
                } 
           });
        }];
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        // show alert to user
        [errorAlertView show];
        self.saveButton.enabled = TRUE;
    }
}
#pragma mark
@end
