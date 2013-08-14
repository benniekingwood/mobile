//
//  SchoolUtil.m
//  ulink
//
//  Created by Bennie Kingwood on 8/13/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "SchoolUtil.h"
#import "DataCache.h"
@implementation SchoolUtil
+ (SchoolUtil*) instance {
    static SchoolUtil* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) {
            _one = [[ SchoolUtil alloc ] init ];
        }
    }
    return _one;
}
-(id)init {
    if (self = [super init]) {
        // Initialization code here
    }
    return self;
}
- (School*) findSchoolById:(NSString*)schoolId {
    // iterate over all of the schools and find the one with the matching id
    School *retVal = nil;
    for (NSString* schoolSection in [UDataCache.schools allKeys]) {
        NSMutableArray *schools = (NSMutableArray*)[UDataCache.schools objectForKey:schoolSection];
        for(int idx =0; idx < [schools count]; idx++) {
            if ([((School*)schools[idx]).schoolId isEqualToString:schoolId]) {
                retVal = ((School*)schools[idx]);
                break;
            }
        }
    }
    return retVal;
}
@end
