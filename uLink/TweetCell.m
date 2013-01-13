//
//  TweetCell.m
//  uLink
//
//  Created by Bennie Kingwood on 11/28/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "TweetCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMacros.h"
#import "UserProfileButton.h"
@interface TweetCell() {
    UILabel *tweetLabel;
    UILabel *twitterUsername;
    UILabel *ulinkUsername;
    UILabel *tweetAge;
    UserProfileButton *tweetUserImageButton;
}
@end
@implementation TweetCell
@synthesize tweet;
@synthesize delegate = _delagate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}
- (void)initialize {
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.masksToBounds = YES;
    [tweetLabel removeFromSuperview];
    tweetLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 13, 185, 80)];
    tweetLabel.numberOfLines = 4;
    tweetLabel.font = [UIFont fontWithName:FONT_GLOBAL size:11.0f];
    tweetLabel.textColor = [UIColor blackColor];
    tweetLabel.backgroundColor = [UIColor clearColor];
    tweetLabel.text = self.tweet.tweetText;
    
    [tweetAge removeFromSuperview];
    tweetAge = [[UILabel alloc] initWithFrame:CGRectMake(263, 5, 30, 20)];
    tweetAge.font = [UIFont fontWithName:FONT_GLOBAL size:10.0f];
    tweetAge.textColor = [UIColor grayColor];
    tweetAge.backgroundColor = [UIColor clearColor];
    tweetAge.text = self.tweet.tweetAge;
    [ulinkUsername removeFromSuperview];
    [twitterUsername removeFromSuperview];
    [tweetUserImageButton removeFromSuperview];
    if(self.tweet.user.username != nil && self.tweet.user.profileImage != nil) {
        tweetUserImageButton = [UserProfileButton buttonWithType:UIButtonTypeCustom];
        [tweetUserImageButton addTarget:self
                                action:@selector(viewUserProfileClick)
                      forControlEvents:UIControlEventTouchDown];
        tweetUserImageButton.frame = CGRectMake(24, 16, 40, 40);
        tweetUserImageButton.user = self.tweet.user;
        [tweetUserImageButton initialize];
        [self.contentView addSubview:tweetUserImageButton];
        twitterUsername = [[UILabel alloc] initWithFrame:CGRectMake(180, 5, 100, 20)];
        ulinkUsername = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 100, 20)];
        ulinkUsername.font = [UIFont fontWithName:FONT_GLOBAL size:10.0f];
        ulinkUsername.textColor = [UIColor blueColor];
        ulinkUsername.backgroundColor = [UIColor clearColor];
        ulinkUsername.text = self.tweet.user.username;
        [self.contentView addSubview:ulinkUsername];
    } else {
        self.imageView.image  = self.tweet.twitterUserImage;
        twitterUsername = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 100, 20)];
    }
    twitterUsername.font = [UIFont fontWithName:FONT_GLOBAL size:10.0f];
    twitterUsername.textColor = [UIColor grayColor];
    twitterUsername.backgroundColor = [UIColor clearColor];
    twitterUsername.text = self.tweet.twitterUsername;
    [self.contentView addSubview:tweetAge];
    [self.contentView addSubview:tweetLabel];
    [self.contentView addSubview:twitterUsername];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(24, 16, 40, 40);
}
- (void)viewUserProfileClick {
    [self.delegate tweetUserClick:self.tweet.user];
}
@end
