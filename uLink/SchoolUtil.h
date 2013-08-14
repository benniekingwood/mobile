//
//  SchoolUtil.h
//  ulink
//
//  Created by Bennie Kingwood on 8/13/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "School.h"
#define USchoolUtil ((SchoolUtil *)[SchoolUtil instance])
@interface SchoolUtil : NSObject
- (School*) findSchoolById:(NSString*)schoolId;
@end
