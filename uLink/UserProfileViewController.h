//
//  UserProfileViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 12/3/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@interface UserProfileViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) User *user;
- (IBAction)closeClick:(UIBarButtonItem *)sender;
- (IBAction)changePage:(UIPageControl *)sender;
@end
