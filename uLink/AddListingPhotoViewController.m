//
//  AddListingPhotoViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 7/14/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "AddListingPhotoViewController.h"
#import "PreviewPhotoView.h"
#import "UlinkButton.h"

@interface AddListingPhotoViewController () {
    UIBarButtonItem *btnSave;
    UIImagePickerController *imagePicker;
    PreviewPhotoView *previewPhotoView1;
    PreviewPhotoView *previewPhotoView2;
    PreviewPhotoView *previewPhotoView3;
    UIButton *photoButton1;
    UIButton *photoButton2;
    UIButton *photoButton3;
    UIActionSheet *photoActionSheet;
    int activePhotoButton;
}
- (void) showNewImages;
@end

@implementation AddListingPhotoViewController
const int kPhotoButton1 = 1;
const int kPhotoButton2 = 2;
const int kPhotoButton3 = 3;
@synthesize listing;
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
    // set the controller title
	self.navigationItem.title = @"Photos";
    // make the background black to match the bg of the photo previews
    self.view.backgroundColor = [UIColor blackColor];
    // add the "Save" button
    btnSave = [[UIBarButtonItem alloc]
               initWithTitle:@"Done"
               style:UIBarButtonItemStylePlain
               target:self
               action:@selector(saveClick:)];
    self.navigationItem.rightBarButtonItem = btnSave;
    
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
    
    // create each of the photo buttons
    UIImage *bgImage = [UIImage imageNamed:@"icon-camera-large"];
    photoButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton1 addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchDown];
    photoButton1.imageView.contentMode = UIViewContentModeScaleAspectFill;
    photoButton1.frame = CGRectMake(5, 10, 100, 80);
    photoButton1.tag = kPhotoButton1;
    [photoButton1 setImage:bgImage forState:UIControlStateNormal];
    [self.view addSubview:photoButton1];

    // button 2
    photoButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton2 addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchDown];
    photoButton2.imageView.contentMode = UIViewContentModeScaleAspectFill;
    photoButton2.frame = CGRectMake(110, 10, 100, 80);
    photoButton2.tag = kPhotoButton2;
    [photoButton2 setImage:bgImage forState:UIControlStateNormal];
    [self.view addSubview:photoButton2];

    // button 3
    photoButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton3 addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchDown];
    photoButton3.imageView.contentMode = UIViewContentModeScaleAspectFill;
    photoButton3.frame = CGRectMake(215, 10, 100, 80);
    photoButton3.tag = kPhotoButton3;
    [photoButton3 setImage:bgImage forState:UIControlStateNormal];
    [self.view addSubview:photoButton3];
    
    // now check to see if there are already images on the listing, if so show them in preview mode
    [self showNewImages];
}
- (void) showNewImages {
    if(self.listing.images != nil) {
        for (int idx=0; idx<[self.listing.images count]; idx++) {
            switch (idx) {
                case 0:
                    // set the image on the preview image view and show the image view
                    if (previewPhotoView1 == nil) {
                        previewPhotoView1 = [[PreviewPhotoView alloc] initWithBackgroundColor:[UIColor blackColor] frame:photoButton1.frame];
                    }
                    previewPhotoView1.previewImageView.image = [self.listing.images objectAtIndex:idx];
                    [previewPhotoView1 showPreviewPhoto:self.view];
                    break;
                case 1:
                    // set the image on the preview image view and show the image view
                    if (previewPhotoView2 == nil) {
                        previewPhotoView2 = [[PreviewPhotoView alloc] initWithBackgroundColor:[UIColor blackColor] frame:photoButton2.frame];
                        previewPhotoView2.frame = photoButton2.frame;
                    }
                    previewPhotoView2.previewImageView.image = [self.listing.images objectAtIndex:idx];
                    [previewPhotoView2 showPreviewPhoto:self.view];
                    break;
                case 2:
                    // set the image on the preview image view and show the image view
                    if (previewPhotoView3 == nil) {
                        previewPhotoView3 = [[PreviewPhotoView alloc] initWithBackgroundColor:[UIColor blackColor] frame:photoButton3.frame];
                    }
                    previewPhotoView3.previewImageView.image = [self.listing.images objectAtIndex:idx];
                    [previewPhotoView3 showPreviewPhoto:self.view];
                    break;
            }
            
        }
    }
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
            [previewPhotoView1 showPreviewPhoto:self.view];
            break;
        case 2:
            // set the image on the preview image view and show the image view
            if (previewPhotoView2 == nil) {
                previewPhotoView2 = [[PreviewPhotoView alloc] initWithBackgroundColor:[UIColor blackColor] frame:photoButton2.frame];
                previewPhotoView2.frame = photoButton2.frame;
            }
            previewPhotoView2.previewImageView.image = image;
            [previewPhotoView2 showPreviewPhoto:self.view];
            break;
        case 3:
            // set the image on the preview image view and show the image view
            if (previewPhotoView3 == nil) {
                previewPhotoView3 = [[PreviewPhotoView alloc] initWithBackgroundColor:[UIColor blackColor] frame:photoButton3.frame];
            }
            previewPhotoView3.previewImageView.image = image;
            [previewPhotoView3 showPreviewPhoto:self.view];
            break;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.view endEditing:YES];
}
#pragma mark -
#pragma mark Actions
- (void)showActionSheet:(id)sender {
    activePhotoButton = ((UIButton*)sender).tag;
    [photoActionSheet showInView:self.view];
}
- (void) saveClick:(id)sender {
    btnSave.enabled = FALSE;
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
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
