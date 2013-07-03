//
//  UListSchoolHomeViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 4/17/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListSchoolHomeViewController.h"
#import "UListSchoolCategoryViewController.h"
#import "AppDelegate.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "UListMenuCell.h"
#import "ListingSearchViewController.h"

@interface UListSchoolHomeViewController () {
    UIBarButtonItem *searchButton;
}
@end

@implementation UListSchoolHomeViewController
@synthesize school;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  use school short_name here
    self.navigationItem.title = self.school.shortName;
    self.navigationItem.hidesBackButton = YES;

    // add the "Search" button
    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchViewController)];
    self.navigationItem.rightBarButtonItem = btnSearch;
    
    // Activate side menu with uList 
    [UAppDelegate activateSideMenu:@"uList"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateView];
}

- (void)updateView {
    self.navigationItem.title = [self.school.shortName stringByAppendingString:@" uList"];
    //self.navigationItem.rightBarButtonItem = searchButton;
}

-(void) showSearchViewController {
    [self performSegueWithIdentifier:SEGUE_SHOW_LISTING_SEARCH_VIEW_CONTROLLER sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if([[item title] isEqualToString:@"uCampus"]) {
        self.navigationItem.title = @"uCampus";
        self.navigationItem.rightBarButtonItem = nil;
        [UAppDelegate activateSideMenu : @"uCampus"];
    } else if([[item title] isEqualToString:@"Me"]) {
        self.navigationItem.title = @"Me";
        [UAppDelegate deactivateSideMenu];
        // Send a notification
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROFILE_VIEW_CONTROLLER object:nil];
    } else if([[item title] isEqualToString:@"uList"]) {
        self.navigationItem.title = @"uList";
        self.navigationItem.rightBarButtonItem = nil;
        [UAppDelegate deactivateSideMenu];
    }
}

/*
 * Prepare for seque from Side Menu Bar Table View
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_ULIST_SCHOOL_LISTINGS_VIEW_CONTROLLER])
    {
        UListMenuCell *menuCell = (UListMenuCell*)sender;
        UListSchoolCategoryViewController *categoryViewController = [segue destinationViewController];
        categoryViewController.mainCat = menuCell.mainCat;
        categoryViewController.subCat = menuCell.subCat;
        categoryViewController.school = school;
    } else if ([[segue identifier] isEqualToString:SEGUE_SHOW_LISTING_SEARCH_VIEW_CONTROLLER]) {
        ListingSearchViewController *searchViewController = [segue destinationViewController];
        searchViewController.school = self.school;
    }
}

// NOTE: create category view
- (void)performSegue:(NSInteger)item {
    switch (item) {
        case 0:
            [self performSegueWithIdentifier:SEGUE_SHOW_ULIST_SCHOOL_LISTINGS_VIEW_CONTROLLER sender:self];
            break;
        default:
            [self performSegueWithIdentifier:SEGUE_SHOW_ULIST_SCHOOL_LISTINGS_VIEW_CONTROLLER sender:self];
            break;
    }
}

@end
