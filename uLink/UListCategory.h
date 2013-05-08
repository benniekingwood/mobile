//
//  UListCategory.h
//  ulink
//
//  Created by Christopher Cerwinski on 4/30/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UListCategory : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *imageURL;
@property (nonatomic) NSDate *cacheAge;
@end
