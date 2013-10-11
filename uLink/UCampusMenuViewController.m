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
#import "ULinkColorPalette.h"
//#import "ImageUtil.h"


@interface UCampusMenuViewController () {
    UIView *overlay;
    NSMutableArray *data;
    NSArray *sectionTitles;
    UIFont *cellFont;
    UIFont *cellFontBold;
    NSMutableArray *sections;
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
    cellFontBold = [UIFont fontWithName:FONT_GLOBAL size:24.0f];
    
    CGRect overlayFrame;
    overlayFrame.origin.x = 0;
    overlayFrame.origin.y = 0;
    overlayFrame.size = self.view.frame.size;
    overlay = [[UIView alloc] initWithFrame:overlayFrame];
    overlay.backgroundColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor clearColor];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"side-menu-bg.png"]];
    self.view.backgroundColor = [UIColor uLinkWhiteColor];
    self.tableView.separatorColor = [UIColor clearColor];
    
    // next set the ulist categories to this local mutable array so we can add a cell for the "Add Listing" button
    [UDataCache.uListCategorySections removeObject:@""];
    sections = UDataCache.uListCategorySections;
    [sections insertObject:@"" atIndex:0];
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
        retVal = [sections count];
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
        NSString *key = [sections objectAtIndex:section];
        if([key isEqualToString:EMPTY_STRING]) {
            retVal = 1;
        } else {
            NSMutableArray *subcategories = [UDataCache.uListCategories mutableArrayValueForKey:key];
            retVal = [subcategories count];
        }
    }

    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = nil;
    int section = [indexPath section];
    if ([mode isEqualToString:@"uCampus"]) {
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UCampusMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Events";
                ((UCampusMenuCell*)cell).iconImage = [UIImage imageNamed:@"ulink-mobile-campus-events-icon.png"];
                ((UCampusMenuCell*)cell).imageView.backgroundColor = [UIColor uLinkBlueColor];
                cell.tag = 0;
                break;
            case 1:
                cell.textLabel.text = @"Snapshots";
                ((UCampusMenuCell*)cell).iconImage = [UIImage imageNamed:@"ulink-mobile-snapshots-icon.png"];
                ((UCampusMenuCell*)cell).imageView.backgroundColor = [UIColor uLinkOrangeColor];
                cell.tag = 1;
                break;
            case 2:
                cell.textLabel.text = @"Social Media";
                ((UCampusMenuCell*)cell).iconImage = [UIImage imageNamed:@"ulink-mobile-social-icon.png"];
                ((UCampusMenuCell*)cell).imageView.backgroundColor = [UIColor uLinkDeepPurpleColor];
                cell.tag = 2;
                break;
            default:
                break;
        }
        
        [(UCampusMenuCell*)cell layoutSubviews];
        [(UCampusMenuCell*)cell setEnabled:YES];
    }
    else if ([mode isEqualToString:@"uList"]) {
        static NSString *CellIdentifier = @"uListCell";
        cell = (UListMenuCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UListMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        if (section == 0) {
            ((UListMenuCell*)cell).mainCat = nil;
            ((UListMenuCell*)cell).subCat = nil;
            ((UListMenuCell*)cell).type = kListingCategoryTypeAddListingButton;
            ((UListMenuCell*)cell).tag = kListingCategoryTypeAddListingButton;
            ((UListMenuCell*)cell).iconImage = [UIImage imageNamed:@"mobile-plus-sign"];
            ((UListMenuCell*)cell).textLabel.text = BTN_ADD_LISTING;
            [(UListMenuCell*)cell layoutSubviews];
            [((UListMenuCell*)cell) initialize];
            
            [(UListMenuCell*)cell setEnabled:YES];
        } else {
            NSString *categoryKey = [UDataCache.uListCategorySections objectAtIndex:section];
            NSMutableArray *categories = [UDataCache.uListCategories objectForKey:categoryKey];
            UListCategory *category = [categories objectAtIndex:indexPath.row];
            ((UListMenuCell*)cell).type = kListingCategoryTypeDark;
            ((UListMenuCell*)cell).tag = kListingCategoryTypeDark;
            ((UListMenuCell*)cell).mainCat = categoryKey;
            ((UListMenuCell*)cell).subCat = category.name;
            ((UListMenuCell*)cell).iconImage = nil;
            //((UListMenuCell*)cell).textLabel.
            ((UListMenuCell*)cell).textLabel.text = category.name;
            [((UListMenuCell*)cell) initialize];
            [(UListMenuCell*)cell layoutSubviews];
            [(UListMenuCell*)cell setEnabled:YES];
        }
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
        
        if ([(id)uListSchoolHomeController respondsToSelector:@selector(performSegue:)]) {
            if(selectedCell.tag == kListingCategoryTypeAddListingButton) {
                UIStoryboard *storyboard = (id)uListSchoolHomeController.storyboard;
                UIViewController *svc = [storyboard instantiateViewControllerWithIdentifier:CONTROLLER_ADD_LISTING_NAVIGATION_CONTROLLER_ID];
                [(id)uListSchoolHomeController presentViewController:svc animated:YES completion:nil];
            } else {
                //[(id)uListSchoolHomeController performSegue:selectedCell.];
                [(id)uListSchoolHomeController performSegueWithIdentifier:SEGUE_SHOW_ULIST_SCHOOL_LISTINGS_VIEW_CONTROLLER sender:selectedCell];
            }
        }
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    if ([mode isEqualToString:@"uList"]) {
        if (section == 0) {
            view = [self createSectionView:EMPTY_STRING];
        } else {
            view = [self createSectionView:[UDataCache.uListCategorySections objectAtIndex:section]];
        }
    }
    else {
        view = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight;
    if ([mode isEqualToString:@"uList"]) {
        if (section == 0) {
            headerHeight = 0.0;
        }
        else {
            headerHeight = 30.0;
        }
    }
    else {
        headerHeight = 0.0;
    }
    return headerHeight;
}

/*
 TODO: Get this to work...
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerTitle = nil;
    NSLog(@"setting title: %@", headerTitle);
    if ([mode isEqualToString:@"uList"]) {
        headerTitle = (NSString*)[UDataCache.uListCategorySections objectAtIndex:section];
    }
    else {
        headerTitle = [[NSString alloc] init];
    }
    return headerTitle;
}
 */

- (UIView*)createSectionView:(NSString*)category {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    view.backgroundColor = [UIColor uLinkDarkGrayColor];
    UILabel *sectionLabel = [[UILabel alloc] init];
    sectionLabel.frame = CGRectMake(5, 0, 250, 30);
    sectionLabel.textColor = [UIColor whiteColor];
    sectionLabel.font = cellFontBold;
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.text = category;
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:sectionLabel];
    return view;
}
@end