//
//  AddListingTextViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 7/3/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "AddListingTextViewController.h"
#import "AlertView.h"
#import "TextUtil.h"
#import "AppMacros.h"

@interface AddListingTextViewController () {
    UITextField *listingTextField;
    UITextView *descriptionTextView;
    AlertView *errorAlertView;
    NSString *defaultValidationMsg;
    NSHashTable *validationErrors;
    UIBarButtonItem *btnSave;
    NSNumberFormatter *numberFormatter;
    
    // tags attributes
    UITextField *tag1TextField;
    UITextField *tag2TextField;
    UITextField *tag3TextField;
    UIImageView *tagImageView1;
    UIImageView *tagImageView2;
    UIImageView *tagImageView3;
    UIButton *addTagButton;
    UIButton *removeTag2Button;
    UIButton *removeTag3Button;
    int numberOfTags;
    BOOL validateTags;
}
-(void) buildTextField;
-(void) buildDescriptionField;
-(void) buildTagRelatedViews;
-(void) validateField:(int)tag;
-(void) addTag;
-(void) removeTag2;
-(void) removeTag3;
@end

@implementation AddListingTextViewController
const int kListingTagLimit = 3;
@synthesize mode, listing;
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
    if(self.listing == nil) {
        self.listing = [[Listing alloc] init];
    }
    // build the text view based on the mode
    switch (mode) {
        case kAddListingTextModeDescription:
            self.navigationItem.title = @"Description";
            defaultValidationMsg = @"Please enter your description";
            [self buildDescriptionField];
            break;
        case kAddListingTextModeTitle:
            self.navigationItem.title = @"Title";
            defaultValidationMsg = @"Please enter your title";
            [self buildTextField];
            break;
        case kAddListingTextModePrice:
            self.navigationItem.title = @"Price";
            defaultValidationMsg = @"Please enter a valid price";
            [self buildTextField];
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [numberFormatter setMaximumFractionDigits:2];
            break;
        case kAddListingTextModeTags:
            // set the current number of tags to 1
            numberOfTags = 1;
            self.navigationItem.title = @"Tags";
            defaultValidationMsg = @"You can only enter up to three tags";
            [self buildTagRelatedViews];
            break;
    }
    // add the "Save" button
    btnSave = [[UIBarButtonItem alloc]
                                initWithTitle:@"Done"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(saveClick:)];
    self.navigationItem.rightBarButtonItem = btnSave;
    btnSave.enabled = FALSE;
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: defaultValidationMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    validationErrors = [[NSHashTable alloc] init];
}

- (void) buildTextField {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 30, 245, 47)];
    imageView.image = [UIImage imageNamed:@"ulink_mobile_input_field"];
    [self.view addSubview:imageView];
    listingTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 42, 229, 47)];
    listingTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    listingTextField.placeholder = self.navigationItem.title;
    listingTextField.tag = mode;
    listingTextField.clearsOnBeginEditing = NO;
    listingTextField.delegate = self;
    if (mode == kAddListingTextModeTitle) {
        if(self.listing.title != nil && ![self.listing.title isEqualToString:EMPTY_STRING]) {
            listingTextField.text = self.listing.title;
            btnSave.enabled = TRUE;
        }
    } else {
        if(self.listing.price > -1) {
            NSNumber *priceNumber = [NSNumber numberWithDouble:self.listing.price];
            listingTextField.text = [priceNumber stringValue];
            btnSave.enabled = TRUE;
        }
        listingTextField.keyboardType = UIKeyboardTypeDecimalPad;
    }

    [self.view addSubview:listingTextField];
}
- (void) buildTagRelatedViews {
    // create the text field bg image
    UIImage *textBgImage = [UIImage imageNamed:@"ulink_mobile_input_field"];
    // create the add tag button and add it to the view
    UIImage *addTagButtonImage = [UIImage imageNamed:@"mobile-plus-sign"];
    addTagButton = [UIButton buttonWithType:UIButtonTypeCustom];   
    addTagButton.frame = CGRectMake(275, 38, 30, 30);
    [addTagButton setBackgroundImage:addTagButtonImage forState:UIControlStateNormal];
    [addTagButton addTarget:self action:@selector(addTag) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addTagButton];
    
    // tag 1
    tagImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(17, 30, 245, 47)];
    tagImageView1.image = textBgImage;
    tag1TextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 42, 229, 47)];
    tag1TextField.autocorrectionType = UITextAutocorrectionTypeNo;
    tag1TextField.placeholder = @"Tag";
    tag1TextField.tag = mode;
    tag1TextField.clearsOnBeginEditing = NO;
    tag1TextField.delegate = self;
    [self.view addSubview:tagImageView1];
    [self.view addSubview:tag1TextField];
    
    // tag 2
    tagImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(17, 90, 245, 47)];
    tagImageView2.image = textBgImage;
    tag2TextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 102, 229, 47)];
    tag2TextField.autocorrectionType = UITextAutocorrectionTypeNo;
    tag2TextField.placeholder = @"Tag";
    tag2TextField.tag = mode;
    tag2TextField.clearsOnBeginEditing = NO;
    tag2TextField.delegate = self;
    [self.view addSubview:tagImageView2];
    [self.view addSubview:tag2TextField];
    // initially hide the 2 tag
    tag2TextField.alpha = ALPHA_ZERO;
    tagImageView2.alpha = ALPHA_ZERO;
    // create the remove tag 2 button and add it to the view
    UIImage *removeTagButtonImage = [UIImage imageNamed:@"mobile-minus-sign"];
    removeTag2Button = [UIButton buttonWithType:UIButtonTypeCustom];
    removeTag2Button.frame = CGRectMake(275, 98, 30, 30);
    removeTag2Button.tag = 2;
    [removeTag2Button setBackgroundImage:removeTagButtonImage forState:UIControlStateNormal];
    [removeTag2Button addTarget:self action:@selector(removeTag2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeTag2Button];
    removeTag2Button.alpha = ALPHA_ZERO;
    
    
    // tag 3
    tagImageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(17, 150, 245, 47)];
    tagImageView3.image = textBgImage;
    tag3TextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 162, 229, 47)];
    tag3TextField.autocorrectionType = UITextAutocorrectionTypeNo;
    tag3TextField.placeholder = @"Tag";
    tag3TextField.tag = mode;
    tag3TextField.clearsOnBeginEditing = NO;
    tag3TextField.delegate = self;
    [self.view addSubview:tagImageView3];
    [self.view addSubview:tag3TextField];
    // initially hide the 3 tag
    tag3TextField.alpha = ALPHA_ZERO;
    tagImageView3.alpha = ALPHA_ZERO;
    // create the remove tag 3 button and add it to the view
    removeTag3Button = [UIButton buttonWithType:UIButtonTypeCustom];
    removeTag3Button.frame = CGRectMake(275, 158, 30, 30);
    removeTag2Button.tag = 3;
    [removeTag3Button setBackgroundImage:removeTagButtonImage forState:UIControlStateNormal];
    [removeTag3Button addTarget:self action:@selector(removeTag3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeTag3Button];
    removeTag3Button.alpha = ALPHA_ZERO;
    
    /* 
     * now determine if there are tags set, and show the correct
     * text fields for the tags as necessary 
     */
    if (self.listing.tags != nil && self.listing.tags.count > 0) {
        btnSave.enabled = TRUE;
        // iterate over the tags, showing and setting the views if there are extra tags
        for (int idx = 0; idx < self.listing.tags.count;  idx++) {
            NSString *tag = (NSString*)[self.listing.tags objectAtIndex:idx];
            if(idx == 0) {
                if(tag != nil && ![tag isEqualToString:EMPTY_STRING]) {
                    tag1TextField.text = tag;
                    btnSave.enabled = TRUE;
                }
            }
            else if (idx == 1) {
                if(tag != nil && ![tag isEqualToString:EMPTY_STRING]) {
                    tag2TextField.text = tag;
                    tag2TextField.alpha = ALPHA_HIGH;
                    tagImageView2.alpha = ALPHA_HIGH;
                    removeTag2Button.alpha = ALPHA_HIGH;
                    numberOfTags = 2;
                }
            } else if (idx == 2) {
                if(tag != nil && ![tag isEqualToString:EMPTY_STRING]) {
                    tag3TextField.text = tag;
                    tag3TextField.alpha = ALPHA_HIGH;
                    tagImageView3.alpha = ALPHA_HIGH;
                    removeTag2Button.alpha = ALPHA_ZERO;
                    removeTag3Button.alpha = ALPHA_HIGH;
                    numberOfTags = 3;
                }
            }
        }
    }
}

- (void) buildDescriptionField {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 30, 248, 121)];
    imageView.image = [UIImage imageNamed:@"ulink_mobile_input_field_textarea"];
    [self.view addSubview:imageView];
    descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(38, 30, 248, 108)];
    descriptionTextView.tag = mode;
    descriptionTextView.delegate = self;
    descriptionTextView.secureTextEntry = NO;
    descriptionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    descriptionTextView.font = [UIFont fontWithName:FONT_GLOBAL size:12.0f];
    descriptionTextView.textColor = [UIColor blackColor];
    descriptionTextView.backgroundColor = [UIColor clearColor];
    descriptionTextView.returnKeyType = UIReturnKeyDefault;
    if(self.listing.listDescription != nil && ![self.listing.listDescription isEqualToString:EMPTY_STRING]) {
        descriptionTextView.text = self.listing.listDescription;
        btnSave.enabled = TRUE;
    } else {
        descriptionTextView.text = @"Description";
    }
    [self.view addSubview:descriptionTextView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if ([listingTextField isFirstResponder] && [touch view] != listingTextField) {
        [listingTextField  resignFirstResponder];
    } else if ([descriptionTextView isFirstResponder] && [touch view] != descriptionTextView) {
        [descriptionTextView  resignFirstResponder];
    } else if ([tag1TextField isFirstResponder] && [touch view] != tag1TextField) {
        [tag1TextField  resignFirstResponder];
    } else if ([tag2TextField isFirstResponder] && [touch view] != tag2TextField) {
        [tag2TextField  resignFirstResponder];
    } else if ([tag3TextField isFirstResponder] && [touch view] != tag3TextField) {
        [tag3TextField  resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark TextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    btnSave.enabled = TRUE;
    BOOL retVal = NO;
    if([string isEqualToString:@""]) {
        retVal = YES;
    } else {
        switch (mode) {
            case kAddListingTextModeDescription:
                break;
            case kAddListingTextModeTitle:
            case kAddListingTextModePrice:
            case kAddListingTextModeTags:
                retVal = listingTextField.text.length < 255;
                break;
        }
    }
    return retVal;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark -

#pragma mark TextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([descriptionTextView.text isEqualToString:@"Description"]) {
        descriptionTextView.text = @"";
    }
    btnSave.enabled = TRUE;
    return TRUE;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL retVal = NO;
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    if([text isEqualToString:@""]) {
        retVal = YES;
    } else {
        retVal = descriptionTextView.text.length < 751;
    }
    return retVal;
}

#pragma mark -
#pragma mark AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // reset the custom Alert view
    [errorAlertView resetAlert:defaultValidationMsg];
}
#pragma mark -
- (void)validateField:(int)tag {
    switch (tag) {
        case kAddListingTextModeDescription:
            if (descriptionTextView.text.length < 2 || [descriptionTextView.text isEqualToString:@"Description"]) {
                [validationErrors addObject:defaultValidationMsg];
            } else {
                [validationErrors removeObject:defaultValidationMsg];
            }
            break;
        case kAddListingTextModeTitle:
            listingTextField.text = [UTextUtil trimWhitespace:listingTextField.text];
            if (listingTextField.text.length < 1 || [listingTextField.text isEqualToString:EMPTY_STRING]) {
                [validationErrors addObject:defaultValidationMsg];
            } else {
                [validationErrors removeObject:defaultValidationMsg];
            }
            break;
        case kAddListingTextModePrice: {
            // trim the text
            listingTextField.text = [UTextUtil trimWhitespace:listingTextField.text];
            NSNumber *price = [NSNumber numberWithDouble:[listingTextField.text doubleValue]];
            listingTextField.text = [numberFormatter stringFromNumber:price];
            // validate that the value is a number
            if (listingTextField.text.length < 1 || [listingTextField.text isEqualToString:EMPTY_STRING] || ![UTextUtil isDigitsOnly:listingTextField.text]) {
                [validationErrors addObject:defaultValidationMsg];
            } else {
                [validationErrors removeObject:defaultValidationMsg];
            }
        }
            break;
        case kAddListingTextModeTags:
            // trim the text on the tags
            tag1TextField.text = [UTextUtil trimWhitespace:tag1TextField.text];
            tag2TextField.text = [UTextUtil trimWhitespace:tag2TextField.text];
            tag3TextField.text = [UTextUtil trimWhitespace:tag3TextField.text];
            if (validateTags && numberOfTags == kListingTagLimit) {
                [validationErrors addObject:defaultValidationMsg];
            } else {
                [validationErrors removeObject:defaultValidationMsg];
            }
            break;
    }
}
#pragma mark Actions
- (void) addTag {
    // make sure we haven't hit our tag limit number
    validateTags = TRUE;
    [self validateField:mode];
    if([validationErrors count] > 0) {
        errorAlertView.message = @"";
        for (NSString *error in validationErrors) {
            errorAlertView.message = [errorAlertView.message stringByAppendingString:error];
        }
        [errorAlertView show];
        return;
    }
    
    // now add the next tag
    switch (numberOfTags) {
        case 1:
            // add the second tag
            tag2TextField.alpha = ALPHA_HIGH;
            tagImageView2.alpha = ALPHA_HIGH;
            removeTag2Button.alpha = ALPHA_HIGH;
            break;
        case 2:
            // add the third tag
            tag3TextField.alpha = ALPHA_HIGH;
            tagImageView3.alpha = ALPHA_HIGH;
            removeTag3Button.alpha = ALPHA_HIGH;
            // hide the remove tag 2 button
            removeTag2Button.alpha = ALPHA_ZERO;
            break;
    }
    numberOfTags++;
}
-(void) removeTag2 {
    [self.view endEditing:YES];
    // hide and clear out tag 2
    tag2TextField.text = EMPTY_STRING;
    tag2TextField.alpha = ALPHA_ZERO;
    tagImageView2.alpha = ALPHA_ZERO;
    removeTag2Button.alpha = ALPHA_ZERO;
    numberOfTags--;
    btnSave.enabled = TRUE;
}

-(void) removeTag3 {
    [self.view endEditing:YES];
    // hide and clear out tag 3
    tag3TextField.text = EMPTY_STRING;
    tag3TextField.alpha = ALPHA_ZERO;
    tagImageView3.alpha = ALPHA_ZERO;
    removeTag3Button.alpha = ALPHA_ZERO;
    // show the remove tag two button
    removeTag2Button.alpha = ALPHA_HIGH;
    numberOfTags--;
    btnSave.enabled = TRUE;
}
- (void)saveClick:(id)sender {
    [self.view endEditing:YES];
     validateTags = FALSE;
    [self validateField:mode];
    if([validationErrors count] > 0) {
        errorAlertView.message = @"";
        for (NSString *error in validationErrors) {
            errorAlertView.message = [errorAlertView.message stringByAppendingString:error];
        }
        [errorAlertView show];
        return;
    }
    btnSave.enabled = FALSE;
    switch (mode) {
        case kAddListingTextModeDescription:
            listing.listDescription = descriptionTextView.text;
            break;
        case kAddListingTextModeTitle:
            listing.title = listingTextField.text;
            break;
        case kAddListingTextModePrice:
            listing.price = [listingTextField.text doubleValue];
        case kAddListingTextModeTags:
        {
            // check to see if there are tags, if so add a tag for each to the listing tags array
            if(tag1TextField.text != nil && ![tag1TextField.text isEqualToString:EMPTY_STRING]) {
                // check to see if the listing already has items, if so just insert
                if(self.listing.tags != nil) {
                    [self.listing.tags removeAllObjects];
                } else {
                    self.listing.tags = [[NSMutableArray alloc] init];
                }
                [self.listing.tags addObject:tag1TextField.text];
                if(tag2TextField.text != nil && ![tag2TextField.text isEqualToString:EMPTY_STRING]) {
                    [self.listing.tags addObject:tag2TextField.text];
                }
                if(tag3TextField.text != nil && ![tag3TextField.text isEqualToString:EMPTY_STRING]) {
                    [self.listing.tags addObject:tag3TextField.text];
                }
            }
        }
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
