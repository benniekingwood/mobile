//
//  RootViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/14/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "FontUtil.h"
@interface RootViewController ()
@end

@implementation RootViewController
@synthesize backgroundView1;
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
    [signUpButton createOrangeButton:signUpButton];
    [loginInButton createOrangeButton:loginInButton];
    [UAppDelegate deactivateUCampusSideMenu];
   // FontUtil *utils = [[FontUtil alloc] init];
   // [utils listSystemFonts];
}
-(void)viewWillAppear:(BOOL)animated {
    backgroundView1.alpha = 1;
    [backgroundView1 sizeToFit];
    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         backgroundView1.alpha = 1.0;
                     }
                     completion:^(BOOL finished){ //task after an animation ends
                         [self performSelector:@selector(animateBackground) withObject:nil afterDelay:0.0];
                     }];
}
-(void)animateBackground {
    float newX = self.backgroundView1.frame.origin.x-50;
    float newY = self.backgroundView1.frame.origin.y+5;
    [UIView animateWithDuration:15.0
                          delay: 0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = self.backgroundView1.frame;
                         frame.origin.x = newX;
                         frame.origin.y = newY;
                         self.backgroundView1.frame = frame;
                     }
                     completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
