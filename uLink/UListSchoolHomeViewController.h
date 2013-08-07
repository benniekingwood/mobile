//
//  UListSchoolHomeViewController.h
//  ulink
//
//  Created by Bennie Kingwood on 4/17/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCampusMenuViewController.h"
#import "School.h"
@interface UListSchoolHomeViewController : UIViewController <UCampusMenuViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) School *school;
@end
