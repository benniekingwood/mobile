//
//  UListSchoolHomeViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 4/17/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "UListSchoolHomeMenuViewController.h"
#import "UCampusMenuViewController.h"
@interface UListSchoolHomeViewController : UIViewController <UCampusMenuViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (nonatomic) NSString *schoolId;
@property (nonatomic) NSString *schoolName;

@end
