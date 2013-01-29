//
//  SelectSchoolViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/14/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SelectSchoolViewController.h"
#import "UlinkButton.h"
#import "SignUpViewController.h"
#import "SelectSchoolCell.h"
#import "TextUtil.h"
#import "ActivityIndicatorView.h"
#import "School.h"
#import "DataCache.h"
@interface SelectSchoolViewController ()
{
    UIFont *cellFont;
    TextUtil *textUtil;
    NSMutableArray *sections;
}
-(void)suggestClick;
@end

@implementation SelectSchoolViewController
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    cellFont = [UIFont fontWithName:FONT_GLOBAL size:15.0f];
    [UDataCache.schoolSections removeObject:@""];
    sections = UDataCache.schoolSections;
    [sections insertObject:@"" atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)suggestClick {
    [self performSegueWithIdentifier:SEGUE_SHOW_SUGGEST_SCHOOL_VIEW_CONTROLLER sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_SIGN_UP_VIEW_CONTROLLER])
    {
        SelectSchoolCell *cell = (SelectSchoolCell *)sender;
        SignUpViewController *signUpViewController = [segue destinationViewController];
        signUpViewController.schoolId = cell.schoolId;
        signUpViewController.schoolName = cell.schoolName;
    }
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
    sectionLabel.frame = CGRectMake(10, 3, 10, 20);
    sectionLabel.textColor = [UIColor whiteColor];
    sectionLabel.font = cellFont;
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
    if([key isEqualToString:@""]) {
        retVal = 1;
    } else {
        NSMutableArray *schools = [UDataCache.schools objectForKey:key];
        retVal = [schools count];
    }
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = CELL_SELECT_SCHOOL_CELL;
    int section = [indexPath section];
    SelectSchoolCell *cell = [[SelectSchoolCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = cellFont;
    if(section == 0) {
        UlinkButton *suggestBtn = [UlinkButton buttonWithType:UIButtonTypeCustom];
        suggestBtn.frame = CGRectMake(200, 5, 110, 35);
        [suggestBtn setTitle:BTN_SUGGEST_HERE forState:UIControlStateNormal];
        [suggestBtn createOrangeSmallButton:suggestBtn];
        [suggestBtn addTarget:self
                       action:@selector(suggestClick)
             forControlEvents:UIControlEventTouchUpInside];
        [cell initialize:suggestBtn];
    } else {
        NSString *schoolKey = [sections objectAtIndex:section];
        NSMutableArray *schools = [UDataCache.schools objectForKey:schoolKey];
        School *school = [schools objectAtIndex:indexPath.row];
        cell.textLabel.text = school.name;
        cell.schoolId = school.schoolId;
    }
    return cell;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    if (section == 0) {
        view = [self createSectionView:@""];
    } else {
        view = [self createSectionView:[sections objectAtIndex:section]];
    }
    return view;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section > 0) {
        SelectSchoolCell *cell = (SelectSchoolCell*)[tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:SEGUE_SHOW_SIGN_UP_VIEW_CONTROLLER sender:cell];
    }
}

@end
