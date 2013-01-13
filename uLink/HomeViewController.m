//
//  Home.m
//  uLink
//
//  Created by Bennie Kingwood on 11/7/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"


@interface HomeViewController ()
@end
@implementation HomeViewController
@synthesize loginViewController;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonClick {
	/*LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
	self.loginViewController = viewController;
    [self addChildViewController:viewController];*/
    LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
    [self.navigationController pushViewController:viewController animated:YES];

    NSLog(@"I clicked login.");
}

@end
