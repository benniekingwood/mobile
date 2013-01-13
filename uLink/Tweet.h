//
//  Tweet.h
//  uLink
//
//  Created by Bennie Kingwood on 12/20/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject
@property (nonatomic) User *user;
@property (nonatomic) UIImage *twitterUserImage;
@property (nonatomic) NSString *twitterUsername;
@property (nonatomic) NSString *tweetAge;
@property (nonatomic) NSString *tweetText;
@property (nonatomic) NSDate *created;
@property (nonatomic) NSDate *cacheAge;
@end
