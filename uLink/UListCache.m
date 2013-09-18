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
#import "CachedItemData.h"

@implementation UListCache
@synthesize  cache, cachedItems, listQueue;

// initialize the array with the number of schools in the cache
-(id)init {
    if (self = [super init]) {
        // initialize code here..
        
        int maxSchoolId = 0;
        NSEnumerator *enumerator = [[UDataCache schools] keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) {
            NSMutableArray *tmp = [[UDataCache schools] objectForKey:key];
            for (School *s in tmp) {
                if ([s.schoolId intValue] > maxSchoolId)
                    maxSchoolId = [s.schoolId intValue];
            }
        }

        //NSLog(@"max school id found is: %i", maxSchoolId);
        
        // initialize cache
        cache = [NSMutableArray arrayWithCapacity:maxSchoolId];
        self.cachedItems = 0;
        
        for (int idx=0; idx<cache.count; idx++) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [cache addObject:dict];
        }

        // initialize queue
        listQueue = [[NSMutableArray alloc] initWithCapacity:ULIST_CACHE_ALLOWANCE];
    }
    return self;
}

//
//  1) Determine slot in the array to add data to (will be determined by sch. id)
//  2) Using NSMutableDictionary, add result (key = category)
//  3) Only allow up to X amount of categories to be cached per school
//  4) Use category "ALL" for random searches on words, etc..
//
-(void) addToCache:(NSInteger)schoolId category:(NSString*)category listingData:(NSMutableArray*)listingData {
    
    // grab the dictionary at the array index
    NSMutableDictionary *dict = [cache objectAtIndex:schoolId];
    if (dict != nil) {
        
        CachedItemData *tmp = nil;
        CachedItemData *data = [[CachedItemData alloc] init];
        data.schoolId = [NSString stringWithFormat:@"%i", schoolId];
        data.category = category;
        
        // we are only caching up to a certain allowance and we will use a queue
        // to store the school id and categories we have cached currently
        
        // if we are already caching this data, then refresh
        if ([listQueue containsObject:data]) {
            // move to front and shift contents
            NSInteger idxObj = [listQueue indexOfObject:data];
            for (int idx = 0; idx <= idxObj; idx++) {
                tmp = (CachedItemData*)[listQueue objectAtIndex:idx];
                [listQueue insertObject:data atIndex:idx];
                data = tmp;
            }
        }
        else {
            if ([listQueue full]) {
                CachedItemData *dq = (CachedItemData*)[listQueue dequeue];
                [self removeFromCache:[dq.schoolId intValue] category:dq.category];
            }
            
            // enqueue our cache data
            [listQueue enqueue:data];
            
            // if we have a dictionary object, then add listings data to cache
            // using the category as the key
            [dict setValue:listingData forKey:category];
            cachedItems++;
        }
    }
}

//
//  Grab the dictionary for the school cached data
//  Remove the cached data using 'category' as key
//
-(void)removeFromCache:(NSInteger)schoolId category:(NSString*)category {
    
    NSMutableDictionary *dict = [cache objectAtIndex:schoolId];
    if (dict != nil) {
        [dict removeObjectForKey:category];
        cachedItems--;
    }
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
