//
//  UCampusSocialViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/28/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UCampusSocialViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMacros.h"
#import "DataCache.h"
#import "UserProfileViewController.h"

@interface UCampusSocialViewController (){}
@end

@implementation UCampusSocialViewController
static NSString *kTweetCellId = CELL_TWEET;
@synthesize tweetsHeader,tweetsTableView, schoolHeaderLabel;
@synthesize trend1Label, trend2Label, trend3Label, trend4Label, trend5Label;
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
    self.schoolHeaderLabel.font = [UIFont fontWithName:FONT_GLOBAL size:17.0f];
    self.schoolHeaderLabel.textColor = [UIColor whiteColor];
    self.schoolHeaderLabel.textAlignment = NSTextAlignmentCenter;
    self.schoolHeaderLabel.backgroundColor = [UIColor clearColor];
    self.schoolHeaderLabel.text = [UDataCache.sessionUser.schoolName stringByAppendingString:@" Trends"];
    [self.tweetsHeader setText:@"Tweets"];
    [self.tweetsHeader setFont:[UIFont fontWithName:FONT_GLOBAL size:12.0f]];
    [self.tweetsHeader setShadowColor:[UIColor lightGrayColor]];
    [self.tweetsHeader setTextColor: [UIColor whiteColor]];
    [self.tweetsHeader setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    self.tweetsTableView.layer.cornerRadius = 5;
    self.tweetsTableView.layer.masksToBounds = YES;
    self.trendsView.layer.cornerRadius = 5;
    self.trendsView.layer.masksToBounds = YES;
    self.tweetsTableView.dataSource = self;
    self.tweetsTableView.delegate = self;
    [self applyUlinkTableFooter];
    
    self.trend1Label.font = [UIFont fontWithName:FONT_GLOBAL size:19.0];
    self.trend1Label.textAlignment = NSTextAlignmentLeft;
    self.trend1Label.textColor = [UIColor blackColor];
    self.trend1Label.backgroundColor = [UIColor clearColor];
    self.trend2Label.font = [UIFont fontWithName:FONT_GLOBAL size:14.0];
    self.trend2Label.textAlignment = NSTextAlignmentCenter;
    self.trend2Label.textColor = [UIColor blackColor];
    self.trend2Label.backgroundColor = [UIColor clearColor];
    self.trend3Label.font = [UIFont fontWithName:FONT_GLOBAL size:11.0];
    self.trend3Label.textAlignment = NSTextAlignmentLeft;
    self.trend3Label.textColor = [UIColor blackColor];
    self.trend3Label.backgroundColor = [UIColor clearColor];
    self.trend4Label.font = [UIFont fontWithName:FONT_GLOBAL size:16.0];
    self.trend4Label.textAlignment = NSTextAlignmentRight;
    self.trend4Label.textColor = [UIColor blackColor];
    self.trend4Label.backgroundColor = [UIColor clearColor];
    self.trend5Label.font = [UIFont fontWithName:FONT_GLOBAL size:14.0];
    self.trend5Label.textAlignment = NSTextAlignmentLeft;
    self.trend5Label.textColor = [UIColor blackColor];
    self.trend5Label.backgroundColor = [UIColor clearColor];
    
    trend1Label.text = [UDataCache.trends objectAtIndex:0];
    trend2Label.text = [UDataCache.trends objectAtIndex:1];
    trend3Label.text = [UDataCache.trends objectAtIndex:2];
    trend4Label.text = [UDataCache.trends objectAtIndex:3];
    trend5Label.text = [UDataCache.trends objectAtIndex:4];
    // TODO: check to see if tweets/trends are stale > 15 mins
    // if so rehydrate the cache and load the table view here and have
    // activity indicator while the table is waiting (make sure table view is alpha zero) and
    // trends section is empty
    
    // TODO: if tweet user has ulink account have the tweet cell have the
    // ulink username in blue and the twitter username under it with a @
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tweetsTableView reloadData];
}

- (void)applyUlinkTableFooter {
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 55)];
	footer.backgroundColor = [UIColor clearColor];
    UIImageView *shortLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(135, 5, 24, 56)];
    shortLogoImageView.image = [UIImage imageNamed:@"ulink_short_logo.png"];
    [footer addSubview:shortLogoImageView];
	self.tweetsTableView.tableFooterView = footer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tweetUserClick:(User*)user {
    UserProfileViewController *viewProfileController = [self.storyboard instantiateViewControllerWithIdentifier:CONTROLLER_USER_PROFILE_VIEW_CONTROLLER_ID];
    viewProfileController.user = user;
    [self.navigationController presentViewController:viewProfileController animated:YES completion:nil];
}

#pragma mark - UITableView section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [UDataCache.tweets count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    TweetCell *cell = (TweetCell *)[self.tweetsTableView dequeueReusableCellWithIdentifier:kTweetCellId];
    if (cell == nil) {
        cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTweetCellId] ;
    }
    cell.tweet = [UDataCache.tweets objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell initialize]; 
    return cell;
}
#pragma mark
@end
