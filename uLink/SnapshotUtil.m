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
#import "user.h"
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
        // load the snap image from the image url
        NSString *snapImgURL =[currRawSnapshot objectForKey:@"imageURL"];
        if(snapImgURL != nil) {
            NSURL *url = [NSURL URLWithString:[URL_SNAP_IMAGE stringByAppendingString:snapImgURL]];
            snap.snapImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            if (snap.snapImage == nil) {
                snap.snapImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URL_DEFAULT_SNAP_IMAGE]]];
            }
        } else {
             snap.snapImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URL_DEFAULT_SNAP_IMAGE]]];
        }
        if(snapsList == nil) {
            snapsList = [[NSMutableArray alloc] init];
        }
        [snapsList addObject:snap];
    }
    return snapsList;
}
- (Snap*) hydrateSnapUser:(id)rawSnapUser snap:(Snap*)snap {
    User *user = [[User alloc] init];
    [user hydrateUser:[(NSDictionary*)rawSnapUser objectForKey:@"User"]];
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
        NSString *userImageURL = [currRawSnapshotComment objectForKey:@"user_image_url"];
        if(userImageURL != nil) {
            NSURL *url = [NSURL URLWithString:[URL_USER_IMAGE stringByAppendingString:userImageURL]];
            commentUser.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        } else {
            commentUser.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URL_DEFAULT_USER_IMAGE]]];
        }
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
@end
