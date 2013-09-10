//
//  DataCache.m
//  uLink
//
//  Created by Bennie Kingwood on 12/8/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "DataCache.h"
#import "School.h"
#import "UListCategory.h"
#import "TextUtil.h"
#import "SnapshotCategory.h"
#import "SnapshotUtil.h"
#import "EventUtil.h"
#import "Tweet.h"
#import "AppDelegate.h"
#import <SDWebImage/SDWebImageDownloader.h>
@interface DataCache() {
    TextUtil *textUtil;
    NSDateFormatter *tweetDateFormatter;
    int activeProcesses;
    BOOL indicatorVisible;
}
- (void) buildSchoolList:(id)schoolsRaw;
- (void) buildUListCategoryList:(NSArray*)json;
- (void) buildUListListingList:(NSArray*)json forSessionUser:(BOOL)forSessionUser;
- (void) retrieveSnapshots:(NSString*)categoryId;
- (void) buildTrends:(id)trendsRaw;
- (void) buildTweets:(id)tweetsRaw;
- (void) buildTimes;
- (void) initImageCaches;
@end
@implementation DataCache
#pragma mark CACHE CONSTANTS
/*
 * The following are the cache age limits in seconds.  When 
 * rehydrating the caches will will only pull new 
 * data if the current cache data is older than the 
 * age limit.
 */
const double CACHE_AGE_LIMIT_SNAP_CATEGORIES = 604800;  // 7 days
const double CACHE_AGE_LIMIT_SNAPSHOTS = 1800;  // 30 minutes
const double CACHE_AGE_LIMIT_TWEETS = 900;  // 15 minutes
const double CACHE_AGE_LIMIT_EVENTS = 86400;  // 1 days
const double CACHE_AGE_LIMIT_SCHOOLS = 604800;  // 7 days
const double CACHE_AGE_LIMIT_IMAGES = 2419200; // 28 days
const double CACHE_AGE_LIMIT_ULIST_CATEGORIES = 604800; // 7 days
const double CACHE_AGE_LIMIT_LISTINGS = 1800;  // 30 minutes

#pragma mark
@synthesize schools;
@synthesize schoolSections;
@synthesize uListCategories = _uListCategories;
@synthesize uListCategorySections = _uListCategorySections;
@synthesize uListListings = _uListListings;
@synthesize sessionUser;
@synthesize topSnapper;
@synthesize events;
@synthesize featuredEvents;
@synthesize snapshots;
@synthesize snapshotCategories;
@synthesize tweets;
@synthesize trends;
@synthesize images;
@synthesize eventImageMedium, eventImageThumbs;
@synthesize snapImageMedium, snapImageThumbs;
@synthesize userImageThumbs, userImageMedium;
@synthesize tweetUserImages;
@synthesize listingImageMedium, listingImageThumbs;
+ (DataCache*) instance {
    static DataCache* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) { 
            _one = [[ DataCache alloc ] init ];
        }
    }
    return _one;
}
-(id)init {
    if (self = [super init]) {
        textUtil = [TextUtil instance];
        tweetDateFormatter = [[NSDateFormatter alloc] init];
        [tweetDateFormatter setDateFormat:@"E, d MMMM yyyy HH:m:s Z"];
        [self buildTimes];
        activeProcesses = 0;
        [self initImageCaches];
    }
    return self;
}

- (void) updateListingCaches:(Listing*)listing type:(ListingSaveType)type {
    switch(type) {
        case kListingSaveTypeAdd:
            // update the user's session listings
            // [TODO in future when cache is ready] update the listign from the global listings cache
            break;
        case kListingSaveTypeDelete:
            // remove listing from the session user
            [self.sessionUser.listings removeObject:listing];
            // remove the old event image since it changed
            for (int x=0; x<[listing.imageUrls count]; x++) {
                [self removeListingImage:[listing.imageUrls objectAtIndex:x] schoolId:listing.schoolId cacheModel:IMAGE_CACHE_LISTING_MEDIUM];
                [self removeListingImage:[listing.imageUrls objectAtIndex:x] schoolId:listing.schoolId cacheModel:IMAGE_CACHE_LISTING_THUMBS];
            }
             // [TODO in future when cache is ready] remove the listign from the global listings cache
            break;
        case kListingSaveTypeUpdate:
            // update the user's session listings
             // [TODO in future when cache is ready] update the listign from the global listings cache
            break;
    }
}

- (void) clearCache {
    self.sessionUser = nil;
    self.topSnapper = nil;
    self.events = nil;
    self.snapshots = nil;
    self.tweets = nil;
    self.trends = nil;
    self.snapshotCategories = nil;
    self.uListListings = nil;
    [self clearAllModelImageCaches];
}

-(void) clearAllModelImageCaches {
    self.eventImageThumbs = nil;
    self.snapImageThumbs = nil;
    self.userImageThumbs = nil;
    self.eventImageMedium = nil;
    self.snapImageMedium = nil;
    self.userImageMedium = nil;
    self.tweetUserImages = nil;
    self.listingImageThumbs = nil;
    self.listingImageMedium = nil;
}
- (void) initImageCaches {
    if(self.userImageThumbs == nil) {
        self.userImageThumbs = [[NSMutableDictionary alloc] init];
    } else {
        [self.userImageThumbs removeAllObjects];
    }
    if(self.userImageMedium == nil) {
        self.userImageMedium = [[NSMutableDictionary alloc] init];
    } else {
        [self.userImageMedium removeAllObjects];
    }
    if(self.snapImageThumbs == nil) {
        self.snapImageThumbs = [[NSMutableDictionary alloc] init];
    }
    if (self.eventImageThumbs == nil) {
        self.eventImageThumbs = [[NSMutableDictionary alloc] init];
    }
    if(self.snapImageMedium == nil) {
        self.snapImageMedium = [[NSMutableDictionary alloc] init];
    }
    if (self.eventImageMedium == nil) {
        self.eventImageMedium = [[NSMutableDictionary alloc] init];
    }
    if (self.tweetUserImages == nil) {
        self.tweetUserImages = [[NSMutableDictionary alloc] init];
    }
    if (self.listingImageMedium == nil) {
        self.listingImageMedium = [[NSMutableDictionary alloc] init];
    }
}
- (void) buildTimes {
    if (self.times == nil) {
        self.times = [[NSArray alloc] initWithObjects:@"",@"12:00 AM",@"12:15 AM",@"12:30 AM",@"12:45 AM",@"01:00 AM",@"01:15 AM",@"01:30 AM",@"01:45 AM",@"02:00 AM",@"02:15 AM",@"02:30 AM",@"02:45 AM",@"03:00 AM",@"03:15 AM",@"03:30 AM",@"03:45 AM",@"04:00 AM",@"04:15 AM",@"04:30 AM",@"04:45 AM",@"05:00 AM",@"05:15 AM",@"05:30 AM",@"05:45 AM",@"06:00 AM",@"06:15 AM",@"06:30 AM",@"06:45 AM",@"07:00 AM",@"07:15 AM",@"07:30 AM",@"07:45 AM",@"08:00 AM",@"08:15 AM",@"08:30 AM",@"08:45 AM",@"09:00 AM",@"09:15 AM",@"09:30 AM",@"09:45 AM",@"10:00 AM",@"10:15 AM",@"10:30 AM",@"10:45 AM",@"11:00 AM",@"11:15 AM",@"11:30 AM",@"11:45 AM",@"12:00 PM",@"12:15 PM",@"12:30 PM",@"12:45 PM",@"01:00 PM",@"01:15 PM",@"01:30 PM",@"01:45 PM",@"02:00 PM",@"02:15 PM",@"02:30 PM",@"02:45 PM",@"03:00 PM",@"03:15 PM",@"03:30 PM",@"03:45 PM",@"04:00 PM",@"04:15 PM",@"04:30 PM",@"04:45 PM",@"05:00 PM",@"05:15 PM",@"05:30 PM",@"05:45 PM",@"06:00 PM",@"06:15 PM",@"06:30 PM",@"06:45 PM",@"07:00 PM",@"07:15 PM",@"07:30 PM",@"07:45 PM",@"08:00 PM",@"08:15 PM",@"08:30 PM",@"08:45 PM",@"09:00 PM",@"09:15 PM",@"09:30 PM",@"09:45 PM",@"10:00 PM",@"10:15 PM",@"10:30 PM",@"10:45 PM",@"11:00 PM",@"11:15 PM",@"11:30 PM",@"11:45 PM", nil];
    }
}
- (NSURL*)buildURL:(NSString*)server api:(NSString*)api query:(NSString*)query {

    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@%@", server, api, [query length] ? @"?" : EMPTY_STRING, [query length] ? [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : EMPTY_STRING];
    NSURL *URL = [NSURL URLWithString:URLString];
    //NSLog(@"%@", URL);
    return URL;
}
- (NSURL*)buildURLWithDictionary:(NSString*)server api:(NSString*)api query:(NSDictionary*)query {
    
    int valuePairCount = [query count];
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", server, api, [query count] ? @"?" : @""];
    
    /* append each key-value pair in the dictionary */
    for (id queryStr in query) {
        [URLString stringByAppendingFormat:@"%@=%@%@", queryStr, [query objectForKey:queryStr], (valuePairCount > 1) ? @"&" : @""];
        valuePairCount--;
    }

    /* build url with url string */
    NSURL *URL = [NSURL URLWithString:URLString];
    NSLog(@"%@", URLString);
    return URL;
}
- (void) incrementActiveProcesses:(int)processCount {
    @synchronized(self) {
        activeProcesses+=processCount;
        // if activity indicator is not shown, show it
        if(activeProcesses > 0 && !indicatorVisible) {
            //[UAppDelegate showActivityIndicator];
            indicatorVisible = YES;
        }
    }
}
- (void) decrementActiveProcesses {
    @synchronized(self) {
        activeProcesses--;
        // hide activity indicator
        if(activeProcesses <= 0 && indicatorVisible) {
            activeProcesses = 0;
            indicatorVisible = NO;
            //[UAppDelegate hideActivityIndicator];
        }
    }
}
- (void) rehydrateCaches:(BOOL)checkAge {
    [self initImageCaches];
    activeProcesses = 0;
    [self incrementActiveProcesses:5];
    [self rehydrateSessionUser];
    // rehydration of the snapshot categories will implicitly hydrate the Snapshots
    [self rehydrateSnapshotCategoriesCache:checkAge];
    [self rehydrateEventsCache:checkAge];
    [self rehydrateTweetsCache:checkAge];
    [self rehydrateTrendsCache:checkAge];
}
- (void) hydrateCaches {
    [self initImageCaches];
    [self hydrateSnapshotsCache];
    [self hydrateEventsCache];
    [self hydrateTweetsCache];
    [self hydrateTrendsCache];
}
- (void) rehydrateSchoolCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        // grab a school
        NSArray *values = [self.schools allValues];
        if ([values count] > 0) {
            NSMutableArray *sectionSchools = [values objectAtIndex:0];
            School *school = [sectionSchools objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:school.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_SCHOOLS) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        [self hydrateSchoolCache];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateUListCategoriesCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    
    if (checkAge) {
        NSArray *values = [self.uListCategories allValues];
        if ([values count] > 0) {
            NSMutableArray *sectionCategories = [values objectAtIndex:0];
            UListCategory *category = [sectionCategories objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:category.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_ULIST_CATEGORIES) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        [self hydrateUListCategoryCache];
    }
    else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateSessionUserListings:(BOOL)checkAge notification:(NSString*)notification {
    BOOL rehydrate = TRUE;
    
    if (checkAge) {
        if ([self.sessionUser.listings count] > 0) {
            Listing *listing = [self.sessionUser.listings objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:listing.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_LISTINGS) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        // clear out the image cache to maintain memory
        [self.listingImageMedium removeAllObjects];
        [self.listingImageThumbs removeAllObjects];
        
        [self hydrateSessionUserListings:notification];
    }
    else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateUListListingsCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    
    if (checkAge) {
        if ([self.uListListings count] > 0) {
            Listing *listing = [self.uListListings objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:listing.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_LISTINGS) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        // clear out the image cache to maintain memory
        [self.listingImageMedium removeAllObjects];
        [self.listingImageThumbs removeAllObjects];
        
        // TODO: use listings data cache to rehydrate if possible
    }
    else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateEventsCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        if ([self.events count] > 0) {
            Event *event = [self.events objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:event.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_EVENTS) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        // clear out the image cache to maintain memory
        [self.eventImageMedium removeAllObjects];
        [self.eventImageThumbs removeAllObjects];
        [self hydrateEventsCache];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateSnapshotsCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        // grab a snapshot 
        NSArray *values = [self.snapshots allValues];
        if ([values count] > 0) {
            Snap *snap = [values objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:snap.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_SNAPSHOTS) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        // clear out the image cache to maintain memory
        [self.snapImageMedium removeAllObjects];
        [self.snapImageThumbs removeAllObjects];
        [self hydrateSnapshotsCache];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateSnapshotCategoriesCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        // grab a snapshot category
        NSArray *values = [self.snapshotCategories allValues];
        if ([values count] > 0) {
            SnapshotCategory *cat = [values objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:cat.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_SNAP_CATEGORIES) {
                rehydrate = FALSE;
            } 
        }
    }
    if (rehydrate) {
        [self hydrateSnapshotCategoriesCache:YES];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateTweetsCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        if ([self.tweets count] > 0) {
            Tweet *tweet = [self.tweets objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:tweet.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_TWEETS) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        // clear out the image cache to maintain memory
        [self.tweetUserImages removeAllObjects];
        [self hydrateTweetsCache];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateTrendsCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        /* NOTE: as of 01.12.13, we do not 
         * need to check an age for the trends
         * since we handle it on the server side.
         */
    }
    if (rehydrate) {
        [self hydrateTrendsCache];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateImageCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        if ([self.images count] > 0) {
            // grab the cache age from the dictionary 
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:[self.images objectForKey:KEY_CACHE_AGE]];
            if (timeElapsed <= CACHE_AGE_LIMIT_IMAGES) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        [self hydrateImageCache];
    }
}
- (void) rehydrateSessionUser {
    @try {
        //clock_t start = clock();
        [self performSelectorInBackground:@selector(hydrateSessionUserListings:) withObject:nil];
        NSDate *start = [NSDate date];
        dispatch_queue_t userQueue = dispatch_queue_create(DISPATCH_USER, NULL);
        dispatch_async(userQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_USERS_USER];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.userId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if ([data length] > 0 && error == nil) {
                    NSError* err;
                    NSDictionary* json = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:kNilOptions
                                          error:&err];
                    NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                     
                    if([(NSString*)result isEqualToString:@"true"]) {
                        NSDictionary *response = [json objectForKey:JSON_KEY_RESPONSE];
                        @synchronized(self) {
                            // clear out the user's snaps and events
                            if(UDataCache.sessionUser.snaps != nil) {
                                [UDataCache.sessionUser.snaps removeAllObjects];
                            }
                            if(UDataCache.sessionUser.events != nil) {
                                [UDataCache.sessionUser.events removeAllObjects];
                            }
                            [UDataCache.sessionUser hydrateUser:response isSessionUser:YES];
                            // send a notification the ucampus view controller
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UCAMPUS_VIEW_CONTROLLER object:nil];
                        }
                    } else {
                    }
                    NSDate *end = [NSDate date];
                    NSLog(@"rehydrateSessionUser complete: %f ms", [end timeIntervalSinceDate:start] * 1000);
                } else {// TODO: report error?
                }
                [self decrementActiveProcesses];
            }];
        });
    }
    @catch (NSException *exception) { NSLog(@"Exception: %@", [exception reason]); } // TODO: report error?
}

- (void) hydrateImageCache {
    //clock_t start = clock();
    NSDate *start = [NSDate date];
    // load the default images into the image dictionary
    if (self.images == nil) {
        self.images = [[NSMutableDictionary alloc] init];
    } else{
        [self.images removeAllObjects];
    }
    [self.images setValue:[NSDate date] forKey:KEY_CACHE_AGE];
    [self.images setValue:[UIImage imageNamed:@"default_user.jpg"] forKey:KEY_DEFAULT_USER_IMAGE];
    [self.images setValue:[UIImage imageNamed:@"default_snap.png"] forKey:KEY_DEFAULT_SNAP_IMAGE];
    [self.images setValue:[UIImage imageNamed:@"default_campus_event.png"] forKey:KEY_DEFAULT_EVENT_IMAGE];
    [self.images setValue:[UIImage imageNamed:@"default_featured_event.png"] forKey:KEY_DEFAULT_FEATURED_EVENT_IMAGE];
    NSDate *end = [NSDate date];
    NSLog(@"hydrateImageCache complete: %f ms", [end timeIntervalSinceDate:start] * 1000);
}
- (void) hydrateSchoolCache {
    @try {
        //clock_t start = clock();
        NSDate *start = [NSDate date];
        dispatch_queue_t schoolQueue = dispatch_queue_create(DISPATCH_SCHOOL, NULL);
        dispatch_async(schoolQueue, ^{
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_SCHOOLS_SCHOOL]]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        
                        NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                        if([(NSString*)result isEqualToString:@"true"]) {
                            @synchronized(self) {
                                if(self.schoolSections == nil) {
                                    self.schoolSections = [[NSMutableArray alloc] initWithObjects:@"", nil];
                                }  else {
                                    [self.schoolSections removeAllObjects];
                                }
                                if (self.schools == nil) {
                                    self.schools = [[NSMutableDictionary alloc] init];
                                } else{
                                    [self.schools removeAllObjects];
                                }
                                [self buildSchoolList:(NSArray*)[json objectForKey:JSON_KEY_RESPONSE]];
                            }
                        } else {
                            // TODO: report error?
                        }
                        NSDate *end = [NSDate date];
                        NSLog(@"hydrateSchoolCache complete: %f ms", [end timeIntervalSinceDate:start] * 1000);
                    } else {// TODO: report error?
                    }
                 [self decrementActiveProcesses];
            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}

/*
 * Hydrate the uList category cache
 *
 */
- (void) hydrateUListCategoryCache {
    @try {
        //clock_t start = clock();
        NSDate *start = [NSDate date];
        dispatch_queue_t categoryQueue = dispatch_queue_create(DISPATCH_ULIST_CATEGORY, NULL);
        dispatch_async(categoryQueue, ^{
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER_3737 stringByAppendingString:API_ULIST_CATEGORIES]]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                // if there is valid data
                if (data)
                {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                    
                    if (httpResponse.statusCode==200)
                    {
                        NSError* err;
                        NSArray* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        @synchronized(self) {
                            if(self.uListCategorySections == nil) {
                                self.uListCategorySections = [[NSMutableArray alloc] init];
                            }  else {
                                [self.uListCategorySections removeAllObjects];
                            }
                            if (self.uListCategories == nil) {
                                self.uListCategories = [[NSMutableDictionary alloc] init];
                            } else{
                                [self.uListCategories removeAllObjects];
                            }
                            [self buildUListCategoryList:json];
                        }

                    } 
                    
                    NSDate *end = [NSDate date];
                    NSLog(@"hydrateUListCategoryCache complete: %f ms", [end timeIntervalSinceDate:start] * 1000);
                    [self decrementActiveProcesses];
                }
            }]; // end sendAsynchronousRequest
        }); // end dispatch_async
    }
    @catch (NSException *exception) {} // TODO: report error?
}

/*
    NOTE: modify this method to only return a set amount of listings to
    preserve performance and integrity of ulink app; add query parameters
 
     qt - query type
     can have values of "s", "c", or "u"
     "s" is for searching
     "c" is for category loading
     "u" is for user listing retrieval
     if you do qt=s, then you have to pass the following params: sid, t
     sid = school id
     t = is the search text
     for qt=c (category searching)
     you need, mc, c, and sid
     mc="main category text"
     c="sub category text"
     sid=school id
     finally qt=u, you just need uid=user id
 */
- (void) hydrateUListListingsCache:(NSString*) query notification:(NSString*)notification {
    @try {
        NSDate *start = [NSDate date];
        dispatch_queue_t listingQueue = dispatch_queue_create(DISPATCH_ULIST_LISTING, NULL);
        dispatch_async(listingQueue, ^{
            /* build the url w/ or w/o query string */
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[self buildURL:URL_SERVER_3737 api:API_ULIST_LISTINGS query:query]];
            [req setHTTPMethod:HTTP_GET];
            NSLog(@"ulist listing request: %@", req.URL);
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                // if there is valid data
                if (data)
                {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                    
                    if (httpResponse.statusCode==200)
                    {
                        NSError* err;
                        NSArray* json = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:kNilOptions
                                         error:&err];
                        @synchronized(self) {
                            if (self.uListListings == nil) {
                                self.uListListings = [[NSMutableArray alloc] init];
                            } else{
                                [self.uListListings removeAllObjects];
                            }
                            [self buildUListListingList:json forSessionUser:NO];
                
                            // Send a notification to observer if necessary to notify a view that the listings are ready
                            if(notification != nil && ![notification isEqualToString:EMPTY_STRING]){
                                NSLog(@"DataCache - done building listings, sending notificaiton.");
                                [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
                            }
                        }
                        
                    }
                    
                    NSDate *end = [NSDate date];
                    NSLog(@"hydrateUListListingsCache complete: %f ms", [end timeIntervalSinceDate:start] * 1000);
                    [self decrementActiveProcesses];
                }
            }]; // end sendAsynchronousRequest
        }); // end dispatch_async
    }
    @catch (NSException *exception) {} // TODO: report error?
}

/*
 * This function will load the listings based on the passed in 
 * user id.
 */
- (void) hydrateSessionUserListings:(NSString*)notification {
    @try {
        //clock_t start = clock();
        NSDate *start = [NSDate date];
        dispatch_queue_t myListingQueue = dispatch_queue_create(DISPATCH_MY_LISTING, NULL);
        dispatch_async(myListingQueue, ^{
            
            NSString *requestData = @"?qt=u";
            requestData = [requestData stringByAppendingString:[@"&uid=" stringByAppendingString:self.sessionUser.userId]];
            NSString *fullURL = [[URL_SERVER_3737 stringByAppendingString:API_ULIST_LISTINGS] stringByAppendingString:requestData];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullURL]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                // if there is valid data
                if (data)
                {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                    
                    if (httpResponse.statusCode==200)
                    {
                        NSError* err;
                        NSArray* json = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:kNilOptions
                                         error:&err];
                        @synchronized(self) {
                            if (self.sessionUser.listings == nil) {
                                self.sessionUser.listings = [[NSMutableArray alloc] init];
                            } else{
                                [self.sessionUser.listings removeAllObjects];
                            }
                            [self buildUListListingList:json forSessionUser:YES];
                        }
                        
                        // Send a notification to observer if necessary to notify a view that the listings are ready
                        if(notification != nil && ![notification isEqualToString:EMPTY_STRING]){
                            NSLog(@"DataCache - done building listings for session user, sending notificaiton.");
                            [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
                        }
                    }
                    
                    NSDate *end = [NSDate date];
                    NSLog(@"hydrateSessionUserListings complete: %f ms", [end timeIntervalSinceDate:start] * 1000);
                    [self decrementActiveProcesses];
                } else {}
            }]; // end sendAsynchronousRequest
        }); // end dispatch_async
    }
    @catch (NSException *exception) {} // TODO: report error?
}

- (void) hydrateEventsCache {
    @try {
        //clock_t start = clock();
        NSDate *start = [NSDate date];
        dispatch_queue_t eventsQueue = dispatch_queue_create(DISPATCH_EVENTS, NULL);
        dispatch_async(eventsQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_EVENTS_EVENTS];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.schoolId];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.userId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if ([data length] > 0 && error == nil) {
                    NSError* err;
                    NSDictionary* json = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:kNilOptions
                                          error:&err];
                   
                    NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                    if([(NSString*)result isEqualToString:@"true"]) {
                        @synchronized(self) {
                            if(self.events == nil) {
                                self.events = [[NSMutableArray alloc] init];
                            } else {
                                [self.events removeAllObjects];
                            }
                            
                            if (self.featuredEvents == nil) {
                                self.featuredEvents = [[NSMutableArray alloc] init];
                            } else {
                                [self.featuredEvents removeAllObjects];
                            }
                            // build the events, and featured events
                            self.events = [UEventUtil hydrateEvents:[json objectForKey:JSON_KEY_RESPONSE] eventCollection:self.events hydrationType:kEventHydrationRegular];
                            self.featuredEvents = [UEventUtil hydrateEvents:[json objectForKey:JSON_KEY_RESPONSE] eventCollection:self.featuredEvents hydrationType:kEventHydrationFeatured];
                        }
                    } else {
                        // TODO: report error?
                    }
                } else {// TODO: report error?
                }
                NSDate *end = [NSDate date];
                NSLog(@"hydrateEventsCache complete: %f ms", [end timeIntervalSinceDate:start] * 1000);
                 [self decrementActiveProcesses];
            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}

- (void) hydrateSnapshotCategoriesCache:(BOOL)implicitHydrateSnapshots {
    @try {
        //clock_t start = clock();
        NSDate *start = [NSDate date];
        dispatch_queue_t snapCategoriesQueue = dispatch_queue_create(DISPATCH_SNAPSHOT_CATEGORIES, NULL);
        dispatch_async(snapCategoriesQueue, ^{
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_SNAPSHOTS_SNAP_CATEGORIES]]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if ([data length] > 0 && error == nil) {
                    NSError* err;
                    NSDictionary* json = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:kNilOptions
                                          error:&err];
                    NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                    if([(NSString*)result isEqualToString:@"true"]) {
                        @synchronized(self) {
                            if(self.snapshotCategories == nil) {
                                self.snapshotCategories = [[NSMutableDictionary alloc] init];
                            } else {
                                [self.snapshotCategories removeAllObjects];
                            }
                            self.snapshotCategories = [USnapshotUtil buildSnapshotCategories:(NSArray*)[json objectForKey:JSON_KEY_RESPONSE] snapshotCategories:self.snapshotCategories];
                            if(implicitHydrateSnapshots) {
                                [self hydrateSnapshotsCache];
                            }
                        }
                    } else {
                        // TODO: report error?
                    }
                } else {// TODO: report error?
                }
                NSDate *end = [NSDate date];
                NSLog(@"hydrateSnapshotCategoriesCache complete: %f ms", [end timeIntervalSinceDate:start] * 1000);
                [self decrementActiveProcesses];
            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}

- (void) hydrateSnapshotsCache {
    @synchronized(self) {
        // iterate over the categories
        NSEnumerator *e = [self.snapshotCategories keyEnumerator];
        id catId;
        while (catId = [e nextObject]) {
            /*
             * Retreive the snapshot data for each category
             *   
             * Format [category_id][NSMutableArray]
             */
            [self performSelectorInBackground:@selector(retrieveSnapshots:) withObject:catId];
        }
    }
}

- (void) hydrateTrendsCache {
    @try {
        //clock_t start = clock();
        NSDate *start = [NSDate date];
        dispatch_queue_t trendsQueue = dispatch_queue_create(DISPATCH_TRENDS, NULL);
        dispatch_async(trendsQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_UCAMPUS_TRENDS];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.schoolId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                        if([(NSString*)result isEqualToString:@"true"]) {
                            @synchronized(self) {
                                if(self.trends == nil) {
                                    self.trends = [[NSMutableArray alloc] init];
                                } else {
                                    [self.trends removeAllObjects];
                                }
                                [self buildTrends:[json objectForKey:JSON_KEY_RESPONSE]];
                            }
                        } else {
                            // TODO: report error?
                        }
                        NSDate *end = [NSDate date];
                         NSLog(@"hydrateTrendsCache complete: %f ms", [end timeIntervalSinceDate:start] * 1000);
                    } else {// TODO: report error?
                    }
                [self decrementActiveProcesses];

            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}

- (void) hydrateTweetsCache {
    @try {
        //clock_t start = clock();
        NSDate *start = [NSDate date];
        dispatch_queue_t tweetsQueue = dispatch_queue_create(DISPATCH_TWEETS, NULL);
        dispatch_async(tweetsQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_UCAMPUS_TWEETS];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.schoolId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                        if([(NSString*)result isEqualToString:@"true"]) {
                            @synchronized( self ) {
                                if(self.tweets == nil) {
                                    self.tweets = [[NSMutableArray alloc] init];
                                } else {
                                    [self.tweets removeAllObjects];
                                }
                                [self buildTweets:[json objectForKey:JSON_KEY_RESPONSE]];
                            }
                        } else {
                            // TODO: report error?
                        }
                        NSDate *end = [NSDate date];
                        NSLog(@"hydrateTweetsCache complete: %f ms", (NSTimeInterval)[end timeIntervalSinceDate:start] * 1000);
                        
                        //NSLog(@"hydrateTweetsCache complete: %f ms", (double)(clock()-start) / CLOCKS_PER_SEC);
                    } else {// TODO: report error?
                    }
                [self decrementActiveProcesses];

            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}

- (void) buildTrends:(id)trendsRaw {
    for(int idx = 0; idx < 5; idx++) {
        [self.trends addObject:[trendsRaw objectAtIndex:idx]];
    }
}
-(void) buildSchoolList:(id)schoolsRaw {
    NSString *schoolSectionKey = nil;
    // iterate over list of schools
    for (NSDictionary *schoolDict in schoolsRaw) {
        NSString *schoolName = [schoolDict objectForKey:@"name"];
        NSString *schoolShortName = [schoolDict objectForKey:@"short_name"];
        // captialize the first letter of school name
        schoolName = [textUtil capitalizeString:schoolName];
        schoolSectionKey = [schoolName substringToIndex:1];
        // grab array from schools dictionary based on captialized letter
        NSMutableArray *sectionSchools = [self.schools objectForKey:schoolSectionKey];
        // if there is no array for that letter, create one
        if(sectionSchools == nil) {
            sectionSchools = [[NSMutableArray alloc] init];
        }
        // create school object, and add it to the retreived array
        School *school = [[School alloc] init];
        // set the needed properties for the school
        school.name = schoolName;
        school.shortName = schoolShortName;
        school.schoolId = [schoolDict objectForKey:@"id"];;
        school.latitude = [schoolDict objectForKey:@"latitude"];
        school.longitude = [schoolDict objectForKey:@"longitude"];
        school.imageURL = ([[schoolDict objectForKey:@"image_url"] isKindOfClass:[NSNull class]] || [[schoolDict objectForKey:@"image_url"] isEqualToString:@"<null>"]) ? nil : [schoolDict objectForKey:@"image_url"];
        school.shortDescription = [schoolDict objectForKey:@"short_description"];
        school.cacheAge = [NSDate date];
        [sectionSchools addObject:school];
        [self.schools setObject:sectionSchools forKey:schoolSectionKey];
    }
    
    NSArray *keys = [self.schools allKeys];
    // sort the cacheSchools by key
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSEnumerator *ee = [sortedKeys objectEnumerator];
    id key;
    // iterate over the cacheSchools putting each section school in an array
    while (key = [ee nextObject]) { 
        [self.schoolSections addObject:(NSString*)key];
    }
}

/*
 * Build uList Categories from json object passed from
 * hydrateUListCategories
 */
-(void) buildUListCategoryList:(NSArray*)json {
    NSString *uListCategorySectionKey = nil;
    for (id object in json) {
        NSString* uListCategoryName = [(NSString*)object valueForKey:@"name"];        
        uListCategorySectionKey = uListCategoryName;

        // create array for the sub categories of the main category
        NSMutableArray *sectionCategories = [[NSMutableArray alloc] init];
        
        NSArray* uListSubCategories = [(NSArray*)object valueForKey:@"subcategories"];
        
        for (id object in uListSubCategories) {
        
            // create ulist (sub)-category object, and add it to the retreived array
            UListCategory *subCategory = [[UListCategory alloc] init];
            
            // set the name and cache age for category
            subCategory.name = (NSString*)object;
            subCategory.cacheAge = [NSDate date];
        
            // add sub-category to categories array
            [sectionCategories addObject:subCategory];
            [self.uListCategories setObject:sectionCategories forKey:uListCategoryName];
         }
    }
    
    NSArray *keys = [self.uListCategories allKeys];
    // sort the cacheSchools by key
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSEnumerator *ee = [sortedKeys objectEnumerator];
    id key;
    // iterate over the cacheSchools putting each section school in an array
    while (key = [ee nextObject]) {
        [self.uListCategorySections addObject:(NSString*)key];
    }
}

//
// TODO: Add caching down the line?
//
-(void) buildUListListingList:(NSArray*)json forSessionUser:(BOOL)forSessionUser {    
    /* cycle through list of json objects */
    for (id object in json) {
        Listing *listing = [[Listing alloc] init];
        
        listing._id = [(NSString*)object valueForKey:@"_id"];
        listing.userId = [[(NSString*)object valueForKey:@"user_id"] intValue];
        listing.schoolId = [[(NSString*)object valueForKey:@"school_id"] intValue];
        listing.title = [(NSString*)object valueForKey:@"title"];
        listing.username = [(NSString*)object valueForKey:@"username"];
        listing.type = [(NSString*)object valueForKey:@"type"];
        listing.listDescription = [(NSString*)object valueForKey:@"description"];
        listing.mainCategory = [(NSString*)object valueForKey:@"main_category"];
        listing.category = [(NSString*)object valueForKey:@"category"];
        listing.replyTo = [(NSString*)object valueForKey:@"reply_to"];
        listing.shortDescription = [(NSString*)object valueForKey:@"short_description"];
        
        NSString *priceValue = [(NSString*)object valueForKey:@"price"];
        listing.price = (![[object valueForKey:@"price"] isKindOfClass:[NSNull class]]) ? [priceValue doubleValue]  : -37;
        /* Try to extract dates from json data */
        @try {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
            listing.created = [df dateFromString:[(NSString*)object valueForKey:@"created"]];
            listing.expires = [df dateFromString:[(NSString*)object valueForKey:@"expires"]];
        } @catch (NSException *exception) {}

        /* Map sub objects: location, meta, tags, images urls */
        // location
        Location *loc = [[Location alloc] init];
        NSDictionary* listingLocation = [(NSMutableArray*)object valueForKey:@"location"];
        // default all the locational info to the empty string
        loc.street = EMPTY_STRING;
        loc.address1 = EMPTY_STRING;
        loc.address2 = EMPTY_STRING;
        loc.zip = EMPTY_STRING;
        loc.city = EMPTY_STRING;
        loc.state = EMPTY_STRING;
        loc.discloseLocation = EMPTY_STRING;
        if (listingLocation)
        {
            for (id object in listingLocation) {
                @try {
                    if ([(NSString*)object isEqualToString:@"latitude"])
                        loc.latitude = [listingLocation valueForKey:(NSString*)object];
                    if ([(NSString*)object isEqualToString:@"longitude"])
                        loc.longitude = [listingLocation valueForKey:(NSString*)object];
                    if ([(NSString*)object isEqualToString:@"street"])
                        loc.address1 = [listingLocation valueForKey:(NSString*)object];
                    if ([(NSString*)object isEqualToString:@"zip"])
                        loc.zip = [listingLocation valueForKey:(NSString*)object];
                    if ([(NSString*)object isEqualToString:@"city"])
                        loc.city = [listingLocation valueForKey:(NSString*)object];
                    if ([(NSString*)object isEqualToString:@"state"])
                        loc.state = [listingLocation valueForKey:(NSString*)object];
                    if ([(NSString*)object isEqualToString:@"discloseLocation"])
                        loc.discloseLocation = [listingLocation valueForKey:(NSString*)object];
                }
                @catch (NSException *exception) {}
            }
        }
        listing.location = loc;
    
        // tags
        listing.tags = [(NSMutableArray*)object valueForKey:@"tags"];
        
        // meta
        listing.meta = [(NSMutableArray*)object valueForKey:@"meta"];
        
        // image_urls
        listing.imageUrls = [(NSMutableArray*)object valueForKey:@"image_urls"];
        
        
        // add listing to listings array
        if(forSessionUser) {[self.sessionUser.listings addObject:listing];}
        else {[self.uListListings addObject:listing];}
    }
}
 
-(void) retrieveSnapshots:(NSString*)categoryId {
    @try {
        dispatch_queue_t snapsQueue = dispatch_queue_create(DISPATCH_SNAPS, NULL);
        dispatch_async(snapsQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_SNAPSHOTS_SNAPS];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.schoolId];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:categoryId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                        if([(NSString*)result isEqualToString:@"true"]) {
                                if(self.snapshots == nil) {
                                    self.snapshots = [[NSMutableDictionary alloc] init];
                                } 
                                // build the snapshots
                                NSMutableArray *snaps = [[NSMutableArray alloc] init];
                                snaps = [USnapshotUtil hydrateSnaps:[json objectForKey:JSON_KEY_RESPONSE] snapCollection:snaps];
                                [self.snapshots setValue:snaps forKey:categoryId];
                            NSLog(@"hydrateSnapshots Category %@ Complete.", ((SnapshotCategory*)[UDataCache.snapshotCategories objectForKey:categoryId]).name);
                        } else {
                            // TODO: report error?
                        }
                    } else {// TODO: report error?
                    }
            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}
#pragma mark Cache Helpers
- (void) buildTweets:(id)tweetsRaw {
    // iterate over the tweets
    for(int idx=0;idx<[tweetsRaw count]; idx++) {
        // create the Tweet object
        Tweet *tweet = [[Tweet alloc] init];
        tweet.cacheAge = [NSDate date];
        tweet.created = [tweetDateFormatter dateFromString:[tweetsRaw[idx] objectForKey:@"created_at"]];
        tweet.tweetAge = [tweetsRaw[idx] objectForKey:@"age"];
        tweet.twitterUsername = [@"@" stringByAppendingString:[tweetsRaw[idx] objectForKey:@"from_user"]];
        tweet.twitterUserImage = [UDataCache.images objectForKey:KEY_DEFAULT_USER_IMAGE];
        tweet.twitterImageURL = [tweetsRaw[idx] objectForKey:@"profile_image_url"];
        tweet.tweetText = [tweetsRaw[idx] objectForKey:@"text"];
        NSDictionary *userRaw = [tweetsRaw[idx] objectForKey:@"ulinkuser"];
        if(userRaw != nil) {
            User *user = [[User alloc] init];
            [user hydrateUser:userRaw isSessionUser:NO];
            tweet.user = user;
        }
        [self.tweets insertObject:tweet atIndex:idx];
    }
}

#pragma mark

#pragma mark IMAGE CACHE
- (UIImage*)imageExists:(NSString*)cacheKey cacheModel:(NSString*)cacheModel {
    UIImage *retVal = nil;
    if ([cacheModel isEqualToString:IMAGE_CACHE_USER_THUMBS]) {
        for (NSString *key in [self.userImageThumbs allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.userImageThumbs objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_USER_MEDIUM]) {
        for (NSString *key in [self.userImageMedium allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.userImageMedium objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_EVENT_THUMBS]) {
        for (NSString *key in [self.eventImageThumbs allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.eventImageThumbs objectForKey:key];
                break;
            }
        }
    }  else if ([cacheModel isEqualToString:IMAGE_CACHE_EVENT_MEDIUM]) {
        for (NSString *key in [self.eventImageMedium allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.eventImageMedium objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_SNAP_THUMBS]) {
        for (NSString *key in [self.snapImageThumbs allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.snapImageThumbs objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_SNAP_MEDIUM]) {
        for (NSString *key in [self.snapImageMedium allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.snapImageMedium objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_TWEET_PROFILE]) {
        for (NSString *key in [self.tweetUserImages allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.tweetUserImages objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE]) {
        for (NSString *key in [self.images allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.images objectForKey:key];
                break;
            }
        }
    }
    return retVal;
}
- (void) removeImage:(NSString*)cacheKey cacheModel:(NSString*)cacheModel {
    if ([cacheModel isEqualToString:IMAGE_CACHE_USER_THUMBS]) {
        [self.userImageThumbs removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_USER_MEDIUM]) {
        [self.userImageMedium removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_EVENT_MEDIUM]) {
        [self.eventImageMedium removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_EVENT_THUMBS]) {
        [self.eventImageThumbs removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_SNAP_MEDIUM]) {
        [self.snapImageMedium removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_SNAP_THUMBS]) {
        [self.snapImageThumbs removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_TWEET_PROFILE]) {
        [self.tweetUserImages removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE]) {
        [self.images removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_LISTING_MEDIUM]) {
        [self.listingImageMedium removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_LISTING_THUMBS]) {
        [self.listingImageThumbs removeObjectForKey:cacheKey];
    }
}
- (void) removeListingImage:(NSString*)cacheKey schoolId:(NSInteger*)schoolId cacheModel:(NSString*)cacheModel {
    // first grab the listing images for the school
    NSString *schoolKey = [NSString stringWithFormat:@"%d", (int)schoolId];
    NSMutableDictionary *schoolListingImages;
    if ([cacheModel isEqualToString:IMAGE_CACHE_LISTING_MEDIUM]) {
        schoolListingImages = [self.listingImageMedium objectForKey:schoolKey];
        [schoolListingImages removeObjectForKey:cacheKey];
        // set the revised cache back on the main cache
        [self.listingImageMedium setValue:schoolListingImages forKey:schoolKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_LISTING_THUMBS]) {
        schoolListingImages = [self.listingImageThumbs objectForKey:schoolKey];
        [schoolListingImages removeObjectForKey:cacheKey];
        // set the revised cache back on the main cache
        [self.listingImageThumbs setValue:schoolListingImages forKey:schoolKey];
    }
}
#pragma mark -

- (BOOL) userIsLoggedIn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return ([defaults objectForKey:@"userIsLoggedIn"] != nil);
}

- (void) storeUserLoginInfo {
    // persist last successful login data on the device
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.sessionUser.username forKey:@"username"];
    [defaults setObject:self.sessionUser.password forKey:@"password"];
    [defaults setObject:@"YES" forKey:@"userIsLoggedIn"];
    [defaults synchronize];
}
- (void) removeLoginInfo {
    // remove last successful login data on the device
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"username"];
    [defaults removeObjectForKey:@"password"];
    [defaults removeObjectForKey:@"userIsLoggedIn"];
    [defaults synchronize];
}
@end
