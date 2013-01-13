//
//  SnapCommentCell.h
//  uLink
//
//  Created by Bennie Kingwood on 11/19/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapshotComment.h"
@protocol SnapCommentCellDelegate;
@protocol SnapCommentCellDelegate
-(void)snapCommentUserClick:(User*)user;
@end
@interface SnapCommentCell : UITableViewCell {
    id<SnapCommentCellDelegate> _delegate;
}
@property (nonatomic, assign) id<SnapCommentCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *comment;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (nonatomic) SnapshotComment *snapComment;
- (void) initialize;
@end
