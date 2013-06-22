//
//  AddListingViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 6/22/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "AddListingViewController.h"

@interface AddListingViewController ()

@end

@implementation AddListingViewController
@synthesize mainCategory, subCategory;
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
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"Add Listing";
    NSLog(@"%@, %@", self.mainCategory, self.subCategory);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
