//
//  MyEventsViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/13/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "MyEventsViewController.h"
#import "DataCache.h"
#import "AppMacros.h"
#import "EventCell.h"
#import "EditEventViewController.h"
@interface MyEventsViewController ()
-  (void)applyUlinkTableFooter;
@end

@implementation MyEventsViewController
static NSString *kMyEventCellId = CELL_MY_EVENT_CELL;
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
    return [UDataCache.sessionUser.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = (EventCell *)[tableView dequeueReusableCellWithIdentifier:kMyEventCellId forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyEventCellId] ;
    }
    cell.event = [UDataCache.sessionUser.events objectAtIndex:indexPath.item];
    [cell initialize];
   // [cell layoutSubviews];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_EDIT_EVENT_VIEW_CONTROLLER])
    {
        EventCell *cell = (EventCell *)sender;
        EditEventViewController *editEventViewController = [segue destinationViewController];
        editEventViewController.event = cell.event;
    }
}
@end
