//
//  UCampusMenuViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/19/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UCampusMenuViewController.h"
#import "MainTabBarViewController.h"
#import "UListSchoolHomeMenuViewController.h"
#import "MFSideMenu.h"
#import "AppDelegate.h"
#import "AppMacros.h"
#import "UCampusMenuCell.h"
#import "UListMenuCell.h"
#import "DataCache.h"
#import "UListCategory.h"


@interface UCampusMenuViewController () {
    UIView *overlay;
    NSMutableArray *data;
    UIFont *cellFont;
    UIFont *cellFontBold;
}
@end

@implementation UCampusMenuViewController
@synthesize sideMenu;
@synthesize mode;
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
    cellFont = [UIFont fontWithName:FONT_GLOBAL size:15.0f];
    cellFontBold = [UIFont fontWithName:FONT_GLOBAL_BOLD size:15.0f];
    
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
    //NSLog(@"view will appear. mode is %@", self.mode);
    [overlay removeFromSuperview];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int retVal = 0;
    
    if ([mode isEqualToString:@"uCampus"]) {
        retVal = 1;
    }
    else if ([mode isEqualToString:@"uList"]) {
        retVal = [UDataCache.uListCategorySections count];
    }

    return retVal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int retVal = 0;
    
    if ([mode isEqualToString:@"uCampus"]) {
        retVal = 3;
    }
    else if ([mode isEqualToString:@"uList"]) {
        NSString *key = [UDataCache.uListCategorySections objectAtIndex:section];
        NSMutableArray *subcategories = [UDataCache.uListCategories mutableArrayValueForKey:key];
        //NSLog(@"%@", subcategories);
        retVal = [subcategories count];
    }

    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    int section = [indexPath section];
    
    //NSLog(@"%@", mode);
    
    if ([mode isEqualToString:@"uCampus"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UCampusMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Events";
                ((UCampusMenuCell*)cell).iconImage = [UIImage imageNamed:@"ulink-mobile-campus-events-icon.png"];
                cell.tag = 0;
                break;
            case 1:
                cell.textLabel.text = @"Snapshots";
                ((UCampusMenuCell*)cell).iconImage = [UIImage imageNamed:@"ulink-mobile-snapshots-icon.png"];
                cell.tag = 1;
                break;
            case 2:
                cell.textLabel.text = @"Social Media";
                ((UCampusMenuCell*)cell).iconImage = [UIImage imageNamed:@"ulink-mobile-social-icon.png"];
                cell.tag = 2;
                break;
            default:
                break;
        }
        
        [(UCampusMenuCell*)cell layoutSubviews];
        [(UCampusMenuCell*)cell setEnabled:YES];
    }
    else if ([mode isEqualToString:@"uList"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UListMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        NSString *categoryKey = [UDataCache.uListCategorySections objectAtIndex:section];
        NSMutableArray *categories = [UDataCache.uListCategories objectForKey:categoryKey];
        UListCategory *category = [categories objectAtIndex:indexPath.row];
        //((UListMenuCell*)cell).iconImage = [UIImage imageNamed:@"ulink-mobile-campus-events-icon.png"];
        ((UListMenuCell*)cell).iconImage = nil;
        ((UListMenuCell*)cell).textLabel.text = category.name;
        [(UListMenuCell*)cell layoutSubviews];
        [(UListMenuCell*)cell setEnabled:YES];
    }
    
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
    
    if ([mode isEqualToString:@"uCampus"]) {
        // grab the UCampusViewController from the MainTabBarViewController
        MainTabBarViewController *tabBarController = (MainTabBarViewController*)[UAppDelegate getMainTabBarViewController];
        id uCampusViewController = [[tabBarController viewControllers] objectAtIndex:0];
        if ([uCampusViewController respondsToSelector:@selector(performSegue:)]) {
            [uCampusViewController performSegue:selectedCell.tag];
        }
    }
    
    if ([mode isEqualToString:@"uList"]) {
        UListSchoolHomeMenuViewController *uListSchoolHomeController = (UListSchoolHomeMenuViewController*)[UAppDelegate getUListSchoolHomeViewController];
        //NSLog(@"%@", [UAppDelegate getUListSchoolHomeViewController]);
        if ([(id)uListSchoolHomeController respondsToSelector:@selector(performSegue:)]) {
            [(id)uListSchoolHomeController performSegue:selectedCell.tag];
        }
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    view = [self createSectionView:[UDataCache.uListCategorySections objectAtIndex:section]];
    return view;
}

- (UIView*)createSectionView:(NSString*)category {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    view.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.6f];
    UILabel *sectionLabel = [[UILabel alloc] init];
    sectionLabel.frame = CGRectMake(0, 0, 300, 15);
    sectionLabel.textColor = [UIColor whiteColor];
    sectionLabel.font = cellFontBold;
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.shadowColor = [UIColor blackColor];
    sectionLabel.shadowOffset = CGSizeMake(0.0f, -0.5f);
    sectionLabel.text = category;
    [view addSubview:sectionLabel];
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 0.1)];
    bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
    [view addSubview:bottomLine];
    return view;
}



@end
