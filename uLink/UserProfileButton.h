//
//  UserProfileButton.h
//  uLink
//
//  Created by Bennie Kingwood on 12/27/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@interface UserProfileButton : UIButton
@property (weak, nonatomic) User *user;
- (void) initialize;
@end
