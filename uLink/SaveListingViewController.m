//
//  SaveListingViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 9/2/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//
// TODO: 
//       3. Verify all validations
//       4. Add the segue to the AddListingAddOnViewController for when the saveMode is "Add"
//
// 
#import "SaveListingViewController.h"
#import "AlertView.h"
#import "ColorConverterUtil.h"
#import "TextUtil.h"
#import "PreviewPhotoView.h"
#import "UlinkButton.h"
#import "ActivityIndicatorView.h"
#import "SuccessNotificationView.h"
#import "ImageActivityIndicatorView.h"
#import "DataCache.h"
#import <SDWebImage/SDWebImageDownloader.h>

@interface SaveListingViewController () {
    UIBarButtonItem *btnSave;
    AlertView *errorAlertView;
    AlertView *deleteAlertView;
    NSString *defaultValidationMsg;
    NSHashTable *validationErrors;
    NSNumberFormatter *numberFormatter;
    float defaultCellHeight;
    BOOL listingHasPrice;
    NSIndexPath* previouslySelectedIndexPath;
    ActivityIndicatorView *activityIndicator;
    SuccessNotificationView *successNotification;
    
    // title text field and bg image view
    UITextField *listingTitleTextField;
    UIImageView *titleBgImageView;
    // description text view and bg image view
    UITextView *descriptionTextView;
    UIImageView *descriptionBgImageView;
    // price text field and bg image view
    UITextField *listingPriceTextField;
    UIImageView *priceBgImageView;
    
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
    
    // photo properties
    UIView *photoContainerView;
    UIImagePickerController *imagePicker;
    PreviewPhotoView *previewPhotoView1;
    PreviewPhotoView *previewPhotoView2;
    PreviewPhotoView *previewPhotoView3;
    UIButton *photoButton1;
    UIButton *photoButton2;
    UIButton *photoButton3;
    UIActionSheet *photoActionSheet;
    int activePhotoButton;
    
    // location properties
    UITextField *zipTextField;
    UIImageView *zipBgImageView;
    UITextField *stateTextField;
    UIImageView *stateBgImageView;
    UITextField *addressTextField;
    UIImageView *addressBgImageView;
    UITextField *cityTextField;
    UIImageView *cityBgImageView;
    UISwitch *discloseLocationSwitch;
    BOOL listingImagesChanged;
    UILabel *disclosureLabel;
}
-(UITableViewCell*) buildTitleDescriptionCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildTitleDescriptionFormCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildPhotosListingCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildPhotosListingFormCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildPriceListingCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildPriceListingFormCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildLocationListingCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildLocationListingFormCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildTagsListingCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildTagsListingFormCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildDeleteListingCell:(UITableViewCell*)cell;

-(void) buildTitleTextField;
-(void) buildDescriptionField;
-(void) buildPriceTextField;
-(void) buildTagRelatedViews;
-(void) buildPhotoRelatedViews;
-(void) buildLocationRelatedViews;
@end

@implementation SaveListingViewController
const int kListingTagLimitNumber = 3;
const int kPhotoButton_1 = 1;
const int kPhotoButton_2 = 2;
const int kPhotoButton_3 = 3;
@synthesize saveMode;
@synthesize listing;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set the default cell height
    defaultCellHeight = 75;
    NSString *btnTitle;
    // set the view's title in the nav bar based on the save mode
    if(self.saveMode == kListingSaveTypeUpdate) {
        self.navigationItem.title = @"Edit Listing";
        btnTitle = @"Save";
    } else {
        self.navigationItem.title = @"Add Listing";
        btnTitle = @"Next";
    }
    
    // set the table view's background color to black
    self.view.backgroundColor = [UIColor blackColor];
    
    // determine if the listing has a price
    listingHasPrice = [self.listing.mainCategory isEqualToString:@"For Sale"];
    
    // remove the cell separators since we are going flat UI
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // if we are in "Add" mode this button will be "Next" (which will go to the Add Ons View)
    btnSave = [[UIBarButtonItem alloc]
               initWithTitle:btnTitle
               style:UIBarButtonItemStylePlain
               target:self
               action:@selector(saveClick)];
    self.navigationItem.rightBarButtonItem = btnSave;
    // initially keep the save button disabled.
    btnSave.enabled = FALSE;
    // initially have the listing image changed bool to False
    listingImagesChanged = FALSE;
    
    // initialize alert view 
    errorAlertView = [[AlertView alloc] initWithTitle:EMPTY_STRING
                                              message: defaultValidationMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    // initialize the delete alert view
    deleteAlertView = [[AlertView alloc] initWithTitle:EMPTY_STRING
                                               message:@"Are you sure you would like delete this listing?  This action cannot be undone."
                                              delegate:self
                                     cancelButtonTitle:BTN_CANCEL
                                     otherButtonTitles:BTN_DELETE,nil];
    validationErrors = [[NSHashTable alloc] init];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    successNotification = [[SuccessNotificationView alloc] init];
    
    // set the current number of tags to 1
    numberOfTags = 1;
    
    // create the image picker
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
    
    // register the notification for when a user removes a photo
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(photoChanged) name:NOTIFICATION_PREVIEW_PHOTO_CLOSED
                                               object:nil];
    
    // build all the text fields and views
    [self buildTitleTextField];
    [self buildDescriptionField];
    // build price if necessary
    if(listingHasPrice) {
        [self buildPriceTextField];
    }
    [self buildTagRelatedViews];
    [self buildPhotoRelatedViews];
    [self buildLocationRelatedViews];
}
-(void) photoChanged {
    /*
     * Since this function gets called when we receive a notification, and since it is
     * possible that the notification comes in on a different sub thread, we
     * need to ensure that the code in this function is executed on the main thread so
     * that it doesn't hold up the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        listingImagesChanged = TRUE;
        btnSave.enabled = TRUE;
    });
}
- (void) buildPhotoRelatedViews {
    // create each of the photo buttons
    UIImage *bgImage = [UIImage imageNamed:@"icon-camera-large"];
    photoButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton1 addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchDown];
    photoButton1.imageView.contentMode = UIViewContentModeScaleAspectFill;
    photoButton1.frame = CGRectMake(5, 10, 100, 80);
    photoButton1.tag = kPhotoButton_1;
    [photoButton1 setImage:bgImage forState:UIControlStateNormal];
    
    // button 2
    photoButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton2 addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchDown];
    photoButton2.imageView.contentMode = UIViewContentModeScaleAspectFill;
    photoButton2.frame = CGRectMake(110, 10, 100, 80);
    photoButton2.tag = kPhotoButton_2;
    [photoButton2 setImage:bgImage forState:UIControlStateNormal];
    
    // button 3
    photoButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton3 addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchDown];
    photoButton3.imageView.contentMode = UIViewContentModeScaleAspectFill;
    photoButton3.frame = CGRectMake(215, 10, 100, 80);
    photoButton3.tag = kPhotoButton_3;
    [photoButton3 setImage:bgImage forState:UIControlStateNormal];
    
    // now build the final container view for the photos
    photoContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    
    // now add all the buttons to the container view
    [photoContainerView addSubview:photoButton1];
    [photoContainerView addSubview:photoButton2];
    [photoContainerView addSubview:photoButton3];
}

- (void) loadListingImages {
    // first grab the listing images for the school
    NSMutableDictionary *schoolListingImages = [UDataCache.listingImageMedium objectForKey:[NSString stringWithFormat:@"%d", self.listing.schoolId]];
    
    // initialize the school listing image cache for the current school
    if(schoolListingImages == nil) {
        schoolListingImages = [[NSMutableDictionary alloc] init];
    }
    
    /*
     * iterate over the image urls and check to see if there is an image
     * for the url in the listing image cache.  If there ever is a case where there
     * isn't an image, we need to load it in the background with SDwebImage.
     */
    for (int idx = 0; idx < [self.listing.imageUrls count]; idx++) {
        // add the preview view to the photos form for this idx
        [self showPhotoPreviewView:idx];
        NSString *imageURL = [self.listing.imageUrls objectAtIndex:idx];
        NSArray* tokens = [imageURL componentsSeparatedByString: @"/"];
        NSString* imageFilename = [tokens objectAtIndex:([tokens count]-1)];
        
        // grab the event image from the listing cache
        UIImage *listingImage = [schoolListingImages objectForKey:imageFilename];
        if (listingImage == nil) {
            // set the key in the cache to let other processes know that this key is in work
            [schoolListingImages setValue:[NSNull null]  forKey:imageFilename];
            NSURL *url = [NSURL URLWithString:[URL_LISTING_IMAGE_MEDIUM stringByAppendingString:imageFilename]];
            __block ImageActivityIndicatorView *iActivityIndicator;
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            [imageDownloader downloadImageWithURL:url
                                          options:SDWebImageDownloaderProgressiveDownload
                                         progress:^(NSUInteger receivedSize, long long expectedSize) {
                                             if (!iActivityIndicator)
                                             {
                                                 iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
                                                 switch (idx) {
                                                     case 0:
                                                         [iActivityIndicator showActivityIndicator:previewPhotoView1];
                                                         break;
                                                     case 1:
                                                         [iActivityIndicator showActivityIndicator:previewPhotoView2];
                                                         break;
                                                     case 2:
                                                         [iActivityIndicator showActivityIndicator:previewPhotoView3];
                                                         break;
                                                 }
                                             }
                                         }
                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                            if (image && finished)
                                            {
                                                // add the event image to the image cache
                                                [schoolListingImages setValue:image forKey:imageFilename];
                                                // set the picture in the view
                                                switch (idx) {
                                                    case 0:
                                                        previewPhotoView1.previewImageView.image = image;
                                                        [iActivityIndicator showActivityIndicator:previewPhotoView1];
                                                        break;
                                                    case 1:
                                                        previewPhotoView2.previewImageView.image = image;
                                                        [iActivityIndicator showActivityIndicator:previewPhotoView2];
                                                        break;
                                                    case 2:
                                                        previewPhotoView3.previewImageView.image = image;
                                                        [iActivityIndicator showActivityIndicator:previewPhotoView3];
                                                        break;
                                                }
                                                iActivityIndicator = nil;
                                            }
                                        }];
        } else if (![listingImage isKindOfClass:[NSNull class]]){
            switch (idx) {
                case 0:
                    previewPhotoView1.previewImageView.image = listingImage;
                    break;
                case 1:
                    previewPhotoView2.previewImageView.image = listingImage;
                    break;
                case 2:
                    previewPhotoView3.previewImageView.image = listingImage;
                    break;
            }
        }
    } // end the looping of listing images
    
    // set the school listing images back in the cache
    [UDataCache.listingImageMedium setValue:schoolListingImages forKey:[NSString stringWithFormat:@"%d", self.listing.schoolId]];    
}
- (void) showPhotoPreviewView:(int)idx {
    switch (idx) {
        case 0:
            // set the image on the preview image view and show the image view
            if (previewPhotoView1 == nil) {
                previewPhotoView1 = [[PreviewPhotoView alloc] initWithBackgroundColor:[UIColor blackColor] frame:photoButton1.frame];
            }
            //previewPhotoView1.previewImageView.image = [self.listing.images objectAtIndex:idx];
            [previewPhotoView1 showPreviewPhoto:photoContainerView];
            break;
        case 1:
            // set the image on the preview image view and show the image view
            if (previewPhotoView2 == nil) {
                previewPhotoView2 = [[PreviewPhotoView alloc] initWithBackgroundColor:[UIColor blackColor] frame:photoButton2.frame];
                previewPhotoView2.frame = photoButton2.frame;
            }
            //previewPhotoView2.previewImageView.image = [self.listing.images objectAtIndex:idx];
            [previewPhotoView2 showPreviewPhoto:photoContainerView];
            break;
        case 2:
            // set the image on the preview image view and show the image view
            if (previewPhotoView3 == nil) {
                previewPhotoView3 = [[PreviewPhotoView alloc] initWithBackgroundColor:[UIColor blackColor] frame:photoButton3.frame];
            }
            //previewPhotoView3.previewImageView.image = [self.listing.images objectAtIndex:idx];
            [previewPhotoView3 showPreviewPhoto:photoContainerView];
            break;
    }
}

-(void) buildLocationRelatedViews {
    // address text field
    addressBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 10, 245, 47)];
    addressBgImageView.image = [UIImage imageNamed:@"ulink_mobile_input_field"];
    addressTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 22, 229, 47)];
    addressTextField.clearsOnBeginEditing = NO;
    addressTextField.delegate = self;
    addressTextField.placeholder = @"Address";
    addressTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    addressTextField.tag = kAddListingLocationAddress;
    // city text field
    cityBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 65, 245, 47)];
    cityBgImageView.image = [UIImage imageNamed:@"ulink_mobile_input_field"];
    cityTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 77, 229, 47)];
    cityTextField.clearsOnBeginEditing = NO;
    cityTextField.delegate = self;
    cityTextField.placeholder = @"City";
    cityTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    cityTextField.tag = kAddListingLocationCity;
    // state text field
    stateBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 120, 245, 47)];
    stateBgImageView.image = [UIImage imageNamed:@"ulink_mobile_input_field"];
    stateTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 132, 229, 47)];
    stateTextField.clearsOnBeginEditing = NO;
    stateTextField.delegate = self;
    stateTextField.placeholder = @"State";
    stateTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    stateTextField.tag = kAddListingLocationState;
    // zip text field
    zipBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 175, 122, 47)];
    zipBgImageView.image = [UIImage imageNamed:@"ulink_mobile_input_field_small"];
    zipTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 187, 114, 47)];
    zipTextField.clearsOnBeginEditing = NO;
    zipTextField.delegate = self;
    zipTextField.placeholder = @"Zip";
    zipTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    zipTextField.tag = kAddListingLocationZip;
    zipTextField.keyboardType = UIKeyboardTypeDecimalPad;
    // set the disclosure indicator to "off"
    discloseLocationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(37, 230, 160, 50)];
    discloseLocationSwitch.on = FALSE;
    [discloseLocationSwitch addTarget:self action:@selector(discloseChanged:) forControlEvents:UIControlEventValueChanged];
    
    // build disclosure label
    disclosureLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 220, 160, 50)];
    disclosureLabel.backgroundColor = [UIColor clearColor];
    disclosureLabel.textColor = [UIColor whiteColor];
    disclosureLabel.font = [UIFont fontWithName:FONT_GLOBAL size:16];
    disclosureLabel.text = @"Disclose my location";

    // set the values of the location (if present) on the form
    if(self.listing.location != nil) {
        addressTextField.text = self.listing.location.address1;
        cityTextField.text = self.listing.location.city;
        stateTextField.text = self.listing.location.state;
        zipTextField.text = self.listing.location.zip;
        discloseLocationSwitch.on = (self.listing.location.discloseLocation != nil && [self.listing.location.discloseLocation isEqualToString:@"TRUE"]);
    }
}
-(void) buildTitleTextField {
    titleBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 10, 245, 47)];
    titleBgImageView.image = [UIImage imageNamed:@"ulink_mobile_input_field"];
    listingTitleTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 22, 229, 47)];
    listingTitleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    listingTitleTextField.placeholder = @"Title";
    listingTitleTextField.tag = kTextFieldListingTitle;
    listingTitleTextField.clearsOnBeginEditing = NO;
    listingTitleTextField.delegate = self;
    
    if(self.listing.title != nil && ![self.listing.title isEqualToString:EMPTY_STRING]) {
        listingTitleTextField.text = self.listing.title;
    }
}

- (void) buildDescriptionField {
    descriptionBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 65, 248, 121)];
    descriptionBgImageView.image = [UIImage imageNamed:@"ulink_mobile_input_field_textarea"];
    descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(38, 65, 248, 108)];
    descriptionTextView.tag = kTextViewListingDescription;
    descriptionTextView.delegate = self;
    descriptionTextView.secureTextEntry = NO;
    descriptionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    descriptionTextView.font = [UIFont fontWithName:FONT_GLOBAL size:12.0f];
    descriptionTextView.textColor = [UIColor blackColor];
    descriptionTextView.backgroundColor = [UIColor clearColor];
    descriptionTextView.returnKeyType = UIReturnKeyDefault;
    
    if(self.listing.listDescription != nil && ![self.listing.listDescription isEqualToString:EMPTY_STRING]) {
        descriptionTextView.text = self.listing.listDescription;
    } else {
        descriptionTextView.text = @"Description";
    }
}
-(void) buildPriceTextField {
    priceBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(37, 10, 245, 47)];
    priceBgImageView.image = [UIImage imageNamed:@"ulink_mobile_input_field"];
    listingPriceTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 22, 229, 47)];
    listingPriceTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    listingPriceTextField.placeholder = @"Price";
    listingPriceTextField.tag = kTextFieldListingTitle;
    listingPriceTextField.clearsOnBeginEditing = NO;
    listingPriceTextField.delegate = self;
    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    if(self.listing.price > -1) {
        NSNumber *priceNumber = [NSNumber numberWithDouble:self.listing.price];
        listingPriceTextField.text = [priceNumber stringValue];
    }
    listingPriceTextField.keyboardType = UIKeyboardTypeDecimalPad;
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
    
    // tag 1
    tagImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(17, 30, 245, 47)];
    tagImageView1.image = textBgImage;
    tag1TextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 42, 229, 47)];
    tag1TextField.autocorrectionType = UITextAutocorrectionTypeNo;
    tag1TextField.placeholder = @"Tag";
    tag1TextField.tag = kTextFieldListingTag;
    tag1TextField.clearsOnBeginEditing = NO;
    tag1TextField.delegate = self;
 
    
    // tag 2
    tagImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(17, 90, 245, 47)];
    tagImageView2.image = textBgImage;
    tag2TextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 102, 229, 47)];
    tag2TextField.autocorrectionType = UITextAutocorrectionTypeNo;
    tag2TextField.placeholder = @"Tag";
    tag2TextField.tag = kTextFieldListingTag;
    tag2TextField.clearsOnBeginEditing = NO;
    tag2TextField.delegate = self;
   
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
    removeTag2Button.alpha = ALPHA_ZERO;
    
    
    // tag 3
    tagImageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(17, 150, 245, 47)];
    tagImageView3.image = textBgImage;
    tag3TextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 162, 229, 47)];
    tag3TextField.autocorrectionType = UITextAutocorrectionTypeNo;
    tag3TextField.placeholder = @"Tag";
    tag3TextField.tag = kTextFieldListingTag;
    tag3TextField.clearsOnBeginEditing = NO;
    tag3TextField.delegate = self;
  
    // initially hide the 3 tag
    tag3TextField.alpha = ALPHA_ZERO;
    tagImageView3.alpha = ALPHA_ZERO;
    // create the remove tag 3 button and add it to the view
    removeTag3Button = [UIButton buttonWithType:UIButtonTypeCustom];
    removeTag3Button.frame = CGRectMake(275, 158, 30, 30);
    removeTag2Button.tag = 3;
    [removeTag3Button setBackgroundImage:removeTagButtonImage forState:UIControlStateNormal];
    [removeTag3Button addTarget:self action:@selector(removeTag3) forControlEvents:UIControlEventTouchUpInside];
    removeTag3Button.alpha = ALPHA_ZERO;
    
    /*
     * now determine if there are tags set, and show the correct
     * text fields for the tags as necessary
     */
    if (self.listing.tags != nil && self.listing.tags.count > 0) {
        // iterate over the tags, showing and setting the views if there are extra tags
        for (int idx = 0; idx < self.listing.tags.count;  idx++) {
            NSString *tag = (NSString*)[self.listing.tags objectAtIndex:idx];
            if(idx == 0) {
                if(tag != nil && ![tag isEqualToString:EMPTY_STRING]) {
                    tag1TextField.text = tag;
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if ([listingTitleTextField isFirstResponder] && [touch view] != listingTitleTextField) {
        [listingTitleTextField  resignFirstResponder];
    } else if ([listingPriceTextField isFirstResponder] && [touch view] != listingPriceTextField) {
        [listingPriceTextField  resignFirstResponder];
    } else if ([descriptionTextView isFirstResponder] && [touch view] != descriptionTextView) {
        [descriptionTextView  resignFirstResponder];
    } else if ([tag1TextField isFirstResponder] && [touch view] != tag1TextField) {
        [tag1TextField  resignFirstResponder];
    } else if ([tag2TextField isFirstResponder] && [touch view] != tag2TextField) {
        [tag2TextField  resignFirstResponder];
    } else if ([tag3TextField isFirstResponder] && [touch view] != tag3TextField) {
        [tag3TextField  resignFirstResponder];
    } else if ([addressTextField isFirstResponder] && [touch view] != addressTextField) {
        [addressTextField  resignFirstResponder];
    } else if ([cityTextField isFirstResponder] && [touch view] != cityTextField) {
        [cityTextField  resignFirstResponder];
    } else if ([stateTextField isFirstResponder] && [touch view] != stateTextField) {
        [stateTextField  resignFirstResponder];
    } else if ([zipTextField isFirstResponder] && [touch view] != zipTextField) {
        [zipTextField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}
- (void)validateField:(int)tag {
    switch (tag) {
        case kTextViewListingDescription:
            if (descriptionTextView.text.length < 2 || [descriptionTextView.text isEqualToString:@"Description"]) {
                [validationErrors addObject:@"\nPlease enter your description"];
            } else {
                [validationErrors removeObject:@"\nPlease enter your description"];
            }
            break;
        case kTextFieldListingTitle:
            listingTitleTextField.text = [UTextUtil trimWhitespace:listingTitleTextField.text];
            if (listingTitleTextField.text.length < 1 || [listingTitleTextField.text isEqualToString:EMPTY_STRING]) {
                [validationErrors addObject:@"\nPlease enter your title"];
            } else {
                [validationErrors removeObject:@"\nPlease enter your title"];
            }
            break;
        case kTextFieldListingPrice: {
            // trim the text
            listingPriceTextField.text = [UTextUtil trimWhitespace:listingPriceTextField.text];
            NSNumber *price = [NSNumber numberWithDouble:[listingPriceTextField.text doubleValue]];
            listingPriceTextField.text = [numberFormatter stringFromNumber:price];
            // validate that the value is a number
            if (listingPriceTextField.text.length < 1 || [listingPriceTextField.text isEqualToString:EMPTY_STRING] || ![UTextUtil isDigitsOnly:listingPriceTextField.text]) {
                [validationErrors addObject:@"\nPlease enter a valid price"];
            } else {
                [validationErrors removeObject:@"\nPlease enter a valid price"];
            }
        }
            break;
        case kTextFieldListingTag:
            // trim the text on the tags
            tag1TextField.text = [UTextUtil trimWhitespace:tag1TextField.text];
            tag2TextField.text = [UTextUtil trimWhitespace:tag2TextField.text];
            tag3TextField.text = [UTextUtil trimWhitespace:tag3TextField.text];
            if (validateTags && numberOfTags == kListingTagLimitNumber) {
                [validationErrors addObject:@"\nYou can only enter up to three tags"];
            } else {
                [validationErrors removeObject:@"\nYou can only enter up to three tags"];
            }
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark -
#pragma mark Image Processing
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    switch (activePhotoButton) {
        case 1:
            // set the image on the preview image view and show the image view
            if (previewPhotoView1 == nil) {
                previewPhotoView1 = [[PreviewPhotoView alloc] initWithBackgroundColor:[UIColor blackColor] frame:photoButton1.frame];
            }
            previewPhotoView1.previewImageView.image = image;
            [previewPhotoView1 showPreviewPhoto:photoContainerView];
            break;
        case 2:
            // set the image on the preview image view and show the image view
            if (previewPhotoView2 == nil) {
                previewPhotoView2 = [[PreviewPhotoView alloc] initWithBackgroundColor:[UIColor blackColor] frame:photoButton2.frame];
                previewPhotoView2.frame = photoButton2.frame;
            }
            previewPhotoView2.previewImageView.image = image;
            [previewPhotoView2 showPreviewPhoto:photoContainerView];
            break;
        case 3:
            // set the image on the preview image view and show the image view
            if (previewPhotoView3 == nil) {
                previewPhotoView3 = [[PreviewPhotoView alloc] initWithBackgroundColor:[UIColor blackColor] frame:photoButton3.frame];
            }
            previewPhotoView3.previewImageView.image = image;
            [previewPhotoView3 showPreviewPhoto:photoContainerView];
            break;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.view endEditing:YES];
    btnSave.enabled = TRUE;
    listingImagesChanged = TRUE;
}
#pragma mark -
#pragma mark Actions
- (void)showActionSheet:(id)sender {
    activePhotoButton = ((UIButton*)sender).tag;
    [photoActionSheet showInView:self.view];
}

#pragma mark TextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    btnSave.enabled = TRUE;
    BOOL retVal = NO;
    if([string isEqualToString:@" "]) {
        retVal = !(textField.tag == kTextFieldListingTag);
    } else if([string isEqualToString:EMPTY_STRING]) {
        retVal = YES;
    } else {
        switch (textField.tag) {
            case kTextFieldListingTitle:
                retVal = textField.text.length < 255;
                break;
            case kTextFieldListingPrice:
                retVal = textField.text.length < 8;
                break;
            case kTextFieldListingTag:
                retVal = textField.text.length < 25;
                break;
            case kAddListingLocationZip:
                retVal = textField.text.length < 5;
                break;
            default:
                retVal = textField.text.length < 255;
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
        descriptionTextView.text = EMPTY_STRING;
    }
    return TRUE;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL retVal = NO;
    btnSave.enabled = TRUE;
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    if([text isEqualToString:EMPTY_STRING]) {
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
    if(buttonIndex == 1) {
        [self.listing deleteListing:nil];
        [successNotification setMessage:@"Listing Deleted."];
        [successNotification showNotification:self.view];
        // pop the controller
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(popController) userInfo:nil repeats:NO];
    }
}
#pragma mark -
#pragma mark Cell Building Functions
-(UITableViewCell*) buildTitleDescriptionCell:(UITableViewCell*)cell {
    // clear any old subviews from the form since they are reused
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#EDB232"];
    // add the text properties
    cell.textLabel.text = @"Title & Description";
    //[cell.textLabel.superview addSubview:bgColor];
    return cell;
}

-(UITableViewCell*) buildTitleDescriptionFormCell:(UITableViewCell*)cell {
    // clear any old subviews from the form since they are reused
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // clear the text label since the cell is reused
    cell.textLabel.text = EMPTY_STRING;
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    // add the text and text view for title and description
    [cell.contentView addSubview:titleBgImageView];
    [cell.contentView addSubview:listingTitleTextField];
    [cell.contentView addSubview:descriptionBgImageView];
    [cell.contentView addSubview:descriptionTextView];
    return cell;
}

-(UITableViewCell*) buildPhotosListingCell:(UITableViewCell*)cell {
    // clear any old subviews from the form since they are reused
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#1E98D9"];
    // add the text properties
    cell.textLabel.text = @"Photos";
    return cell;
}

-(UITableViewCell*) buildPhotosListingFormCell:(UITableViewCell*)cell {
    // clear any old subviews from the form since they are reused
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // clear the text label since the cell is reused
    cell.textLabel.text = EMPTY_STRING;
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    [cell.contentView addSubview:photoContainerView];
    // now check to see if there are already images on the listing, if so show them in preview mode
    [self loadListingImages];
    return cell;
}

-(UITableViewCell*) buildPriceListingCell:(UITableViewCell*)cell {
    // clear any old subviews from the form since they are reused
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#38A640"];
    // add the text properties
    cell.textLabel.text = @"Price";
    return cell;
}
-(UITableViewCell*) buildPriceListingFormCell:(UITableViewCell*)cell {
    // clear any old subviews from the form since they are reused
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // clear the text label since the cell is reused
    cell.textLabel.text = EMPTY_STRING;
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    // add the text and text view for title and description
    [cell.contentView addSubview:priceBgImageView];
    [cell.contentView addSubview:listingPriceTextField];
    return cell;
}
-(UITableViewCell*) buildLocationListingCell:(UITableViewCell*)cell {
    // clear any old subviews from the form since they are reused
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#975FC2"];
    // add the text properties
    cell.textLabel.text = @"Location";
   return cell; 
}
-(UITableViewCell*) buildLocationListingFormCell:(UITableViewCell*)cell {
    // clear any old subviews from the form since they are reused
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // clear the text label since the cell is reused
    cell.textLabel.text = EMPTY_STRING;
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    // add the text properties
    [cell.contentView addSubview:zipBgImageView];
    [cell.contentView addSubview:zipTextField];
    [cell.contentView addSubview:stateBgImageView];
    [cell.contentView addSubview:stateTextField];
    [cell.contentView addSubview:addressBgImageView];
    [cell.contentView addSubview:addressTextField];
    [cell.contentView addSubview:cityBgImageView];
    [cell.contentView addSubview:cityTextField];
    [cell.contentView addSubview:discloseLocationSwitch];
    [cell.contentView addSubview:disclosureLabel];
    return cell;
}
-(UITableViewCell*) buildTagsListingCell:(UITableViewCell*)cell {
    // clear any old subviews from the form since they are reused
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#6B64B0"];
    // add the text properties
    cell.textLabel.text = @"Tags";
    return cell;
}
-(UITableViewCell*) buildTagsListingFormCell:(UITableViewCell*)cell {
    // clear any old subviews from the form since they are reused
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // clear the text label since the cell is reused
    cell.textLabel.text = EMPTY_STRING;
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    [cell.contentView addSubview:addTagButton];
    [cell.contentView addSubview:tagImageView1];
    [cell.contentView addSubview:tag1TextField];
    [cell.contentView addSubview:tagImageView2];
    [cell.contentView addSubview:tag2TextField];
    [cell.contentView addSubview:removeTag2Button];
    [cell.contentView addSubview:tagImageView3];
    [cell.contentView addSubview:tag3TextField];
    [cell.contentView addSubview:removeTag3Button];
    return cell;
}

-(UITableViewCell*) buildDeleteListingCell:(UITableViewCell*)cell {
    // clear any old subviews from the form since they are reused
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#990000"];
    // add the text properties
    cell.textLabel.text = @"Delete";
    // set the cell tag
    cell.tag = kListingSaveDeleteCell;
    return cell;
}
#pragma mark - 
#pragma mark - Table view data source
- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat retVal = defaultCellHeight;
    // grab the selected index path
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    // if the selected indexpath row is the previous row, then we need to expand this form cell
        // show the form for the selected cell
    if (selectedIndexPath != nil && selectedIndexPath.row == indexPath.row-1) {
        switch (indexPath.row) {
            case 1: 
                retVal = 200;
                break;
            case 3: retVal = 150;
                break;
            case 5: retVal = 270;
                break;
            case 7:
                retVal = 225;
                break;
            case 9: retVal = 67;
                break;
        }
    } else {
        switch (indexPath.row) {
            case 1:
            case 3:
            case 5:
            case 7:
            case 9:
                retVal = 0;
            break;
        }
    }
    return retVal;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int retVal = 1;
    if (self.saveMode == kListingSaveTypeAdd) {
        if(listingHasPrice) {
            retVal = 11;
        } else {
            retVal = 9;
        }
    } else {
        if(listingHasPrice) {
            retVal = 11;
        } else {
            retVal = 9;
        }
    }
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = CELL_LISTING_SAVE_CELL;
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.clipsToBounds = YES;
        cell.textLabel.font = [UIFont fontWithName:FONT_GLOBAL size:20.0f];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, defaultCellHeight);
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }
    // build the base rows
    switch (indexPath.row) {
        case 0: cell = [self buildTitleDescriptionCell:cell];
            break;
        case 1: cell = [self buildTitleDescriptionFormCell:cell];
            break;
        case 2: cell = [self buildPhotosListingCell:cell];
            break;
        case 3: cell = [self buildPhotosListingFormCell:cell];
            break;
        case 4: cell = [self buildLocationListingCell:cell];
            break;
        case 5: cell = [self buildLocationListingFormCell:cell];
            break;
        case 6: cell = [self buildTagsListingCell:cell];
            break;
        case 7: cell = [self buildTagsListingFormCell:cell];
            break;
    }
    // if we are in add mode we can build the "Add On" cell
    if(self.saveMode == kListingSaveTypeAdd) {
        if(listingHasPrice) {
            switch (indexPath.row) {
                // add the price cell if necessary
                case 8: cell = [self buildPriceListingCell:cell];
                    break;
                case 9: cell = [self buildPriceListingFormCell:cell];
                    break;
                // finally build the delete listing cell if necessary
                case 10: cell = [self buildDeleteListingCell:cell];
                    break;
            }
        } else {
            // finally build the delete listing cell if necessary
            if(indexPath.row == 8) {
                cell = [self buildDeleteListingCell:cell];
            }
        }
    } else {
        /* since we are just editing, we will not have the Add Ons here, only for when the user creates a new listing
         */
        if(listingHasPrice) {
            switch (indexPath.row) {
                    // add the price cell if necessary
                case 8: cell = [self buildPriceListingCell:cell];
                    break;
                case 9: cell = [self buildPriceListingFormCell:cell];
                    break;
                    // finally build the delete listing cell if necessary
                case 10: cell = [self buildDeleteListingCell:cell];
                    break;
            }
        } else {
            // finally build the delete listing cell if necessary
            if(indexPath.row == 8) {
                cell = [self buildDeleteListingCell:cell];
            }
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // first close any open keypads
    [self.view endEditing:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    /*
     * 2.  If delete cell was clicked, we then show the alert for the user to confirm the deletion
     */
    if(cell.tag == kListingSaveDeleteCell) {
        [deleteAlertView show];
    } else {
        if(![indexPath isEqual:previouslySelectedIndexPath]) {
            // simply toggle the size of the cell based on the cell type
            // we need these lines below to show the cell change animations, and to rebuild the tableview
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            previouslySelectedIndexPath = indexPath;
        } else {
            
        }
    }
}
#pragma mark Actions
- (void) discloseChanged:(id)sender {
    btnSave.enabled = TRUE;
}
- (void) addTag {
    // make sure we haven't hit our tag limit number
    validateTags = TRUE;
    [self validateField:kTextFieldListingTag];
    if([validationErrors count] > 0) {
        errorAlertView.message = EMPTY_STRING;
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
-(void) saveClick {
    [self.view endEditing:YES];
    if(self.saveMode == kListingSaveTypeAdd) {
        // TODO: navigate to the Add Ons screen
    } else {
        // validate all necessary fields
        [self validateField:kTextFieldListingTitle];
        [self validateField:kTextViewListingDescription];
        // we don't need to validate the number of tags here so we set validateTags to false
        validateTags = FALSE;
        [self validateField:kTextFieldListingTag];
        
        // validate price if the listing has it
        if(listingHasPrice) {
            [self validateField:kTextFieldListingPrice];
        }
        if([validationErrors count] > 0) {
            errorAlertView.message = @"";
            for (NSString *error in validationErrors) {
                errorAlertView.message = [errorAlertView.message stringByAppendingString:error];
            }
            [errorAlertView show];
            return;
        }
        
        self.listing.listDescription = descriptionTextView.text;
        self.listing.title = listingTitleTextField.text;
        if(listingHasPrice) {
            listing.price = [listingTitleTextField.text doubleValue];
        }

        // check to see if there are tags, if so add a tag for each to the listing tags array
        if(tag1TextField.text != nil && ![tag1TextField.text isEqualToString:EMPTY_STRING]) {
            // check to see if the listing already has items, if so just insert
            self.listing.tags = nil;
            self.listing.tags = [[NSMutableArray alloc] init];
            [self.listing.tags addObject:tag1TextField.text];
            if(tag2TextField.text != nil && ![tag2TextField.text isEqualToString:EMPTY_STRING]) {
                [self.listing.tags addObject:tag2TextField.text];
            }
            if(tag3TextField.text != nil && ![tag3TextField.text isEqualToString:EMPTY_STRING]) {
                [self.listing.tags addObject:tag3TextField.text];
            }
        }

        // if the image changes, we need to put the images on the images list so that we can save it
        if(listingImagesChanged) {
            // Remove all images for this listing from the listing image cache
            for (NSString *imageURL in self.listing.imageUrls) {
                [UDataCache removeListingImage:imageURL schoolId:self.listing.schoolId cacheModel:IMAGE_CACHE_LISTING_MEDIUM];
                [UDataCache removeListingImage:imageURL schoolId:self.listing.schoolId cacheModel:IMAGE_CACHE_LISTING_THUMBS];
            }
            // set each of the images in the preview views on the images array
            if(self.listing.images != nil) {
                [self.listing.images removeAllObjects];
            } else {
                // check to see if images are already on the listing, if so clear the images array
                self.listing.images = [[NSMutableArray alloc] init];
            }
            
            // now add each new photo as necessary
            if(previewPhotoView1.previewImageView.image != nil) {
                [self.listing.images addObject:previewPhotoView1.previewImageView.image];
            }
            if(previewPhotoView2.previewImageView.image != nil) {
                [self.listing.images addObject:previewPhotoView2.previewImageView.image];
            } if(previewPhotoView3.previewImageView.image != nil) {
                [self.listing.images addObject:previewPhotoView3.previewImageView.image];
            }
        }
        // set the location changes, so if there is an existing location, set it to nil and create a new location
        self.listing.location = [[Location alloc] init];
        // set the address, city, state, and disclose indicator on the listing
        
        if (addressTextField != nil) {
            // trim the field
            addressTextField.text = [UTextUtil trimWhitespace:addressTextField.text];
            listing.location.address1 = addressTextField.text;
        }
        if (cityTextField != nil) {
            // trim the field
            cityTextField.text = [UTextUtil trimWhitespace:cityTextField.text];
            listing.location.city = cityTextField.text;
        }
        if (stateTextField != nil) {
            // trim the field
            stateTextField.text = [UTextUtil trimWhitespace:stateTextField.text];
            listing.location.state = stateTextField.text;
        }
        if (zipTextField != nil) {
            // trim the field
            zipTextField.text = [UTextUtil trimWhitespace:zipTextField.text];
            listing.location.zip = zipTextField.text;
        }
        self.listing.location.discloseLocation = (discloseLocationSwitch.on) ? @"TRUE" : @"FALSE";
        
        // finally submit the listing
        [self submitListing];
    }
}
-(void) submitListing {
    @try {
        self.view.userInteractionEnabled = NO;
        [activityIndicator showActivityIndicator:self.view];
        NSString *listingJSON = [self.listing getJSON];
        btnSave.enabled = FALSE;
        NSString *url = [URL_SERVER_3737 stringByAppendingString:API_ULIST_LISTINGS];
        url = [url stringByAppendingString:self.listing._id];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSData *requestData = [NSData dataWithBytes:[listingJSON UTF8String] length:[listingJSON length]];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
        [req setHTTPBody: requestData];
        [req setHTTPMethod:HTTP_PUT];
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t postListingQueue = dispatch_queue_create(DISPATCH_ULIST_LISTING, NULL);
        dispatch_async(postListingQueue, ^{
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
                        if(((NSHTTPURLResponse*)response).statusCode == 200) {
                            // set the new id on the listing
                             [successNotification showNotification:self.view];
                        } else {
                            self.view.userInteractionEnabled = YES;
                            btnSave.enabled = TRUE;
                            NSString* errorText = (NSString*)[json objectForKey:@"error"];
                            if (errorText != nil && ![errorText isEqualToString:@""] ) {
                                errorAlertView.message = errorText;
                            } else {
                                errorAlertView.message = @"There was a problem submitting your listing.  Please try again later or contact help@theulink.com.";
                            }
                            [errorAlertView show];
                        }
                    } else {
                        btnSave.enabled = TRUE;
                        errorAlertView.message = @"There was a problem submitting your listing.  Please try again later or contact help@theulink.com.";
                        // show alert to user
                        [errorAlertView show];
                    }
                });
            }];
        });
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        btnSave.enabled = TRUE;
        // show alert to user
        [errorAlertView show];
    }
}
- (void) popController {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
@end
