//
//  UListSchoolHomeMenuViewController.m
//  ulink
//
//  Created by Christopher Cerwinski on 4/23/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListSchoolHomeMenuViewController.h"
#import "MainTabBarViewController.h"
#import "MFSideMenu.h"
#import "AppDelegate.h"
#import "UListMenuCell.h"

@interface UListSchoolHomeMenuViewController () {
    UIView *overlay;
}
@end

@implementation UListSchoolHomeMenuViewController
@synthesize sideMenu;
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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    CGRect overlayFrame;
    overlayFrame.origin.x = 0;
    overlayFrame.origin.y = 0;
    overlayFrame.size = self.view.frame.size;
    overlay = [[UIView alloc] initWithFrame:overlayFrame];
    overlay.backgroundColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"side-menu-bg.png"]];
    self.tableView.separatorColor = [UIColor clearColor];
}

-(void)hideMenu {
    [self.view addSubview:overlay];
}
- (void)showMenu {
    [overlay removeFromSuperview];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections (use # of categories from db).
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section (calculate # of rows per category).
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UListMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UListMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Test";
            cell.iconImage = [UIImage imageNamed:@"ulink-mobile-campus-events-icon.png"];
            cell.tag = 0;
            break;
        case 1:
            cell.textLabel.text = @"Test";
            cell.iconImage = [UIImage imageNamed:@"ulink-mobile-snapshots-icon.png"];
            cell.tag = 1;
            break;
        default:
            break;
    }
    [cell layoutSubviews];
    [cell setEnabled:YES];
    return cell;

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(self.sideMenu.menuState == MFSideMenuStateVisible) {
        [self.sideMenu setMenuState:MFSideMenuStateHidden];
    } else {
        [self.sideMenu setMenuState:MFSideMenuStateVisible];
    }
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    // grab the UListSchoolHomeViewController from the MainTabBarViewController
    MainTabBarViewController *tabBarController = (MainTabBarViewController*)[UAppDelegate getMainTabBarViewController];
    id uListSchoolViewController = [[tabBarController viewControllers] objectAtIndex:0];
    if ([uListSchoolViewController respondsToSelector:@selector(performSegue:)]) {
        [uListSchoolViewController performSegue:selectedCell.tag];
    }
}

@end
