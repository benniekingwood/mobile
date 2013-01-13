//
//  DataCache.h
//  uLink
//
//  Created by Bennie Kingwood on 12/8/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#define UDataCache ((DataCache *)[DataCache instance])
@interface DataCache : NSObject {
    NSMutableDictionary *schools;
    NSMutableArray *schoolSections;
    User *sessionUser;
}
@property (strong, nonatomic) NSMutableDictionary *schools;
@property (strong, nonatomic) NSMutableArray *schoolSections;
@property (strong, nonatomic) NSMutableArray *featuredEvents;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableDictionary *snapshots;
@property (strong, nonatomic) NSMutableDictionary *snapshotCategories;
@property (strong, nonatomic) NSMutableArray *trends;
@property (strong, nonatomic) NSMutableArray *tweets;
@property (strong, nonatomic) User *sessionUser;
@property (strong, nonatomic) NSArray *times;
+ (DataCache*) instance;
- (void) clearCache;
- (void) rehydrateCaches:(BOOL)checkAge;
- (void) hydrateCaches;
- (void) hydrateSchoolCache;
- (void) hydrateEventsCache;
- (void) hydrateSnapshotsCache;
- (void) hydrateSnapshotCategoriesCache:(BOOL)implicitHydrateSnapshots;
- (void) hydrateTweetsCache;
- (void) hydrateTrendsCache;
- (void) rehydrateSessionUser;
- (void) rehydrateSchoolCache:(BOOL)checkAge;
- (void) rehydrateEventsCache:(BOOL)checkAge;
- (void) rehydrateSnapshotsCache:(BOOL)checkAge;
- (void) rehydrateSnapshotCategoriesCache:(BOOL)checkAge;
- (void) rehydrateTweetsCache:(BOOL)checkAge;
- (void) rehydrateTrendsCache:(BOOL)checkAge;
- (void) incrementActiveProcesses:(int)processCount;
- (void) decrementActiveProcesses;
@end
