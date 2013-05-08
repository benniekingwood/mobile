//
//  AppDelegate.h
//  uLink
//
//  Created by Bennie Kingwood on 11/7/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate> 
@property (strong, nonatomic) UIWindow *window;
-(void) activateSideMenu : (NSString*) mode;
-(void) deactivateSideMenu;
//-(void) activateUListSideMenu;
//-(void) deactivateUListSideMenu;
-(UITabBarController*) getMainTabBarViewController;
-(UIViewController*) getUListSchoolHomeViewController;
-(void) showActivityIndicator;
-(void) hideActivityIndicator;
-(UIButton*) createUIButtonNoBorder : (NSString*)imageName method:(SEL)selMethod target:(id)selTarget;
@end
