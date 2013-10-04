//
//  MyListingsViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 5/26/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "MyListingsViewController.h"
#import "DataCache.h"
#import "AppDelegate.h"
#import "AppMacros.h"
#import "MyListingCell.h"
#import "SaveListingViewController.h"
#import "AddListingSelectCategoryTableViewController.h"

@interface MyListingsViewController ()
- (void)applyUlinkTableFooter;
- (void)addListingClick:(id)sender;
- (void) rehydrateListingsAfterDelete;
- (void)finishedDeletingListing;
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
    NSLog(@"ViewDidLoad MyListings");
    
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self applyUlinkTableFooter];
    // add the "Add Listing" button
    UIImage *plusImg = [UIImage imageNamed:@"mobile-plus-sign"];
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setImage:plusImg forState:UIControlStateNormal];
    addBtn.showsTouchWhenHighlighted = YES;
    addBtn.frame = CGRectMake(0.0, 0.0, 25,25);
    [addBtn addTarget:self action:@selector(addListingClick:) forControlEvents:UIControlEventTouchUpInside];
    
    /*
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc]
                                initWithImage:[UIImage imageNamed:@"mobile-plus-sign"]
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(addListingClick:)];
    */
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    // register observer used when refreshing listings after deletion
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rehydrateListingsAfterDelete) name:NOTIFICATION_MY_LISTINGS_CONTROLLER_REFRESH
                                               object:nil];
    
    // Register the observer used when deleting listing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedDeletingListing) name:NOTIFICATION_MY_LISTINGS_CONTROLLER
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"ViewWillAppear MyListings");
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

// Allow editing on all user listings
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // call deletion on listing
        MyListingCell *cell = (MyListingCell*)[tableView cellForRowAtIndexPath:indexPath];
        if (cell != nil) {
            [self deleteListing:cell.listing];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_SAVE_LISTING_VIEW_CONTROLLER])
    {
        MyListingCell *cell = (MyListingCell *)sender;
        SaveListingViewController *saveListingViewController = [segue destinationViewController];
        saveListingViewController.saveMode = kListingSaveTypeUpdate;
        saveListingViewController.listing = cell.listing;
    }
}
#pragma mark - 
#pragma mark Actions
- (void)addListingClick:(id)sender {
    
    UIStoryboard *storyboard = self.storyboard;
    UIViewController *svc = [storyboard instantiateViewControllerWithIdentifier:CONTROLLER_ADD_LISTING_NAVIGATION_CONTROLLER_ID];

    [self presentViewController:svc animated:YES completion:nil];
    
    /*
    AddListingSelectCategoryTableViewController *addListVC = [[AddListingSelectCategoryTableViewController alloc] init];
    addListVC.myListingDelegate = self;
    UINavigationController *uiNav = [[UINavigationController alloc] initWithRootViewController:addListVC];
    [self presentViewController:uiNav animated:YES completion:nil];
     */
}
#pragma mark - endpoint calls

/*
 * Retreive the top categories
 * for this school
 */
- (void) deleteListing:(Listing*)toDelete {
    @try {
        [toDelete deleteListing:NOTIFICATION_MY_LISTINGS_CONTROLLER_REFRESH];
    }
    @catch (NSException *exception) {} 
}

- (void) rehydrateListingsAfterDelete {
    NSLog(@"Rehydrate Session User Listings - Recieved notification, listing has been deleted.");
    [UDataCache rehydrateSessionUserListings:NO notification:NOTIFICATION_MY_LISTINGS_CONTROLLER];
}

- (void) finishedDeletingListing {
    NSLog(@"Delete Listing - Recieved notification, session user listings rehydrated.");
    /*
     * Since this function gets called when we receive a notification, and since it is
     * possible that the notification comes in on a different sub thread, we
     * need to ensure that the code in this function is executed on the main thread so
     * that it doesn't hold up the UI.
     */
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
@end
