//
//  UserProfileViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 12/3/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@interface UserProfileViewController : UIViewController
@property (weak, nonatomic) User *user;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) IBOutlet UILabel *schoolLabel;
@property (strong, nonatomic) IBOutlet UILabel *schoolStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *gradYearLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeButton;
- (IBAction)closeClick:(id)sender;
@end
