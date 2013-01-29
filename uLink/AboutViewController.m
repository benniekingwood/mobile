//
//  AboutViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/30/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "AboutViewController.h"
#import "AppMacros.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                   style:UITableViewStyleGrouped];
    
    tv.delegate = self;
    tv.dataSource = self;
    self.tableView = tv;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:182.0f / 255.0f green:204.0f / 255.0f blue:213.0f / 255.0f alpha:1.0f];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kversionCell = CELL_VERSION_CELL;
     UITableViewCell *versionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kversionCell];
    
    versionCell.textLabel.text = @"Version";
    versionCell.textLabel.font = [UIFont fontWithName:FONT_GLOBAL size:15.0f];
    versionCell.detailTextLabel.text = VERSION_NUMBER;
    versionCell.detailTextLabel.font =[UIFont fontWithName:FONT_GLOBAL size:15.0f];
    versionCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return versionCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
