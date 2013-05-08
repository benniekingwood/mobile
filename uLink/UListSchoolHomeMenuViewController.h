//
//  UListSchoolHomeMenuViewController.h
//  ulink
//
//  Created by Christopher Cerwinski on 4/23/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"
@protocol UListSchoolHomeMenuViewControllerDelegate;
@protocol UListSchoolHomeMenuViewControllerDelegate <NSObject>
-(void) performSegue:(NSInteger)item;
@end

@interface UListSchoolHomeMenuViewController : UITableViewController
@property (nonatomic, assign) MFSideMenu *sideMenu;
@property (nonatomic, assign) id<UListSchoolHomeMenuViewControllerDelegate> delegate;

-(void)hideMenu;
-(void)showMenu;
@end
