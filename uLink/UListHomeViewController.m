//
//  UListHomeViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 4/17/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListHomeViewController.h"
#import "AppDelegate.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "SelectSchoolCell.h"
#import "UListSchoolHomeViewController.h"

@interface UListHomeViewController ()
{
    NSMutableArray *sections;
    UIFont *cellFont;
    UIFont *cellFontBold;
}
@end

@implementation UListHomeViewController

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
    //[self setEdgesForExtendedLayout:UIRectEdgeBottom];
    //[self setExtendedLayoutIncludesOpaqueBars:YES];
    
    cellFont = [UIFont fontWithName:FONT_GLOBAL size:15.0f];
    cellFontBold = [UIFont fontWithName:FONT_GLOBAL_BOLD size:15.0f];
    
    [UDataCache.schoolSections removeObject:@""];
    sections = UDataCache.schoolSections;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sections count];
}

- (UIView*)createSectionView:(NSString*)sectionText {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    view.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.6f];
    UILabel *sectionLabel = [[UILabel alloc] init];
    sectionLabel.frame = CGRectMake(10, 1, 20, 20);
    sectionLabel.textColor = [UIColor whiteColor];
    sectionLabel.font = cellFontBold;
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.shadowColor = [UIColor blackColor];
    sectionLabel.shadowOffset = CGSizeMake(0.0f, -0.5f);
    sectionLabel.text = sectionText;
    [view addSubview:sectionLabel];
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 0.1)];
    bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
    [view addSubview:bottomLine];
    return view;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ 
    NSInteger retVal;
    NSString *key = [sections objectAtIndex:section];
    NSMutableArray *schools = [UDataCache.schools objectForKey:key];
    retVal = [schools count];
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = CELL_SELECT_SCHOOL_CELL;
    int section = [indexPath section];
    SelectSchoolCell *cell = [[SelectSchoolCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = cellFont;
    NSString *schoolKey = [sections objectAtIndex:section];
    NSMutableArray *schools = [UDataCache.schools objectForKey:schoolKey];
    cell.school= [schools objectAtIndex:indexPath.row];
    [cell initialize];
    return cell;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    view = [self createSectionView:[sections objectAtIndex:section]];
    return view;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectSchoolCell *cell = (SelectSchoolCell*)[tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:SEGUE_SHOW_ULIST_SCHOOL_HOME_VIEW_CONTROLLER sender:cell];
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_ULIST_SCHOOL_HOME_VIEW_CONTROLLER])
    {
        SelectSchoolCell *cell = (SelectSchoolCell *)sender;
        UListSchoolHomeViewController *schoolHomeViewController = [segue destinationViewController];
        schoolHomeViewController.school = cell.school;
        schoolHomeViewController.school.schoolId = cell.schoolId;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
