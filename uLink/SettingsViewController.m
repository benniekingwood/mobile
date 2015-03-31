//
//  SettingsViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/29/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "UlinkButton.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "MainNavigationViewController.h"
#import <Pixate/Pixate.h>
@interface SettingsViewController () {
    UIButton *logoutButton;
}
- (void)logout;
- (void) hydrateInitialCaches;
@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect logoutButtonFrame  = CGRectMake(20, 310, 280, 50);
    logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutButton.frame = logoutButtonFrame;
    [logoutButton setTitle:@"Log out" forState:UIControlStateNormal];
    logoutButton.styleClass = @"btn red-button";
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:logoutButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) logout {
    [UDataCache removeLoginInfo];
    // clear all cache data
    [UDataCache clearCache];
    // remove the school image, NOTE: this can probably be removed once we add a schoolImage cache
    [UDataCache removeImage:KEY_SESSION_USER_SCHOOL cacheModel:IMAGE_CACHE];
    // pop back to the login screen 
    MainNavigationViewController *parent = (MainNavigationViewController*)self.presentingViewController;
    [parent popToRootViewControllerAnimated:NO];
    // rehydrate school cache in background 
    [self performSelectorInBackground:@selector(hydrateInitialCaches) withObject:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) hydrateInitialCaches {
    [UDataCache rehydrateSchoolCache:YES];
    [UDataCache hydrateSnapshotCategoriesCache:NO];
}

- (IBAction)doneClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
