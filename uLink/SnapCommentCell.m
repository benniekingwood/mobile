//
//  SnapCommentCell.m
//  uLink
//
//  Created by Bennie Kingwood on 11/19/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SnapCommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMacros.h"
#import "UserProfileButton.h"
@interface SnapCommentCell() {
    UserProfileButton *snapUserImageButton;
}
@end
@implementation SnapCommentCell
@synthesize userName,date, comment, snapComment;
@synthesize delegate = _delagate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

-(void) initialize {
    self.comment.font = [UIFont fontWithName:FONT_GLOBAL size:11.0f];
    self.userName.font = [UIFont fontWithName:FONT_GLOBAL size:10.0f];
    self.date.font = [UIFont fontWithName:FONT_GLOBAL size:10.0f];
    self.date.textColor = [UIColor lightGrayColor];
    self.date.backgroundColor = [UIColor clearColor];
    self.userName.textColor = [UIColor lightGrayColor];
    self.userName.backgroundColor = [UIColor clearColor];
    self.comment.numberOfLines = 4;
    self.comment.textColor = [UIColor blackColor];
    self.userName.textAlignment = NSTextAlignmentLeft;
    [snapUserImageButton removeFromSuperview];
    // build snap user image button
    snapUserImageButton = [UserProfileButton buttonWithType:UIButtonTypeCustom];
    [snapUserImageButton addTarget:self
                            action:@selector(viewUserProfileClick)
                  forControlEvents:UIControlEventTouchDown];
    snapUserImageButton.frame = CGRectMake(10, 20, 40, 40);
    snapUserImageButton.user = snapComment.user;
    [snapUserImageButton initialize];
    [self.contentView addSubview:snapUserImageButton];
    
    
    self.userName.text = snapComment.user.username;
    self.date.text = snapComment.createdShort;
    self.comment.text = snapComment.comment;
}

- (void)viewUserProfileClick {
    [self.delegate snapCommentUserClick:snapComment.user];
}
@end
