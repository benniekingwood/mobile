//
//  SocialViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/13/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UISwitch *twitterEnabledSwitch;
@property (strong, nonatomic) IBOutlet UITextField *twitterUserNameTextField;
- (IBAction)twitterEnabledChange:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)saveClick:(id)sender;

@end
