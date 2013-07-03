//
//  AddListingViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 6/22/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "AddListingViewController.h"
#import "AppMacros.h"

@interface AddListingViewController () 
@end

@implementation AddListingViewController
@synthesize mainCategory, subCategory;
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
    // create the basic info table
    self.tableView.backgroundColor = [UIColor blackColor];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextClick:(id)sender {
}
@end
