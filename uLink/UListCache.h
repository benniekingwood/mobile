//
//  UListCache.h
//  ulink
//
//  Created by Christopher Cerwinski on 7/18/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//
//  UList Data Cache:
//      This class will keep track of caching all data
//      that user has collected in uList module of the
//      uLink application
//
//
//  Data Structure:
//      NSMutableArray [school max id];
//          -> NSMutableDictionary < key = cat id, val = array of listings >
//
//  TODO: Set up a queue style structure; we do not want to cache too much
//        data and take up memory on the iphone app pool
//


#import <Foundation/Foundation.h>
#import "Queue.h"

@interface UListCache : NSObject
@property (strong, nonatomic) NSMutableArray *cache;
@property (nonatomic) NSInteger cachedItems;
@property (strong, nonatomic) NSMutableArray *listQueue;

/*
    Add listing result to the data cache
 */
-(void) addToCache:(NSInteger) schoolId category:(NSString*)category listingData:(NSMutableArray*)listingData;

/* 
    Remove cached data by school id and category 
*/
-(void) removeFromCache:(NSInteger)schoolId category:(NSString*)category;

/*
    Get cached data by school id and category
 */
-(NSMutableArray*) getCachedData:(NSInteger)schoolId category:(NSString*)category;

/*
    Clear ALL of the cached data
 */
-(void) clear;

/*
    Determine if cache is empty
 */
-(BOOL) empty;

@end