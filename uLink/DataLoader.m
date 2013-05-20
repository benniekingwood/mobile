//
//  DataLoader.m
//  ulink
//
//  Created by Christopher Cerwinski on 5/14/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "DataLoader.h"
#import "DataCache.h"

@implementation DataLoader
@synthesize uListDelegate;

- (void)loadUListListingData
{
    [self performSelector:@selector(loadUListListingDataDelayed) withObject:nil afterDelay:3];
}

// TODO: Make capacity, # of data rows to load a constant
/*
 * Set this method up to load the next set
 * of result data from the cache.  Later on
 * down the line, we may even decide to only
 * load next 10-30 rows of data from the db...
 */
- (void)loadUListListingDataDelayed
{
    uListDelegate.fetchBatch ++;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    
    // Grab the next set of listings from database
    // Set up hydrate to only grab 10 new listings @ 1 time
    // simply to test...
    if ([UDataCache.uListListings count] > 0) {
        for (int i = 0; i < 10; i++) {
            [array addObject:[UDataCache.uListListings objectAtIndex:i]];
        }
    }
    
    [uListDelegate.searchResultOfSets addObjectsFromArray:array];
    NSLog(@"loadUlistListingDataDelayed searchResultOfSets: %i", [uListDelegate.searchResultOfSets count]);
    [uListDelegate.tableView reloadData];
    uListDelegate.loading = NO;
}

@end


