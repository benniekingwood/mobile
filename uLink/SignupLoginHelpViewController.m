//
//  SignupLoginHelpViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/30/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SignupLoginHelpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SignupLoginHelpViewController ()

@end

@implementation SignupLoginHelpViewController

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
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
