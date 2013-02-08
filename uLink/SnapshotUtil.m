//
//  SnapshotUtil.m
//  uLink
//
//  Created by Bennie Kingwood on 12/18/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SnapshotUtil.h"
#import "SnapshotCategory.h"
#import "AppMacros.h"
#import "SnapshotComment.h"
#import "Snap.h"
#import "User.h"
#import "DataCache.h"
#import <SDWebImage/SDWebImageDownloader.h>
@interface SnapshotUtil() {
    NSDateFormatter *dateFormatter;
}
- (NSMutableArray*) addUniqueCategoryId:(NSMutableDictionary*)snapshots snapshotCategories:(NSMutableDictionary*)snapshotCategories featuredCategories:(NSMutableArray*)featuredCategories featuredSnaps:(NSMutableArray*)featuredSnaps;
@end
@implementation SnapshotUtil
+ (SnapshotUtil*) instance {
    static SnapshotUtil* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) {
            _one = [[ SnapshotUtil alloc ] init ];
        }
    }
    return _one;
}
-(id)init {
    if (self = [super init]) {
        // Initialization code here
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM d, yyyy, hh:m a"];
    }
    return self;
}
-(NSMutableDictionary*) buildSnapshotCategories:(id)categoriesRaw snapshotCategories:(NSMutableDictionary*)categories {
    // iterate over list of categories, creating and adding them to list
    for (NSDictionary *curCategory in categoriesRaw) {
        NSDictionary *cat = [curCategory objectForKey:@"SnapshotCategory"];
        SnapshotCategory *newCategory = [[SnapshotCategory alloc] init];
        newCategory.snapCategoryId = [cat objectForKey:@"_id"];
        newCategory.name = [cat objectForKey:@"name"];
        newCategory.cacheAge = [NSDate date];
        [categories setValue:newCategory forKey:newCategory.snapCategoryId];
    }
    return categories;
}
- (NSMutableArray*) hydrateSnaps:(id)rawSnapData snapCollection:(NSMutableArray*)snapsList {
    // iterate over the raw snap data, creating Snap objects
    for (int idx = 0; idx < [rawSnapData count]; idx++) {
        NSDictionary *currRawSnapshot = [(NSDictionary*)rawSnapData[idx] objectForKey:@"Snapshot"];
        Snap *snap = [[Snap alloc] init];
        snap.snapId = [currRawSnapshot objectForKey:@"_id"];
        snap.caption = [currRawSnapshot objectForKey:@"caption"];
        snap.categoryId = [currRawSnapshot objectForKey:@"category"];
        snap.cacheAge = [NSDate date];
        snap.created = [dateFormatter dateFromString: [currRawSnapshot objectForKey:@"created"]];
        // hydrate the snap user
        snap = [self hydrateSnapUser:[currRawSnapshot objectForKey:@"user"] snap:snap];
        // build the snap comments
        snap = [self hydrateSnapComments:[currRawSnapshot objectForKey:@"comments"] snap:snap];
        
        // default the snap image
        snap.snapImage = [UDataCache.images objectForKey:KEY_DEFAULT_SNAP_IMAGE];
        
        // set the snap image url
        snap.snapImageURL = [currRawSnapshot objectForKey:@"imageURL"];

        if(snapsList == nil) {
            snapsList = [[NSMutableArray alloc] init];
        }
        [snapsList addObject:snap];
    }
    return snapsList;
}
- (Snap*) hydrateSnapUser:(id)rawSnapUser snap:(Snap*)snap {
    User *user = [[User alloc] init];
    [user hydrateUser:[(NSDictionary*)rawSnapUser objectForKey:@"User"] isSessionUser:NO];
    snap.user = user;
    return snap;
}
- (Snap*) hydrateSnapComments:(id)rawSnapComments snap:(Snap*)snap {
    // iterate over the raw snap data, creating Snap objects
    for (int idx = 0; idx < [rawSnapComments count]; idx++) {
        NSDictionary *currRawSnapshotComment = [(NSDictionary*)rawSnapComments[idx] objectForKey:@"SnapshotComment"];
        SnapshotComment *snapComment = [[SnapshotComment alloc] init];
        snapComment.snapCommentId = [currRawSnapshotComment objectForKey:@"_id"];
        snapComment.comment = [currRawSnapshotComment objectForKey:@"comment"];
        snapComment.created = [dateFormatter dateFromString: [currRawSnapshotComment objectForKey:@"created"]];
        snapComment.createdShort = [currRawSnapshotComment objectForKey:@"created_short"];
        
        // build a user for the comment
        User *commentUser = [[User alloc] init];
        // userid
        commentUser.userId = [currRawSnapshotComment objectForKey:@"userId"];
        // username
        commentUser.username = [currRawSnapshotComment objectForKey:@"user_username"];
        // bio
        commentUser.bio = [currRawSnapshotComment objectForKey:@"user_bio"];
        // grad year
        commentUser.year = [currRawSnapshotComment objectForKey:@"user_year"];
        // firstname
        commentUser.firstname = [currRawSnapshotComment objectForKey:@"user_firstname"];
        // lastname
        commentUser.lastname = [currRawSnapshotComment objectForKey:@"user_lastname"];
        // school status
        commentUser.schoolStatus = [currRawSnapshotComment objectForKey:@"user_school_status"];
        
        // load the snap image from the image url
        commentUser.userImgURL = [currRawSnapshotComment objectForKey:@"user_image_url"];

        // assign the default user image 
        commentUser.profileImage = [UDataCache.images objectForKey:KEY_DEFAULT_USER_IMAGE];
        
        // assign the created user
        snapComment.user = commentUser;
        if(snap.snapComments == nil) {
            snap.snapComments = [[NSMutableArray alloc] init];
        }
        [snap.snapComments addObject:snapComment];
    }
    return snap;
}
-(NSMutableArray*) getFeaturedSnaps:(NSMutableDictionary*)snapshotsCache snapshotCategories:(NSMutableDictionary*)categoriesCache {
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    NSMutableArray *usedCategories = [[NSMutableArray alloc] init];
    // first grab four unique category ids
    for (int x = 0; x < 4; x++) {
        retVal = [self addUniqueCategoryId:snapshotsCache snapshotCategories:categoriesCache featuredCategories:usedCategories featuredSnaps:retVal];
    }
    return retVal;
}

- (NSMutableArray*) addUniqueCategoryId:(NSMutableDictionary*)snapshots  snapshotCategories:(NSMutableDictionary*)snapshotCategories featuredCategories:(NSMutableArray*)featuredCategories featuredSnaps:(NSMutableArray*)featuredSnaps{
    // get random int
    int randomKey = RANDOM_INT(0,4);
    // get random snapshot category
    id key = [[snapshotCategories allKeys] objectAtIndex:randomKey];
    BOOL foundMatch = FALSE;
    // iterate over the featured categories already being used
    for (NSString *categoryId in featuredCategories) {
        // if the category is in list of categories
        if ([categoryId isEqualToString:key]) {
            foundMatch = TRUE;
            break;
        }
    }
    if (foundMatch) {
        // recursively call method again
        return [self addUniqueCategoryId:snapshots snapshotCategories:snapshotCategories featuredCategories:featuredCategories featuredSnaps:featuredSnaps];
    } else {
        // add the key to the featured categories list
        [featuredCategories addObject:key];
        Snap *currSnap = nil;
        /*
         * if there are no snapshots for the category, 
         * create a dummy snapshot so that we can know
         * to not display it on the UI
         */
        if ([[snapshots objectForKey:key] count] == 0) {
            currSnap = [[Snap alloc] init];
        } else {
            // grab a random snapshot from the category
            randomKey = RANDOM_INT(0, [[snapshots objectForKey:key] count]-1);
            currSnap = [[snapshots objectForKey:key] objectAtIndex:randomKey];
            currSnap.categoryName = ((SnapshotCategory*)[snapshotCategories objectForKey:currSnap.categoryId]).name;
        }
       
        // add the snap to the featured snaps array
        [featuredSnaps addObject:currSnap];
    }
    return featuredSnaps;
}
- (void) removeSnap:(Snap*)snap {    
    // iterate over all of the snaps and when you find it add the image
    int matchIdx = -1;
    for (NSString* category in [UDataCache.snapshots allKeys]) {
        NSMutableArray *catSnaps = (NSMutableArray*)[UDataCache.snapshots objectForKey:category];
        for(int idx =0; idx < [catSnaps count]; idx++) {
            if ([((Snap*)catSnaps[idx]).snapId isEqualToString:snap.snapId]) {
                matchIdx = idx;
                break;
            }
        }
        if (matchIdx != -1) {
            [catSnaps removeObjectAtIndex:matchIdx];
            [UDataCache.snapshots setValue:catSnaps forKey:category];
            break;
        }
        
    }
}
- (void) removeSnapComment:(NSString*)snapId comment:(SnapshotComment*)comment {
    // iterate over all of the snaps and when you find it add the image
    for (NSString* category in [UDataCache.snapshots allKeys]) {
        NSMutableArray *catSnaps = (NSMutableArray*)[UDataCache.snapshots objectForKey:category];
        for(int idx =0; idx < [catSnaps count]; idx++) {
            if ([((Snap*)catSnaps[idx]).snapId isEqualToString:snapId]) {
                int matchSnapCommentIdx = -1;
                Snap *curSnap = ((Snap*)catSnaps[idx]);
                // iterate over the comments and find the matching comment
                for (int y=0;y<[curSnap.snapComments count]; y++) {
                  
                    if ([comment.snapCommentId isEqualToString:((SnapshotComment*)curSnap.snapComments[y]).snapCommentId]) {
                        matchSnapCommentIdx = y;
                        break;
                    }
                }
                if(matchSnapCommentIdx != -1) {
                    [curSnap.snapComments removeObjectAtIndex:matchSnapCommentIdx];
                }
                break;
            }
        }
    }
}
@end
