//
//  TweetCell.h
//  uLink
//
//  Created by Bennie Kingwood on 11/28/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
@protocol TweetCellDelegate;
@protocol TweetCellDelegate
-(void)tweetUserClick:(User*)user;
@end
@interface TweetCell : UITableViewCell {
    id<TweetCellDelegate> _delegate;
}
@property (nonatomic, assign) id<TweetCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIImageView *userImageView;
@property (nonatomic) Tweet *tweet;
-(void)initialize;
@end
