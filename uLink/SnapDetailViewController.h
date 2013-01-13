//
//  SnapDetailViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/16/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snap.h"
#import "SnapCommentCell.h"

@interface SnapDetailViewController : UIViewController <UIAlertViewDelegate,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SnapCommentCellDelegate>
- (IBAction)showDeleteAlert:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *snapImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentHeader;
@property (strong, nonatomic) IBOutlet UITableView *commentsTableView;
@property (nonatomic, strong) Snap *snap;
@property(nonatomic) BOOL inUCampusMode;
@property (strong, nonatomic) IBOutlet UILabel *snapCaptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *snapUserImageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@end
