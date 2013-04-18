//
//  UListHomeViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 4/17/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListHomeViewController.h"
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
    cellFont = [UIFont fontWithName:FONT_GLOBAL size:15.0f];
    cellFontBold = [UIFont fontWithName:FONT_GLOBAL_BOLD size:15.0f];
    
	// Do any additional setup after loading the view.
    UIView *titleBG = [[UIView alloc] initWithFrame:CGRectMake(0, 34, 320, 75)];
    titleBG.backgroundColor = [UIColor blackColor];
    titleBG.alpha = ALPHA_MED;
    
    // add uList title
    UILabel *uListTitle = [[UILabel alloc] initWithFrame:CGRectMake(25, 9, 320, 100)];
    uListTitle.backgroundColor = [UIColor clearColor];
    uListTitle.text = @"uList.";
    uListTitle.textColor = [UIColor whiteColor];
    uListTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:20.0];
    uListTitle.numberOfLines = 1;
    uListTitle.textAlignment = NSTextAlignmentLeft;
    
    // add uList caption
    UILabel *uListCap= [[UILabel alloc] initWithFrame:CGRectMake(25, 39, 320, 100)];
    uListCap.backgroundColor = [UIColor clearColor];
    uListCap.text = @"College classifieds done right.";
    uListCap.textColor = [UIColor whiteColor];
    uListCap.font = [UIFont fontWithName:FONT_GLOBAL size:16.0];
    uListCap.numberOfLines = 1;
    uListCap.textAlignment = NSTextAlignmentLeft;
    
    [self.view addSubview:titleBG];
    [self.view addSubview:uListTitle];
    [self.view addSubview:uListCap];
    
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
    School *school = [schools objectAtIndex:indexPath.row];
    cell.textLabel.text = school.name;
    cell.schoolId = school.schoolId;
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
        schoolHomeViewController.schoolId = cell.schoolId;
        schoolHomeViewController.schoolName = cell.schoolName;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
