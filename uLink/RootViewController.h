//
//  RootViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/14/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityIndicatorView.h"
@interface RootViewController : UIViewController <UITextFieldDelegate> {
    NSString *currentPassword;
    NSString *username;
}
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView1;
@property (nonatomic) NSString *currentPassword;
@property (nonatomic) NSString *username;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
- (IBAction)loginClick:(id)sender;
- (void) login:(BOOL)relogin;
@end
