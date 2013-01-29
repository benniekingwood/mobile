//
//  UCampusViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/19/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UCampusViewController.h"
#import "AppDelegate.h"

@interface UCampusViewController () {
    UIScrollView *scroll;
    UIImageView *campusImage;
    UIImageView *socialImage;
    UIImageView *snapshotsImage;
}
@end

@implementation UCampusViewController
@synthesize pageControl;
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
    self.tabBarController.navigationItem.hidesBackButton = YES;
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,60,320,240)];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    scroll.contentSize = CGSizeMake(960, 100);
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.userInteractionEnabled = YES;
    CGRect splashFrame;
    splashFrame.origin.x = 0;
    splashFrame.origin.y = 0;
    splashFrame.size = scroll.frame.size;
    UIView *splashPicView = [[UIView alloc] initWithFrame:splashFrame];
    splashPicView.userInteractionEnabled = YES;

    // add the campus events splash image
    campusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ulink-mobile-campus-events-splash.png"]];
    campusImage.userInteractionEnabled = YES;
    CGRect campusFrame = CGRectMake(0, 0, 320, 240);
    campusImage.frame = campusFrame;
    [splashPicView addSubview:campusImage];
    
    // add the social splash image
    socialImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ulink-mobile-social-splash.png"]];
    socialImage.userInteractionEnabled = YES;
    CGRect socialFrame = CGRectMake(320, 0, 320, 240);
    socialImage.frame = socialFrame;
    [splashPicView addSubview:socialImage];
    
    // add the snapshots splash image
    snapshotsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ulink-mobile-snapshots-splash.png"]];
    CGRect snapshotsFrame = CGRectMake(640, 00, 320, 240);
    snapshotsImage.frame = snapshotsFrame;
    [splashPicView addSubview:snapshotsImage];
    
    // add the profile pic view to the scroll view
    [scroll addSubview:splashPicView];
    
    // add the scroll view to the main view
    [self.mainView addSubview:scroll];
    self.mainView.userInteractionEnabled = YES;
    snapshotsImage.userInteractionEnabled = YES;

    // initialize the page control
    pageControl.numberOfPages = 3;
    pageControl.currentPage = 0;
 
   
}

-(void)viewDidAppear:(BOOL)animated {
    // we need this to ensure the tab bar is able to have interactions
    self.navigationController.visibleViewController.view.userInteractionEnabled = YES;
    self.tabBarController.navigationItem.title = @"uCampus";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scroll.frame.size.width;
    int page = floor((scroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	if([touch view] == campusImage) {
        [self performSegue:0];
    } else if ([touch view] == snapshotsImage) {
        [self performSegue:1];
    } else if ([touch view] == socialImage) {
        [self performSegue:2];
    }
}

- (IBAction)changePage:(UIPageControl *)sender {
    int page = self.pageControl.currentPage;
    CGRect frame = scroll.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scroll scrollRectToVisible:frame animated:YES];
}

-(void) performSegue:(NSInteger)item {
    switch (item) {
        case 0:	
            [self performSegueWithIdentifier:@"ShowCampusEventsViewController" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"ShowSnapshotsViewController" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"ShowSocialViewController" sender:self];
            break;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
