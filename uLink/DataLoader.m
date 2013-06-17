//
//  DataLoader.m
//  ulink
//
//  Created by Christopher Cerwinski on 5/14/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "DataLoader.h"
#import "DataCache.h"
#import "AppMacros.h"

@implementation DataLoader
@synthesize uListDelegate;

- (void)loadUListListingData
{
    [self performSelector:@selector(loadUListListingDataDelayed) withObject:nil afterDelay:3];
}

/*
 * Set this method up to load the next set
 * of result data from the cache.  Later on
 * down the line, we may even decide to only
 * load next 10-30 rows of data from the db...
 */
- (void)loadUListListingDataDelayed
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:ULIST_LISTING_BATCH_SIZE];
    
    /* log loading of batch */
    NSLog(@"ulist data -- loading batch #: %i; searchResultOfSets: %i", uListDelegate.fetchBatch, [uListDelegate.searchResultOfSets count]);
    
    /* 
     * Grab the next set of listings from database
     * Set up hydrate to only grab X new listings @ 1 time
     */
    if ([UDataCache.uListListings count] > 0) {
        uListDelegate.retries = 0;
        for (int i = 0; (i<ULIST_LISTING_BATCH_SIZE && i<[UDataCache.uListListings count]); i++) {
            [array addObject:[UDataCache.uListListings objectAtIndex:i]];
        }
        [uListDelegate.searchResultOfSets addObjectsFromArray:array];
        
        if (uListDelegate.initializeSpinner) [uListDelegate.initializeSpinner stopAnimating];
        
    } else if ([UDataCache.uListListings count] < ULIST_LISTING_BATCH_SIZE) {
        if (uListDelegate.retries <= MIN_RETRIES && [UDataCache.uListListings count] <= 0)
            uListDelegate.retries++;
        else
            uListDelegate.noMoreResultsAvail = YES;
    }
    
    /* 
     * increment batch to fetch (only if we are not retrying)
     * & log next batch fetch event 
     */
    if (uListDelegate.retries == 0)
        uListDelegate.fetchBatch ++;
    
    if (!uListDelegate.noMoreResultsAvail) {
        NSLog(@"ulist data -- fetching batch #: %i; retries: %i", uListDelegate.fetchBatch, uListDelegate.retries);
        NSString *query;
        if (uListDelegate.queryType == kListingQueryTypeSearch) {
            // qt=s&mc=main_cat&c=sub_cat&sid=school_id&b=initial_batch&t=search_text
            query = [[NSString alloc] initWithFormat:@"qt=s&sid=%@&b=%i&t=%@", uListDelegate.school.schoolId, uListDelegate.fetchBatch, uListDelegate.searchText];
        } else if (uListDelegate.queryType == kListingQueryTypeSubCategory) {
            /*
             * grab the next batch of listing data (if there is any...)
             */
            query = [[NSString alloc] initWithFormat:@"qt=%@&mc=%@&c=%@&sid=%@&b=%i", @"c", [uListDelegate.mainCat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], uListDelegate.subCat, uListDelegate.school.schoolId, uListDelegate.fetchBatch];
        } else if (uListDelegate.queryType == kListingQueryTypeSubCategorySearch) {
            query = [[NSString alloc] initWithFormat:@"qt=s&mc=%@&c=%@&sid=%@&b=%i&t=%@", [uListDelegate.mainCat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], [uListDelegate.subCat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], uListDelegate.school.schoolId, uListDelegate.fetchBatch, uListDelegate.searchText];
        }
     
        [UDataCache hydrateUListListingsCache:query];
    }
    
    /* use reload data for right now, down the line, we have to switch this
     * to maybe load specific sections
     * EX. Every time a new batch is loaded make that a new section (keep
     *     track of the sections in table
     */
    [uListDelegate.tableView reloadData];
    uListDelegate.loading = NO;
}

@end


