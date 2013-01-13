//
//  UCampusSocialViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/28/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetCell.h"
@interface UCampusSocialViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, TweetCellDelegate>
@property (strong, nonatomic) IBOutlet UILabel *schoolHeaderLabel;
@property (strong, nonatomic) IBOutlet UILabel *trend5Label;
@property (strong, nonatomic) IBOutlet UILabel *trend4Label;
@property (strong, nonatomic) IBOutlet UILabel *trend3Label;
@property (strong, nonatomic) IBOutlet UILabel *trend2Label;
@property (strong, nonatomic) IBOutlet UILabel *trend1Label;
@property (strong, nonatomic) IBOutlet UIView *trendsView;
@property (strong, nonatomic) IBOutlet UITableView *tweetsTableView;
@property (strong, nonatomic) IBOutlet UILabel *tweetsHeader;

@end
