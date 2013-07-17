//
//  AddListingLocationViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 7/10/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "AddListingLocationViewController.h"
#import "AppMacros.h"
#import "TextUtil.h"

@interface AddListingLocationViewController () {
    UIBarButtonItem *btnSave;
}

@end

@implementation AddListingLocationViewController
@synthesize addressTextField;
@synthesize cityTextField;
@synthesize stateTextField;
@synthesize zipTextField;
@synthesize discloseLocationSwitch;
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
    self.navigationItem.title = @"Location";
    
    // initialize the listing if need be
    if(self.listing == nil) {
        self.listing = [[Listing alloc] init];
    }
    
	// address text field
    self.addressTextField.clearsOnBeginEditing = NO;
    self.addressTextField.delegate = self;
    self.addressTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.addressTextField.tag = kAddListingLocationAddress;
    // city text field
    self.cityTextField.clearsOnBeginEditing = NO;
    self.cityTextField.delegate = self;
    self.cityTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.cityTextField.tag = kAddListingLocationCity;
    // state text field
    self.stateTextField.clearsOnBeginEditing = NO;
    self.stateTextField.delegate = self;
    self.stateTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.stateTextField.tag = kAddListingLocationState;
    // zip text field
    self.zipTextField.clearsOnBeginEditing = NO;
    self.zipTextField.delegate = self;
    self.zipTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.zipTextField.tag = kAddListingLocationZip;
    self.zipTextField.keyboardType = UIKeyboardTypeDecimalPad;
    // set the disclosure indicator to "off"
    self.discloseLocationSwitch.on = FALSE;
    
    // build disclosure label
    UILabel *disclosureLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 237, 160, 50)];
    disclosureLabel.backgroundColor = [UIColor clearColor];
    disclosureLabel.textColor = [UIColor whiteColor];
    disclosureLabel.font = [UIFont fontWithName:FONT_GLOBAL size:16];
    disclosureLabel.text = @"Disclose my location";
    [self.view addSubview:disclosureLabel];
    
    // set the values of the location (if present) on the form
    if(self.listing.location != nil) {
        self.addressTextField.text = self.listing.location.address1;
        self.cityTextField.text = self.listing.location.city;
        self.stateTextField.text = self.listing.location.state;
        self.zipTextField.text = self.listing.location.zip;
        self.discloseLocationSwitch.on = (self.listing.location.discloseLocation != nil && [self.listing.location.discloseLocation isEqualToString:@"TRUE"]);
    }
    // add the "Save" button
    btnSave = [[UIBarButtonItem alloc]
               initWithTitle:@"Done"
               style:UIBarButtonItemStylePlain
               target:self
               action:@selector(saveClick:)];
    self.navigationItem.rightBarButtonItem = btnSave;
    btnSave.enabled = FALSE;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.addressTextField isFirstResponder] && [touch view] != self.addressTextField) {
        [self.addressTextField  resignFirstResponder];
    } else if ([self.cityTextField isFirstResponder] && [touch view] != self.cityTextField) {
        [self.cityTextField  resignFirstResponder];
    } else if ([self.stateTextField isFirstResponder] && [touch view] != self.stateTextField) {
        [self.stateTextField  resignFirstResponder];
    } else if ([self.zipTextField isFirstResponder] && [touch view] != self.zipTextField) {
        [self.zipTextField  resignFirstResponder];
    } 
    [super touchesBegan:touches withEvent:event];
}
#pragma mark Text Field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    btnSave.enabled = TRUE;
    BOOL retVal = NO;
    if([string isEqualToString:@""]) {
        retVal = YES;
    } else {
        if (textField.tag == kAddListingLocationZip) {
            retVal = textField.text.length < 5;
        } else {
            retVal = textField.text.length < 256;
        }
    }
    return retVal;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark -
#pragma mark Actions
- (void) saveClick:(id)sender {
    [self.view endEditing:YES];
    btnSave.enabled = FALSE;
    
    // if there is an existing location, set it to nil and create a new location
    self.listing.location = [[Location alloc] init];
    // set the address, city, state, and disclose indicator on the listing

    if (self.addressTextField != nil) {
        // trim the field
        self.addressTextField.text = [UTextUtil trimWhitespace:self.addressTextField.text];
        self.listing.location.address1 = self.addressTextField.text;
    }
    if (self.cityTextField != nil) {
        // trim the field
        self.cityTextField.text = [UTextUtil trimWhitespace:self.cityTextField.text];
        self.listing.location.city = self.cityTextField.text;
    }
    if (self.stateTextField != nil) {
        // trim the field
        self.stateTextField.text = [UTextUtil trimWhitespace:self.stateTextField.text];
        self.listing.location.state = self.stateTextField.text;
    }
    if (self.zipTextField != nil) {
        // trim the field
        self.zipTextField.text = [UTextUtil trimWhitespace:self.zipTextField.text];
        self.listing.location.zip = self.zipTextField.text;
    }
    self.listing.location.discloseLocation = (self.discloseLocationSwitch.on) ? @"TRUE" : @"FALSE";
    // go back
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)discloseChanged:(id)sender {
    btnSave.enabled = TRUE;
}
#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
