//
//  User.h
//  uLink
//
//  Created by Bennie Kingwood on 11/16/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "School.h"
@interface User : NSObject
@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *firstname;
@property (nonatomic) NSString *lastname;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *schoolId;
@property (nonatomic) NSString *schoolName;
@property (nonatomic) School *school;
@property (nonatomic) NSString *major;
@property (nonatomic) NSString *year;
@property (nonatomic) NSString *schoolStatus;
@property (nonatomic) NSString *bio;
@property (nonatomic) NSString *twitterUsername;
@property (nonatomic) NSString *userImgURL;
@property (nonatomic) BOOL twitterEnabled;
@property (strong, nonatomic) UIImage *profileImage;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableArray *snaps;
@property (nonatomic) NSDate *cacheAge;
- (void) hydrateUser:(NSDictionary*)rawData isSessionUser:(BOOL)isSessionUser;
@end
