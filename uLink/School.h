//
//  School.h
//  uLink
//
//  Created by Bennie Kingwood on 12/8/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface School : NSObject
@property (nonatomic) NSString *schoolId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *shortName;
@property (nonatomic) NSString *year;
@property (nonatomic) NSString *attendance;
@property (nonatomic) NSString *imageURL;
@property (nonatomic) NSDate *cacheAge;
@end
