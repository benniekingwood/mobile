//
//  MyListingsViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 5/26/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "MyListingsViewController.h"
#import "DataCache.h"
#import "AppMacros.h"
#import "MyListingCell.h"
@interface MyListingsViewController ()
-  (void)applyUlinkTableFooter;
- (void)addListingClick:(id)sender;
@end
@implementation MyListingsViewController
static NSString *kMyListingCellId = CELL_MY_LISTING_CELL;
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
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self applyUlinkTableFooter];
    // add the "Add Listing" button
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc]
                                initWithTitle:@"Add Listing"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(addListingClick:)];
    self.navigationItem.rightBarButtonItem = btnSave;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applyUlinkTableFooter {
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 55)];
	footer.backgroundColor = [UIColor clearColor];
    UIImageView *shortLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 5, 24, 56)];
    shortLogoImageView.image = [UIImage imageNamed:@"ulink_short_logo.png"];
    [footer addSubview:shortLogoImageView];
	self.tableView.tableFooterView = footer;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [UDataCache.sessionUser.listings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyListingCell *cell = (MyListingCell *)[tableView dequeueReusableCellWithIdentifier:kMyListingCellId forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[MyListingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyListingCellId] ;
    }
    cell.listing = [UDataCache.sessionUser.listings objectAtIndex:indexPath.item];
    [cell initialize];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_EDIT_EVENT_VIEW_CONTROLLER])
    {
        MyListingCell *cell = (MyListingCell *)sender;
      //  EditEventViewController *editEventViewController = [segue destinationViewController];
       // editEventViewController.event = cell.event;
    }
}
#pragma mark - 
#pragma mark Actions
- (void)addListingClick:(id)sender {
    NSLog(@"Add Listing click");
}
#pragma mark -
@end
