//
//  SnapshotComment.h
//  uLink
//
//  Created by Bennie Kingwood on 12/15/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;
@interface SnapshotComment : NSObject
@property (nonatomic) NSString *snapCommentId;
@property (nonatomic) NSString *comment;
@property (nonatomic) NSString *createdShort;
@property (nonatomic) NSDate *created;
@property (nonatomic) User *user;
@end
