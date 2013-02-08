//
//  User.m
//  uLink
//
//  Created by Bennie Kingwood on 11/16/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "User.h"
#import "AppMacros.h"
#import "Snap.h"
#import "SnapshotComment.h"
#import "SnapshotUtil.h"
#import "EventUtil.h"
#import "DataCache.h"

@implementation User
@synthesize cacheAge,
userId,username,firstname,lastname,password,email,schoolId,major,year,schoolStatus, schoolName;
@synthesize bio,twitterEnabled,twitterUsername, profileImage, userImgURL;
@synthesize events;
@synthesize snaps;

-(id)init {
    if (self = [super init]) {
        // Initialization code here
    }
    return self;
}

- (void) hydrateUser:(NSDictionary *)rawData isSessionUser:(BOOL)isSessionUser {
    // password is already set in the caller
    self.userId = [rawData objectForKey:@"id"];
    self.username = [rawData objectForKey:@"username"];
    self.bio = (![[rawData objectForKey:@"bio"] isKindOfClass:[NSNull class]])  ? [rawData objectForKey:@"bio"] : @"";
    self.email = (![[rawData objectForKey:@"email"] isKindOfClass:[NSNull class]])  ? [rawData objectForKey:@"email"] : @"";
    self.major = (![[rawData objectForKey:@"major"] isKindOfClass:[NSNull class]])  ? [rawData objectForKey:@"major"] : @"";
    self.year = (![[rawData objectForKey:@"year"] isKindOfClass:[NSNull class]])  ? [rawData objectForKey:@"year"] : @"";
    self.firstname = (![[rawData objectForKey:@"firstname"] isKindOfClass:[NSNull class]])  ? [rawData objectForKey:@"firstname"] : @"";
    self.lastname  = (![[rawData objectForKey:@"lastname"] isKindOfClass:[NSNull class]])  ? [rawData objectForKey:@"lastname"] : @"";
    self.schoolId = [rawData objectForKey:@"school_id"];
    self.schoolStatus = (![[rawData objectForKey:@"school_status"] isKindOfClass:[NSNull class]])  ? [rawData objectForKey:@"school_status"] : @"";
    self.twitterEnabled = (BOOL)[rawData objectForKey:@"twitter_enabled"];
    self.twitterUsername = (![[rawData objectForKey:@"twitter_username"] isKindOfClass:[NSNull class]])  ? [rawData objectForKey:@"twitter_username"] : @"";
    self.schoolName = (![[rawData objectForKey:@"school_name"] isKindOfClass:[NSNull class]])  ? [rawData objectForKey:@"school_name"] : @"";
    self.userImgURL = ([[rawData objectForKey:@"image_url"] isKindOfClass:[NSNull class]] || [[rawData objectForKey:@"image_url"] isEqualToString:@"<null>"]) ? nil : [rawData objectForKey:@"image_url"];
    self.profileImage = [UDataCache.images objectForKey:KEY_DEFAULT_USER_IMAGE];
    self.cacheAge = [NSDate date];
    self.events = [UEventUtil hydrateEvents:[rawData objectForKey:@"Events"] eventCollection:self.events hydrationType:kEventHydrationAll];
    self.snaps = [USnapshotUtil hydrateSnaps:[rawData objectForKey:@"Snaps"] snapCollection:self.snaps];
    NSDictionary *schoolRawData = [rawData objectForKey:@"School"];
    if(![schoolRawData isKindOfClass:[NSNull class]] && schoolRawData != nil) {
        if (self.school == nil) {
            self.school = [[School alloc] init];
        }
        // hydrate any school data
        self.school.attendance = (![[schoolRawData objectForKey:@"attendence"] isKindOfClass:[NSNull class]])  ? [schoolRawData objectForKey:@"attendence"] : @"";
        self.school.year = (![[schoolRawData objectForKey:@"year"] isKindOfClass:[NSNull class]])  ? [schoolRawData objectForKey:@"year"] : @"";
        self.school.imageURL = ([[schoolRawData objectForKey:@"image_url"] isKindOfClass:[NSNull class]] || [[schoolRawData objectForKey:@"image_url"] isEqualToString:@"<null>"]) ? nil : [schoolRawData objectForKey:@"image_url"];
    }
    // Hydrate extra data for the session user if necessary
    if(isSessionUser) {
        // Hydrate the top snapper if the data is present
        if (![[rawData objectForKey:@"TopSnapper"] isKindOfClass:[NSNull class]] &&
            [rawData objectForKey:@"TopSnapper"] != nil) {
            UDataCache.topSnapper = [[User alloc] init];
            [UDataCache.topSnapper hydrateUser:[rawData objectForKey:@"TopSnapper"] isSessionUser:NO];
        }
    }
}
@end
