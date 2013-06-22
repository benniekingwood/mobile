//
//  AddListingSelectCategoryTableViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 6/22/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "AddListingSelectCategoryTableViewController.h"
#import "DataCache.h"
#import "UListMenuCell.h"
#import "AppMacros.h"
#import "UListCategory.h"
#import "AddListingViewController.h"
@interface AddListingSelectCategoryTableViewController () {
    UIFont *cellFontBold;
}
- (void) reloadTableData;
@end

@implementation AddListingSelectCategoryTableViewController

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
    cellFontBold = [UIFont fontWithName:FONT_GLOBAL_BOLD size:15.0f];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if(UDataCache.uListCategorySections.count == 0) {
        // TODO: have notification on this..also have the activity indicator load here
        // until the notification comes back in ..initially just have timer to test the
        // activity indicator view
         [UDataCache hydrateUListCategoryCache];
        [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(reloadTableData) userInfo:nil repeats:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) reloadTableData {
    NSLog(@"reloading data.");
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [UDataCache.uListCategorySections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [UDataCache.uListCategorySections objectAtIndex:section];
    NSMutableArray *subcategories = [UDataCache.uListCategories mutableArrayValueForKey:key];
    return [subcategories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = CELL_LISTING_CATEGORY_CELL;
    UListMenuCell *cell = nil;
    int section = [indexPath section];
    cell = (UListMenuCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UListMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *categoryKey = [UDataCache.uListCategorySections objectAtIndex:section];
    NSMutableArray *categories = [UDataCache.uListCategories objectForKey:categoryKey];
    UListCategory *category = [categories objectAtIndex:indexPath.row];
    cell.type = kListingCategoryTypeLight;
    cell.mainCat = categoryKey;
    cell.subCat = category.name;
    cell.iconImage = [[UIImage alloc] init];
    cell.textLabel.text = category.name;
    [cell initialize];
    [cell layoutSubviews];
    [cell setEnabled:YES];
    return cell;
}
#pragma mark -
#pragma mark - Table view delegate
- (UIView*)createSectionView:(NSString*)sectionText {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    view.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.6f];
    UILabel *sectionLabel = [[UILabel alloc] init];
    sectionLabel.frame = CGRectMake(10, 1, 320, 20);
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
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    view = [self createSectionView:[UDataCache.uListCategorySections objectAtIndex:section]];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
   // UListMenuCell *selectedCell = (UListMenuCell*)[tableView cellForRowAtIndexPath:indexPath];
   // [self performSegueWithIdentifier:SEGUE_SHOW_ADD_LISTING_VIEW_CONTROLLER sender:selectedCell];
}
#pragma mark -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_ADD_LISTING_VIEW_CONTROLLER])
    {
        UListMenuCell *cell = (UListMenuCell *)sender;
        AddListingViewController *addListingViewController = [segue destinationViewController];
        addListingViewController.mainCategory = cell.mainCat;
        addListingViewController.subCategory  = cell.subCat;
    }
}

- (IBAction)cancelClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
