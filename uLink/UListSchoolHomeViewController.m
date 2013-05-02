//
//  UListSchoolHomeViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 4/17/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListSchoolHomeViewController.h"
#import "AppDelegate.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "SelectCategoryCell.h"

@interface UListSchoolHomeViewController () {
    UIBarButtonItem *searchButton;
}
@end

@implementation UListSchoolHomeViewController
@synthesize schoolId, schoolName;
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
    
    // TODO: use school short_name here
    self.navigationItem.title = self.schoolName;
    self.navigationItem.hidesBackButton = YES;
    
    // Generate search button using custom created button from AppDelegate
    //searchButton = [[UIBarButtonItem alloc] initWithCustomView:[UAppDelegate createUIButtonNoBorder:@"options.png" method:@selector(showSearchViewController) target:self]];
    
    // Activate side menu with uList 
    [UAppDelegate activateSideMenu:@"uList"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateView];
}

- (void)updateView {
    self.navigationItem.title = self.schoolName;
    //self.navigationItem.rightBarButtonItem = searchButton;
}

-(void) showSearchViewController {
    //[self performSegueWithIdentifier:SEGUE_SHOW_SETTINGS_VIEW_CONTROLLER sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_ULIST_CATEGORY_VIEW_CONTROLLER])
    {
        SelectCategoryCell *cell = (SelectCategoryCell *)sender;
        UListSchoolHomeViewController *categoryViewController = [segue destinationViewController];
        //categoryViewController.categoryId = cell.schoolId;
        //categoryViewController.categoryName = cell.schoolName;
    }
}

// NOTE: create category view
- (void)performSegue:(NSInteger)item {
    switch (item) {
        case 0:
            [self performSegueWithIdentifier:SEGUE_SHOW_ULIST_CATEGORY_VIEW_CONTROLLER sender:self];
            break;
    }
}

@end
