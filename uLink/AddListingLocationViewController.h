//
//  AddListingLocationViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 7/10/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"

@interface AddListingLocationViewController : UIViewController <UITextFieldDelegate>
- (IBAction)discloseChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *zipTextField;
@property (strong, nonatomic) IBOutlet UITextField *stateTextField;
@property (strong, nonatomic) IBOutlet UITextField *addressTextField;
@property (strong, nonatomic) IBOutlet UITextField *cityTextField;
@property (strong, nonatomic) IBOutlet UISwitch *discloseLocationSwitch;
@property (nonatomic, strong) Listing *listing;
@end
