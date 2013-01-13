//
//  MainTabBarViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/21/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "AppDelegate.h"
@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [UAppDelegate activateUCampusSideMenu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if([[item title] isEqualToString:@"uCampus"]) {
        self.navigationItem.title = @"uCampus";
        self.navigationItem.rightBarButtonItem = nil;
        [UAppDelegate activateUCampusSideMenu];
    } else {
        self.navigationItem.title = @"Me";
        [UAppDelegate deactivateUCampusSideMenu];
    }
}

@end
