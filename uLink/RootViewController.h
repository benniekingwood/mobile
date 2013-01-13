//
//  RootViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/14/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UlinkButton.h"

@interface RootViewController : UIViewController {
    IBOutlet UlinkButton *signUpButton;
    IBOutlet UlinkButton *loginInButton;
}
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView1;
@end
