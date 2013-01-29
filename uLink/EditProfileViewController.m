//
//  EditProfileViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/13/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "EditProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ActivityIndicatorView.h"
#import "SuccessNotificationView.h"
#import "AlertView.h"
#import "AppMacros.h"
#import "TextUtil.h"
#import "DataCache.h"
#import "ProfileViewController.h"
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import "ImageUtil.h"
@interface EditProfileViewController () {
    AlertView *errorAlertView;
    NSString *defaulValidationMsg;
    TextUtil *textUtil;
    NSHashTable *validationErrors;
    NSArray *schoolStatuses;
    BOOL pickListVisible;
    ActivityIndicatorView *activityIndicator;
    SuccessNotificationView *successNotifiction;
    CGPoint svos;
    
    UIScrollView *scrollView;
    UILabel *userNameLabel;
    UILabel *schoolLabel;
    UITextField *firstNameTextField;
    UIImageView *firstNameImageView;
    UITextField *lastNameTextField;
    UIImageView *lastNameImageView;
    UITextView *bioTextView;
    UIImageView *bioImageView;
    UITextField *schoolStatusTextField;
    UIImageView *schoolStatusImageView;
    UITextField *yearTextField;
    UIImageView *yearImageView;
    UIPickerView *schoolStatusPickerView;
    
    UIButton *profilePictureButton;
    UIImagePickerController *imagePicker;
    UIActionSheet *photoActionSheet;
    BOOL imageChanged;
}
-(void)showValidationErrors;
-(void)validateField:(int)tag;
- (void) singleTapGestureCaptured:(UITapGestureRecognizer*)gesture;
- (void)showActionSheet:(id)sender;
- (NSMutableURLRequest*) buildDataRequest;
- (void) setUserDataInView;
- (void) refreshCaches;
@end

@implementation EditProfileViewController
@synthesize saveButton, cancelButton;
@synthesize delegate = _delagate;
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
	CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, screenHeight)];
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(320, 600);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.userInteractionEnabled = YES;

    // profile picture button
    profilePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(37, 19, 72, 72)];
    profilePictureButton.layer.cornerRadius = 5;
    profilePictureButton.layer.masksToBounds = YES;
    [profilePictureButton addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    profilePictureButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [scrollView addSubview:profilePictureButton];
    
    userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 23, 184, 21)];
    userNameLabel.font = [UIFont fontWithName:FONT_GLOBAL size:16.0f];
    userNameLabel.textColor = [UIColor whiteColor];
    userNameLabel.backgroundColor = [UIColor clearColor];
    userNameLabel.userInteractionEnabled = YES;
    [scrollView addSubview:userNameLabel];
    
    schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 43, 181, 40)];
    schoolLabel.font = [UIFont fontWithName:FONT_GLOBAL size:12.0f];
    schoolLabel.textColor = [UIColor whiteColor];
    schoolLabel.backgroundColor = [UIColor clearColor];
    schoolLabel.userInteractionEnabled = YES;
    [scrollView addSubview:schoolLabel];
    
    UIFont *textFieldFont = [UIFont fontWithName:FONT_GLOBAL size:18.0f];
    UIImage *textFieldBg = [UIImage imageNamed:@"ulink_mobile_input_field.png"];
    firstNameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 99, 245, 47)];
    firstNameImageView.image = textFieldBg;
    [scrollView addSubview:firstNameImageView];
    firstNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 108, 229, 47)];
    firstNameTextField.placeholder = @"FirstName";
    firstNameTextField.delegate = self;
    firstNameTextField.tag = kTextFieldFirstname;
    firstNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    firstNameTextField.clearsOnBeginEditing = NO;
    firstNameTextField.font = textFieldFont;
    firstNameTextField.textColor = [UIColor blackColor];
    [scrollView addSubview:firstNameTextField];
    
    lastNameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 154, 245, 47)];
    lastNameImageView.image = textFieldBg;
    [scrollView addSubview:lastNameImageView];
    lastNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 163, 229, 47)];
    lastNameTextField.placeholder = @"LastName";
    lastNameTextField.delegate = self;
    lastNameTextField.tag = kTextFieldLastname;
    lastNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    lastNameTextField.clearsOnBeginEditing = NO;
    lastNameTextField.font = textFieldFont;
    lastNameTextField.textColor = [UIColor blackColor];
    [scrollView addSubview:lastNameTextField];

    schoolStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 209, 245, 47)];
    schoolStatusImageView.image = textFieldBg;
    [scrollView addSubview:schoolStatusImageView];
    schoolStatusTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 218, 245, 47)];
    schoolStatusTextField.placeholder = @"School Status";
    schoolStatusTextField.tag = kTextFieldSchoolStatus;
    schoolStatusTextField.delegate = self;
    schoolStatusTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    schoolStatusTextField.userInteractionEnabled = YES;
    schoolStatusTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    schoolStatusTextField.clearsOnBeginEditing = NO;
    schoolStatusTextField.font = textFieldFont;
    schoolStatusTextField.textColor = [UIColor blackColor];
    [scrollView addSubview:schoolStatusTextField];
    
    yearImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 264, 245, 47)];
    yearImageView.image = textFieldBg;
    [scrollView addSubview:yearImageView];
    yearTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 273, 245, 47)];
    yearTextField.placeholder = @"Year";
    yearTextField.tag = kTextFieldYear;
    yearTextField.delegate = self;
    yearTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    yearTextField.userInteractionEnabled = YES;
    yearTextField.clearsOnBeginEditing = NO;
    yearTextField.font = textFieldFont;
    yearTextField.textColor = [UIColor blackColor];
    [scrollView addSubview:yearTextField];
    
    UIImage *textViewBg = [UIImage imageNamed:@"ulink_mobile_input_field_textarea.png"];
    bioImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 320, 248, 121)];
    bioImageView.image = textViewBg;
    [scrollView addSubview:bioImageView];
    bioTextView = [[UITextView alloc] initWithFrame:CGRectMake(37, 323, 248, 108)];
    bioTextView.tag = kTextViewBio;
    bioTextView.delegate = self;
    bioTextView.secureTextEntry = NO;
    bioTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    bioTextView.font = [UIFont fontWithName:FONT_GLOBAL size:12.0f];
    bioTextView.textColor = [UIColor blackColor];
    bioTextView.backgroundColor = [UIColor clearColor];
    bioTextView.returnKeyType = UIReturnKeyDone;
    [scrollView addSubview:bioTextView];
    [self.view addSubview:scrollView];
    
    schoolStatuses = [[NSArray alloc] initWithObjects:@"",SCHOOL_STATUS_CURRENT_STUDENT, SCHOOL_STATUS_ALUMNI, nil];
    schoolStatusPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,screenHeight-216, 320, 216)];
    schoolStatusPickerView.dataSource = self;
    schoolStatusPickerView.delegate = self;
    schoolStatusPickerView.showsSelectionIndicator = YES;
    schoolStatusPickerView.alpha = ALPHA_ZERO;
    [self.view addSubview:schoolStatusPickerView];
    
    
    validationErrors = [[NSHashTable alloc] init];
    textUtil = [TextUtil instance];
    defaulValidationMsg = @"";
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: defaulValidationMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    successNotifiction = [[SuccessNotificationView alloc] init];
    [successNotifiction setMessage:@"Profile Updated."];
    self.saveButton.enabled = FALSE;
    [self hideSchoolStatusPickerView];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    
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
    [self setUserDataInView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUserDataInView {
    userNameLabel.text = UDataCache.sessionUser.username;
    schoolLabel.text = UDataCache.sessionUser.schoolName;
    yearTextField.text = UDataCache.sessionUser.year;
    schoolStatusTextField.text = UDataCache.sessionUser.schoolStatus;
    if([schoolStatusTextField.text isEqualToString:SCHOOL_STATUS_CURRENT_STUDENT]) {
        [schoolStatusPickerView selectRow:1 inComponent:0 animated:NO];
    } else if ([schoolStatusTextField.text isEqualToString:SCHOOL_STATUS_ALUMNI]) {
        [schoolStatusPickerView selectRow:2 inComponent:0 animated:NO];
    } else {
        [schoolStatusPickerView selectRow:0 inComponent:0 animated:NO];
    }
    bioTextView.text = UDataCache.sessionUser.bio;
    lastNameTextField.text = UDataCache.sessionUser.lastname;
    firstNameTextField.text = UDataCache.sessionUser.firstname;
    if (!imageChanged) {
        [profilePictureButton setImage:UDataCache.sessionUser.profileImage forState:UIControlStateNormal];

        // grab the user's image from the user cache
        UIImage *profileImage = [UDataCache imageExists:UDataCache.sessionUser.userId cacheModel:IMAGE_CACHE_USER_MEDIUM];
        if (profileImage == nil) {
            if(UDataCache.sessionUser.userImgURL != nil) {
            // set the key in the cache to let other processes know that this key is in work
            [UDataCache.userImageMedium setValue:[NSNull null] forKey:UDataCache.sessionUser.userId];
            // lazy load the image from the web
            NSURL *url = [NSURL URLWithString:[URL_USER_IMAGE_MEDIUM stringByAppendingString:UDataCache.sessionUser.userImgURL]];
            __block ImageActivityIndicatorView *editProActIndicator;
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            [imageDownloader downloadImageWithURL:url
                                          options:SDWebImageDownloaderProgressiveDownload
                                         progress:^(NSUInteger receivedSize, long long expectedSize) {
                                             if (!editProActIndicator)
                                             {
                                                 editProActIndicator = [[ImageActivityIndicatorView alloc] init];
                                                 [editProActIndicator showActivityIndicator:profilePictureButton.imageView];
                                                 profilePictureButton.userInteractionEnabled = NO;
                                             }
                                         }
                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                            if (image && finished)
                                            {
                                                // add the user's image to the image cache
                                                [UDataCache.userImageMedium setValue:image forKey:UDataCache.sessionUser.userId];
                                                // set the picture in the view
                                                [profilePictureButton setImage:image forState:UIControlStateNormal];
                                                [editProActIndicator hideActivityIndicator:profilePictureButton.imageView];
                                                editProActIndicator = nil;
                                                profilePictureButton.userInteractionEnabled = YES;
                                            }
                                        }];
            }
        } else if(![profileImage isKindOfClass:[NSNull class]]){
            [profilePictureButton setImage:profileImage forState:UIControlStateNormal];
        }
    }
}
- (void) refreshCaches {
    [UDataCache rehydrateSessionUser];
    [UDataCache rehydrateSnapshotsCache:NO];
    [UDataCache rehydrateEventsCache:NO];
    [UDataCache rehydrateTweetsCache:NO];
}
- (void)hideSchoolStatusPickerView {
    pickListVisible = FALSE;
    schoolStatusPickerView.alpha = ALPHA_ZERO;
}
- (void)showSchoolStatusPickerView {
    pickListVisible = TRUE;
    schoolStatusPickerView.alpha = ALPHA_HIGH;
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
    [profilePictureButton setImage:image forState:UIControlStateNormal];
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
    return [schoolStatuses count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [schoolStatuses objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    schoolStatusTextField.text = [schoolStatuses objectAtIndex:row];
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
        case kTextFieldFirstname: {
            if (firstNameTextField.text.length < 1) {
                [validationErrors addObject:@"\nPlease enter your firstname"];
            }else {
                [validationErrors removeObject:@"\nPlease enter your firstname"];
            }
        }
            break;
        case kTextFieldLastname:
        {
            if (lastNameTextField.text.length < 1) {
                [validationErrors addObject:@"\nPlease enter your lastname"];
            } else {
                [validationErrors removeObject:@"\nPlease enter your lastname"];
            }
        }
            break;
        case kTextViewBio: {
            if (bioTextView.text.length < 1) {
                [validationErrors addObject:@"\nPlease enter your bio"];
            } else {
                [validationErrors removeObject:@"\nPlease enter your bio"];
            }
        }
            break;
        case kTextFieldSchoolStatus:
            if (schoolStatusTextField.text.length < 3) {
                [validationErrors addObject:@"\nPlease enter your school status"];
            } else {
                [validationErrors removeObject:@"\nPlease enter your school status"];
            }
            break;
        case kTextFieldYear:
            if (yearTextField.text.length != 4 && [textUtil isDigitsOnly:yearTextField.text]) {
                [validationErrors addObject:@"\nPlease enter your four digit graduation year"];
            } else {
                [validationErrors removeObject:@"\nPlease enter your four digit graduation year"];
            }
            break;
    }
    
}
- (void) singleTapGestureCaptured:(UITapGestureRecognizer*)gesture {
    CGPoint touchPoint = [gesture locationInView:scrollView];
    if ([firstNameTextField isFirstResponder] && !CGRectContainsPoint(firstNameTextField.frame, touchPoint)) {
        [firstNameTextField  resignFirstResponder];
    } else if ([lastNameTextField isFirstResponder] && !CGRectContainsPoint(lastNameTextField.frame, touchPoint)) {
        [lastNameTextField  resignFirstResponder];
    } else if ([bioTextView isFirstResponder] && !CGRectContainsPoint(bioTextView.frame, touchPoint)) {
        [bioTextView  resignFirstResponder];
    } else if ([yearTextField isFirstResponder] && !CGRectContainsPoint(yearTextField.frame, touchPoint)) {
        [yearTextField  resignFirstResponder];
    }
    
    if(!CGRectContainsPoint(schoolStatusTextField.frame, touchPoint)) {
        if(pickListVisible) {
            [self hideSchoolStatusPickerView];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if(pickListVisible) {
        [self hideSchoolStatusPickerView];
    }
    [scrollView setContentOffset:svos animated:YES];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL retVal = YES;
    if(textField.tag == kTextFieldSchoolStatus) {
        if(!pickListVisible) {
            [self showSchoolStatusPickerView];
        } 
        if ([firstNameTextField isFirstResponder]) {
            [firstNameTextField  resignFirstResponder];
        } else if ([lastNameTextField isFirstResponder]) {
            [lastNameTextField  resignFirstResponder];
        } else if ([bioTextView isFirstResponder]) {
            [bioTextView  resignFirstResponder];
        } else if ([yearTextField isFirstResponder]) {
            [yearTextField  resignFirstResponder];
        }
        retVal = NO;
    } else {
        if(pickListVisible) {
            [self hideSchoolStatusPickerView];
        }
    }

    return retVal;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    svos = scrollView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:scrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    [scrollView setContentOffset:pt animated:YES];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [scrollView setContentOffset:CGPointMake(0, 200) animated:YES];
    if(pickListVisible) {
        [self hideSchoolStatusPickerView];
    }
    return TRUE;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldYear: [self validateField:kTextFieldYear];
            break;
        case kTextFieldFirstname: [self validateField:kTextFieldFirstname];
            break;
        case kTextFieldLastname: [self validateField:kTextFieldLastname];
            break;
        case kTextFieldSchoolStatus: [self validateField:kTextFieldSchoolStatus];
            break;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self validateField:kTextFieldBio];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL retVal = NO;
    self.saveButton.enabled = TRUE;
    if([text isEqualToString:@"\n"]) {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [textView resignFirstResponder];
    }
    if([text isEqualToString:@""]) {
        retVal = YES;
    } else {
        retVal = bioTextView.text.length < 151;
    }
    return retVal;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL retVal = NO;
    self.saveButton.enabled = TRUE;
    if([string isEqualToString:@""]) {
        retVal = YES;
    } else {
        if (textField.tag == kTextFieldYear) {
            retVal = textField.text.length < 5;
        } else if (textField.tag == kTextFieldFirstname || textField.tag == kTextFieldLastname) {
            retVal = textField.text.length < 51;
        } 
    } 
    return retVal;
}
- (NSMutableURLRequest*) buildDataRequest {
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_USERS_UPDATE_USER]]];
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
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[User][id]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", UDataCache.sessionUser.userId] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[User][username]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", UDataCache.sessionUser.username] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[User][image_url]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", UDataCache.sessionUser.userImgURL] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[User][firstname]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", firstNameTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[User][lastname]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", lastNameTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[User][year]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", yearTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[User][bio]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", bioTextView.text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"data[User][school_status]"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", schoolStatusTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"mobile_login"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", @"yes"] dataUsingEncoding:NSUTF8StringEncoding]];
    /*
     * If the image changed we will add
     * it to POST to the API.
     */
    if(imageChanged) {
        if (profilePictureButton.imageView.image != nil) {
            // add image as event image data
            NSData *imageData = [UImageUtil compressImageToData:profilePictureButton.imageView.image];
            if (imageData) {
                [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
                NSString *imageName = @"userpic";
                imageName = [imageName stringByAppendingFormat:@"%@.jpg\"\r\n",UDataCache.sessionUser.userId];
                NSString *imageParamData = [@"Content-Disposition: form-data; name=\"data[User][file]\"; filename=\"" stringByAppendingString:imageName];
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
- (IBAction)cancelClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveClick:(id)sender {
    [self.view endEditing:YES];
    [scrollView setContentOffset:svos animated:YES];
    if(pickListVisible) {
        [self hideSchoolStatusPickerView];
    }
    @try {
        [self validateField:kTextFieldFirstname];
        [self validateField:kTextFieldLastname];
        [self validateField:kTextFieldYear];
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
                        // set updated user data in UserCache
                        UDataCache.sessionUser.firstname  = firstNameTextField.text;
                        UDataCache.sessionUser.lastname = lastNameTextField.text;
                        UDataCache.sessionUser.year = yearTextField.text;
                        UDataCache.sessionUser.schoolStatus = schoolStatusTextField.text;
                        UDataCache.sessionUser.bio = bioTextView.text;
                        if(imageChanged) {
                            UDataCache.sessionUser.profileImage = profilePictureButton.imageView.image;
                            NSDictionary *response = [json objectForKey:JSON_KEY_RESPONSE];
                            UDataCache.sessionUser.userImgURL = [[response objectForKey:@"userdata"] objectForKey:@"image_url"];
                            // remove the old user image since it changed
                            [UDataCache removeImage:UDataCache.sessionUser.userId cacheModel:IMAGE_CACHE_USER_MEDIUM];
                              [UDataCache removeImage:UDataCache.sessionUser.userId cacheModel:IMAGE_CACHE_EVENT_THUMBS];
                        }
                        [successNotifiction showNotification:self.view];
                        self.cancelButton.title = @"Done";
                        self.cancelButton.style = UIBarButtonItemStyleDone;
                        // update the profile in profilepictureviewcontroller
                        [self.delegate updateProfileInformation];
                        // rehydrate all the caches to show this user's updated data
                        [self performSelectorInBackground:@selector(refreshCaches) withObject:self];
                    } else {
                       NSString *response = (NSString*)[json objectForKey:JSON_KEY_RESPONSE];
                       if (response != nil) {
                            // remove HTML line breaks from response
                            NSString *filteredResponse = [response stringByReplacingOccurrencesOfString: @"<br />" withString:@"\n"];
                            errorAlertView.message = filteredResponse;
                        } else {
                            errorAlertView.message = @"There was a problem updating your profile.  Please try again later or contact help@theulink.com.";
                        }
                        [errorAlertView show];
                        self.saveButton.enabled = TRUE;
                    }
                } else {
                    errorAlertView.message = @"There was a problem updating your profile.  Please try again later or contact help@theulink.com.";
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
