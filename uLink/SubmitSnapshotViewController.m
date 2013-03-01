//
//  SubmitSnapshotViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 12/3/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SubmitSnapshotViewController.h"
#import "AlertView.h"
#import "ActivityIndicatorView.h"
#import "SuccessNotificationView.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "TextUtil.h"
#import "EventUtil.h"
#import "PreviewPhotoView.h"
#import "SnapshotCategory.h"
#import "ImageUtil.h"
@interface SubmitSnapshotViewController () {
    AlertView *errorAlertView;
    AlertView *customAlertView;
    NSString *defaulValidationMsg;
    NSHashTable *validationErrors;
    BOOL categoryPickListVisible;
    ActivityIndicatorView *activityIndicator;
    NSString *defaultValidationMsg;
    UIPickerView *categoryPickerView;
    UIImagePickerController *imagePicker;
    PreviewPhotoView *previewPhotoView;
    UlinkButton *takePhotoButton;
    UlinkButton *chooseButton;
    AFPhotoEditorController *photoEditorController;
    NSString *selectedCategoryId;
    NSMutableArray *categories;
    SnapshotCategory *blank;
}
-(void)showValidationErrors;
- (void)hideCategoryPickerView;
-(void)validateField:(int)tag;
- (NSMutableURLRequest*) buildDataRequest;
- (void)showTimePickerView;
- (void) submitSnap;
- (void) rehydrateSnapCaches;
@end

@implementation SubmitSnapshotViewController
@synthesize takePhotoButton,chooseButton, dismissImmediately, photoPlaceHolderView, captionTextView, categoryTextField, nextButton, cancelButton, submitSuccessView;
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
     self.submitSuccessView.alpha = 0.0;
    if(dismissImmediately) {
       [self dismissViewControllerAnimated:NO completion:nil];
    }
    categories = [[NSMutableArray alloc] init];
    blank = [[SnapshotCategory alloc] init];
    blank.name = @"";
    blank.snapCategoryId = @"";
    // insert a blank category for the picklist
    [categories insertObject:blank atIndex:0];
    
    // add the snapshot categories to list for the picklist
    for (SnapshotCategory *cat in [UDataCache.snapshotCategories allValues]) {
        [categories addObject:cat];
    }

    // initially keep the next button disabled until an image is uploaded
    self.nextButton.enabled = NO;
    self.navigationItem.title = @"Submit Snap";
    self.view.backgroundColor = [UIColor colorWithRed:142.0f / 255.0f green:142.0f / 255.0f blue:142.0f / 255.0f alpha:1.0f];
    
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
        takePhotoButton.frame = CGRectMake(45, 328, 230, 30);
        chooseButton.frame = CGRectMake(45, 365, 230, 30);
        [self.view addSubview:takePhotoButton];
    } else {
        chooseButton.frame = CGRectMake(45, 365, 230, 30);
    }
    
    [self.view addSubview:chooseButton];
    
    validationErrors = [[NSHashTable alloc] init];
    defaultValidationMsg = @"";
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: defaultValidationMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    [self hideCategoryPickerView];
    
    // category
    self.categoryTextField.placeholder = @"Category";
    self.categoryTextField.tag = kTextFieldSnapCategory;
    self.categoryTextField.delegate = self;
    self.categoryTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.categoryTextField.userInteractionEnabled = YES;
    self.categoryTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    self.categoryTextField.clearsOnBeginEditing = NO;
    self.categoryTextField.font = [UIFont fontWithName:FONT_GLOBAL size:18.0f];
    self.categoryTextField.textColor = [UIColor blackColor];
    
    // caption
    self.captionTextView.tag = kTextViewSnapCaption;
    self.captionTextView.delegate = self;
    self.captionTextView.secureTextEntry = NO;
    self.captionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.captionTextView.font = [UIFont fontWithName:FONT_GLOBAL size:12.0f];
    self.captionTextView.textColor = [UIColor blackColor];
    self.captionTextView.backgroundColor = [UIColor clearColor];
    self.captionTextView.returnKeyType = UIReturnKeyDone;
    self.captionTextView.text = @"Snap Caption";
    
    categoryPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-216, 320, 216)];
    categoryPickerView.dataSource = self;
    categoryPickerView.delegate = self;
    categoryPickerView.showsSelectionIndicator = YES;
    categoryPickerView.alpha = ALPHA_ZERO;
    [self.view addSubview:categoryPickerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideCategoryPickerView {
    categoryPickListVisible = FALSE;
    categoryPickerView.alpha = ALPHA_ZERO;
}
- (void)showTimePickerView {
    categoryPickListVisible = TRUE;
    CGRect frame = categoryPickerView.frame;
    frame.origin.y = (self.view.bounds.origin.y+self.view.frame.size.height)-216;
    categoryPickerView.frame = frame;
    categoryPickerView.alpha = ALPHA_HIGH;
    [categoryPickerView removeFromSuperview];
    [self.view addSubview:categoryPickerView];
}

- (void) rehydrateSnapCaches {
    [UDataCache rehydrateSessionUser];
    [UDataCache rehydrateSnapshotsCache:NO];
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
        previewPhotoView = [[PreviewPhotoView alloc]initWithFrame:CGRectMake(42.5f, 223, 235, 190)];
    }
    previewPhotoView.previewImageView.image = image;
    [previewPhotoView showPreviewPhoto:self.view];
    // enable the next button now
    self.nextButton.enabled = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark

#pragma mark UIPickerView Section
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [categories count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    SnapshotCategory *category = [categories objectAtIndex:row];
    return category.name;
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    SnapshotCategory *category = [categories objectAtIndex:row];
    self.categoryTextField.text = category.name;
    selectedCategoryId = category.snapCategoryId;
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
        case kTextFieldSnapCategory: {
            if (self.categoryTextField.text.length < 1) {
                [validationErrors addObject:@"\nPlease select a snap category"];
            }else {
                [validationErrors removeObject:@"\nPlease select a snap category"];
            }
        }
            break;
        case kTextViewSnapCaption: {
            if (self.captionTextView.text.length < 1 || [self.captionTextView.text isEqualToString:@"Snap Caption"]) {
                [validationErrors addObject:@"\nPlease enter your snap caption"];
            } else {
                [validationErrors removeObject:@"\nPlease enter your snap caption"];
            }
        }
            break;
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if([touch view] != self.categoryTextField) {
        if(categoryPickListVisible) {
            [self hideCategoryPickerView];
        }
    }
    if ([self.captionTextView isFirstResponder] && [touch view] != self.captionTextView) {
        [self.captionTextView  resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if(categoryPickListVisible) {
        [self hideCategoryPickerView];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL retVal = YES;
    if(textField.tag == kTextFieldSnapCategory) {
        if(!categoryPickListVisible) {
            [self showTimePickerView];
        }
        if ([self.captionTextView isFirstResponder]) {
            [self.captionTextView resignFirstResponder];
        } 
        retVal = NO;
    } else {
        if(categoryPickListVisible) {
            [self hideCategoryPickerView];
        }
    }
    
    return retVal;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if(categoryPickListVisible) {
        [self hideCategoryPickerView];
    }
    if ([self.captionTextView.text isEqualToString:@"Snap Caption"]) {
        self.captionTextView.text = @"";
    }
    return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldSnapCategory: [self validateField:kTextFieldEventTitle];
            break;
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [self validateField:kTextViewSnapCaption];
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
        retVal = self.captionTextView.text.length < 141;
        useIncrementedLength = YES;
    }
    return retVal;
}

- (NSMutableURLRequest*) buildDataRequest {
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_SNAPSHOTS_INSERT_SNAPSHOT]]];
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
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[Snapshot][category]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", selectedCategoryId] dataUsingEncoding:NSUTF8StringEncoding]];

    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[Snapshot][caption]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", self.captionTextView.text] dataUsingEncoding:NSUTF8StringEncoding]];
 
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
            // add image as snap image data, compressed
            NSData *imageData = [UImageUtil compressImageToData:previewPhotoView.previewImageView.image];
            if (imageData) {
                [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
                NSString *imageName = @"snap";
                imageName = [imageName stringByAppendingFormat:@"%@ %i-%@.jpg\"\r\n",UDataCache.sessionUser.userId, UDataCache.sessionUser.snaps.count, [UImageUtil generateRandomString:10]];
                NSString *imageParamData = [@"Content-Disposition: form-data; name=\"data[Snapshot][image]\"; filename=\"" stringByAppendingString:imageName];
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

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image {
   // previewPhotoView.previewImageView.image = image;
    [photoEditorController dismissViewControllerAnimated:NO completion:nil];
    previewPhotoView.previewImageView.image = image;
    // now peform the submission of the snapshot
    [self submitSnap];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor {
    [photoEditorController dismissViewControllerAnimated:YES completion:nil];
}

- (void) submitSnap {
    [self.view endEditing:YES];
    if(categoryPickListVisible) {
        [self hideCategoryPickerView];
    }
    @try {
        [activityIndicator showActivityIndicator:self.view];
        self.nextButton.enabled = FALSE;
        
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
                    
                    NSString* result = (NSString*)[json objectForKey:JSON_KEY_RESPONSE];
                    if([result isEqualToString:@"true"]) {
                        // for now we will just rehyrdate the snap data
                        [self performSelectorInBackground:@selector(rehydrateSnapCaches) withObject:self];
                        // build new snap object and set in user session cache
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
                         
                         // add the new snap back to the cache
                         [UDataCache.sessionUser.snap addObject:snap];
                         
                         */
                      //  previewPhotoView.previewImageView.alpha = ALPHA_ZERO;
                        //previewPhotoView.alpha = ALPHA_ZERO;
                        //[previewPhotoView.previewImageView removeFromSuperview];
                        [previewPhotoView hidePreviewPhoto];
                        [chooseButton removeFromSuperview];
                        [takePhotoButton removeFromSuperview];
                        self.submitSuccessView.alpha = 1.0;
                        self.cancelButton.style = UIBarButtonItemStyleDone;
                        self.cancelButton.title = @"Done";
                        self.nextButton.enabled = NO;
                    } else {
                        errorAlertView.message = @"There was a problem submitting your snap.  Please try again later or contact help@theulink.com.";
                        [errorAlertView show];
                        self.nextButton.enabled = TRUE;
                    }
                } else {
                    errorAlertView.message = @"There was a problem submitting your snap.  Please try again later or contact help@theulink.com.";
                    // show alert to user
                    [errorAlertView show];
                    self.nextButton.enabled = TRUE;
                }
            });
        }];
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        // show alert to user
        [errorAlertView show];
        self.nextButton.enabled = TRUE;
    }
}
#pragma mark Actions
- (IBAction)cancelClick:(UIBarButtonItem *)sender {
    // remove the blank snap category
    [UDataCache.snapshotCategories removeObjectForKey:@""];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)nextClick:(id)sender {
    // first perform validation before going to the filters screen
    [self validateField:kTextFieldSnapCategory];
    [self validateField:kTextViewSnapCaption];
    if(previewPhotoView.previewImageView.image == nil) {
        [validationErrors addObject:@"\nPlease add your photo"];
    } else {
        [validationErrors removeObject:@"\nPlease add your photo"];
    }
    if([validationErrors count] > 0) {
        errorAlertView.message = @"";
        for (NSString *error in validationErrors) {
            errorAlertView.message = [errorAlertView.message stringByAppendingString:error];
        }
        [errorAlertView show];
        return;
    }
    
    photoEditorController = [[AFPhotoEditorController alloc] initWithImage:previewPhotoView.previewImageView.image];
    [AFPhotoEditorCustomization setOptionValue:[UIColor colorWithRed:35.0f / 255.0f green:85.0f / 255.0f blue:100.0f / 255.0f alpha:1.0f] forKey:@"editor.accentColor"];
    [AFPhotoEditorCustomization setOptionValue:@"Submit" forKey:@"editor"];
    
    [photoEditorController setDelegate:self];
    [self presentViewController:photoEditorController animated:YES completion:nil];
}
#pragma mark
@end
