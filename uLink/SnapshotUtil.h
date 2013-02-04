//
//  SnapshotUtil.h
//  uLink
//
//  Created by Bennie Kingwood on 12/18/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Snap.h"
#import "SnapshotComment.h"
#import "AppMacros.h"
#define USnapshotUtil ((SnapshotUtil *)[SnapshotUtil instance])
@interface SnapshotUtil : NSObject
+ (SnapshotUtil*) instance;
- (NSMutableArray*) hydrateSnaps:(id)rawSnapData snapCollection:(NSMutableArray*)snapsList;
- (Snap*) hydrateSnapComments:(id)rawSnapComments snap:(Snap*)snap;
- (Snap*) hydrateSnapUser:(id)rawSnapUser snap:(Snap*)snap;
-(NSMutableDictionary*) buildSnapshotCategories:(id)categoriesRaw snapshotCategories:(NSMutableDictionary*)categories;
-(NSMutableArray*) getFeaturedSnaps:(NSMutableDictionary*)snapshotsCache snapshotCategories:(NSMutableDictionary*)categoriesCache;
- (void) removeSnap:(Snap*)snap;
- (void) removeSnapComment:(NSString*)snapId comment:(SnapshotComment*)comment;
@end
