//
//  Home.h
//  uLink
//
//  Created by Bennie Kingwood on 11/7/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginViewController;

@interface HomeViewController : UINavigationController {
    LoginViewController *loginViewController;
}
@property (nonatomic, retain) LoginViewController *loginViewController;
- (IBAction)loginButtonClick;
@end
