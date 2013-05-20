//
//  Listing.m
//  ulink
//
//  Created by Christopher Cerwinski on 5/10/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "Listing.h"

@implementation Listing
@synthesize _id, userId, schoolId, title, type, mainCategory, category, email, location, imageUrls, tags, meta, created, listDescription, shortDescription, replyTo, files, expires;
@synthesize cacheAge;

/* override description method to print out */
-(NSString*) description {
    [super description];

    // entire listing
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendFormat:@"\r--------------- Begin Listing Object ---------------\r"];
    [desc appendFormat:@"{\r"];
    [desc appendFormat:@"_id:%@\r",self._id];
    [desc appendFormat:@"user_id:%i\r",self.userId];
    [desc appendFormat:@"school_id:%i\r",self.schoolId];
    [desc appendFormat:@"title:%@\r",self.title];
    [desc appendFormat:@"description:%@\r",self.listDescription];
    [desc appendFormat:@"short_description:%@\r",self.shortDescription];
    [desc appendFormat:@"type:%@\r",self.type];
    [desc appendFormat:@"main_category:%@\r", self.mainCategory];
    [desc appendFormat:@"category:%@\r", self.category];
    [desc appendFormat:@"reply_to:%@\r", self.replyTo];
    
    [desc appendFormat:@"location: {\r"];
    [desc appendFormat:@"address1:%@\r", self.location.address1];
    [desc appendFormat:@"address2:%@\r", self.location.address2];
    [desc appendFormat:@"street:%@\r", self.location.street];
    [desc appendFormat:@"city:%@\r", self.location.city];
    [desc appendFormat:@"state:%@\r", self.location.state];
    [desc appendFormat:@"zip:%@\r", self.location.zip];
    [desc appendFormat:@"latitude:%@\r", self.location.latitude];
    [desc appendFormat:@"logitude:%@\r", self.location.longitude];
    [desc appendFormat:@"}\r"];
    
    [desc appendFormat:@"tags: {\r"];
    for (id object in self.tags) {
        [desc appendFormat:@"%@\r", (NSString*)object];
    }
    [desc appendFormat:@"}\r"];
    
    [desc appendFormat:@"files: {\r"];
    for (id object in self.files) {
        [desc appendFormat:@"%@\r", (NSString*)object];
    }
    [desc appendFormat:@"}\r"];
    
    [desc appendFormat:@"created:%@\r", self.created];
    [desc appendFormat:@"expires:%@\r", self.expires];
    [desc appendFormat:@"}\r"];
    [desc appendFormat:@"--------------- End Listing Object ---------------\r"];
    return desc;
}
@end
