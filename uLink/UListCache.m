//
//  UListCache.m
//  ulink
//
//  Created by Christopher Cerwinski on 7/18/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListCache.h"
#import "Queue.h"
#import "DataCache.h"
@implementation UListCache
@synthesize  cache, cachedItems;

// initialize the array with the number of schools in the cache
-(id)init {
    if (self = [super init]) {
        // initialize code here..
        cache = [NSMutableArray arrayWithCapacity:[UDataCache schools].count];
        self.cachedItems = 0;
        
        for (int idx=0; idx<cache.count; idx++) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [cache addObject:dict];
        }
    }
    return self;
}

//
//  1) Determine slot in the array to add data to (will be determined by sch. id)
//  2) Using NSMutableDictionary, add result (key = category)
//  3) Only allow up to X amount of categories to be cached per school
//  4)
//
-(void) addToCache:(NSInteger)schoolId category:(NSString*)category listingData:(NSMutableArray*)listingData {
    
    // grab the dictionary at the array index
    NSMutableDictionary *dict = [cache objectAtIndex:schoolId];
    if (dict != nil) {
        // if we have a dictionary object, then add listings data to cache
        // using the category as the key
        [dict setValue:listingData forKey:category];
    }
    
    cachedItems++;
}

//
//  Returns a mutable array based on the school id and category of cached data
//  that you want.  If there is no data, then return nil
//
-(NSMutableArray*) getCachedData:(NSInteger)schoolId category:(NSString*)category {
    NSMutableArray *data = nil;
    
    // grab the dictionary at the array index using school id
    NSMutableDictionary *dict = [cache objectAtIndex:schoolId];
    if (dict != nil) {
        // grab the listing data using the category as key
        data = [dict objectForKey:category];
    }
    
    return data;
}

//
// Remove all listing cached elements
//
-(void) clear {
    for (int idx=0; idx<cache.count; idx++) {
        [(NSMutableDictionary*)[cache objectAtIndex:idx] removeAllObjects];
    }
    cachedItems = 0;
}

//
//  Determine if the cache is empty
//
-(BOOL) empty {
    return (self.cachedItems == 0);
}

@end
