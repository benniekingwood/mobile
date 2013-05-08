//
//  UListSchoolHomeViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 4/17/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCampusMenuViewController.h"
@interface UListSchoolHomeViewController : UIViewController <UCampusMenuViewControllerDelegate, UITabBarDelegate>
@property (strong, nonatomic) IBOutlet UIView *mainView;
//@property (strong, nonatomic) IBOutlet UITabBarController *tabController;
@property (nonatomic) NSString *schoolId;
@property (nonatomic) NSString *schoolName;

@end
