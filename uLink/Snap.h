//
//  Snap.h
//  uLink
//
//  Created by Bennie Kingwood on 11/16/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Snap : NSObject
@property (nonatomic) NSString *snapId;
@property (nonatomic) NSString *categoryId;
@property (nonatomic) NSString *categoryName;
@property (nonatomic) NSString *caption;
@property (nonatomic) NSDate *created;
@property (nonatomic) NSString *snapImageURL;
@property (strong, nonatomic) UIImage *snapImage;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray *snapComments;
@property (nonatomic) NSDate *cacheAge;
@end
