//
//  UCampusMenuViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/19/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UCampusMenuViewController.h"
#import "MainTabBarViewController.h"
#import "MFSideMenu.h"
#import "AppDelegate.h"
#import "UCampusMenuCell.h"


@interface UCampusMenuViewController () {
    UIView *overlay;
}
@end

@implementation UCampusMenuViewController
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
    [super viewDidLoad];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UCampusMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UCampusMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Events";
            cell.iconImage = [UIImage imageNamed:@"ulink-mobile-campus-events-icon.png"];
            cell.tag = 0;
            break;
        case 1:
            cell.textLabel.text = @"Snapshots";
            cell.iconImage = [UIImage imageNamed:@"ulink-mobile-snapshots-icon.png"];
            cell.tag = 1;
            break;
        case 2:
            cell.textLabel.text = @"Social Media";
            cell.iconImage = [UIImage imageNamed:@"ulink-mobile-social-icon.png"];
            cell.tag = 2;
            break;
        default:
            break;
    }
    [cell layoutSubviews];
    [cell setEnabled:YES];
    return cell;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.sideMenu.menuState == MFSideMenuStateVisible) {
        [self.sideMenu setMenuState:MFSideMenuStateHidden];
    } else {
        [self.sideMenu setMenuState:MFSideMenuStateVisible];
    }
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    // grab the UCampusViewController from the MainTabBarViewController
    MainTabBarViewController *tabBarController = (MainTabBarViewController*)[UAppDelegate getMainTabBarViewController];
    id uCampusViewController = [[tabBarController viewControllers] objectAtIndex:0];
    if ([uCampusViewController respondsToSelector:@selector(performSegue:)]) {
        [uCampusViewController performSegue:selectedCell.tag];
    }
}

@end
