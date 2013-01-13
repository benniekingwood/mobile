//
//  Event.h
//  uLink
//
//  Created by Bennie Kingwood on 11/26/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Event : NSObject
@property (nonatomic) NSString *eventId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *location;
@property (nonatomic) NSString *time;
@property (nonatomic) NSString *information;
@property (nonatomic) NSString *featured;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) NSString *imageURL;
@property (nonatomic) User *user;
@property (nonatomic) NSString *clearDate;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSDate *cacheAge;
@end
