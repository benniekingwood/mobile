//
//  SnapshotCategory.h
//  uLink
//
//  Created by Bennie Kingwood on 12/18/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnapshotCategory : NSObject
@property (nonatomic) NSString *snapCategoryId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSDate *cacheAge;
@end
