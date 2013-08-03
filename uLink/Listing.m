//
//  Listing.m
//  ulink
//
//  Created by Christopher Cerwinski on 5/10/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "Listing.h"
#import "Base64.h"
#import "ImageUtil.h"

@implementation Listing
@synthesize _id, userId, schoolId, title, type, mainCategory, category, location, imageUrls, tags, meta, created, listDescription, shortDescription, replyTo, expires, price, username;
@synthesize images;
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
    [desc appendFormat:@"username:%@\r",self.username];
    [desc appendFormat:@"description:%@\r",self.listDescription];
    [desc appendFormat:@"short_description:%@\r",self.shortDescription];
    [desc appendFormat:@"type:%@\r",self.type];
    [desc appendFormat:@"main_category:%@\r", self.mainCategory];
    [desc appendFormat:@"category:%@\r", self.category];
    [desc appendFormat:@"reply_to:%@\r", self.replyTo];
    [desc appendFormat:@"price:%f\r", self.price];
    
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
    
    
    [desc appendFormat:@"created:%@\r", self.created];
    [desc appendFormat:@"expires:%@\r", self.expires];
    [desc appendFormat:@"}\r"];
    [desc appendFormat:@"--------------- End Listing Object ---------------\r"];
    return desc;
}

- (NSString*) getJSON {
    NSString *json = @"{ \"user_id\":";
    NSNumber *numObj = [NSNumber numberWithInteger:self.userId];
    json = [json stringByAppendingString:[numObj stringValue]];
    json = [json stringByAppendingString:@",\"school_id\":"];
    numObj = [NSNumber numberWithInteger:self.schoolId];
    json = [json stringByAppendingString:[numObj stringValue]];
    json = [json stringByAppendingString:@",\"username\":"];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:self.username];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:@",\"title\":"];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:self.title];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:@",\"description\":"];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:self.listDescription];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:@",\"type\":"];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:self.type];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:@",\"main_category\":"];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:self.mainCategory];
    json = [json stringByAppendingString:@"\""];
    // add the price of this listing is under the for sale category
    if([self.mainCategory isEqualToString:@"For Sale"]) {
        json = [json stringByAppendingString:@",\"price\":"];
        NSNumber *priceNum = [NSNumber numberWithDouble:self.price];
        json = [json stringByAppendingString:@"\""];
        json = [json stringByAppendingString:[priceNum stringValue]];
        json = [json stringByAppendingString:@"\""];
    }
    json = [json stringByAppendingString:@",\"category\":"];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:self.category];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:@",\"reply_to\":"];
    json = [json stringByAppendingString:@"\""];
    json = [json stringByAppendingString:self.replyTo];
    json = [json stringByAppendingString:@"\""];
    
    // add in the date related JSON
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    
    if(self.created != nil) {
        json = [json stringByAppendingString:@",\"created\":"];
        json = [json stringByAppendingString:@"\""];
        json = [json stringByAppendingString:[df stringFromDate:self.created]];
        json = [json stringByAppendingString:@"\""];
    }

    if(self.expires != nil) {
        json = [json stringByAppendingString:@",\"expires\":"];
        json = [json stringByAppendingString:@"\""];
        json = [json stringByAppendingString:[df stringFromDate:self.expires]];
        json = [json stringByAppendingString:@"\""];
    }
    
    // build the location for the JSON
    json = [self buildLocationJSON:json];
    // set the images on the JSON
    json = [self buildImageJSON:json];
    // set the tags on the JSON 
    json = [self buildTagsJSON:json];
    // set the meta data on the JSON
    json = [self buildMetaJSON:json];
    return json;
}

- (NSString*) buildLocationJSON:(NSString*)json {
    if(self.location != nil) {
        json = [json stringByAppendingString:@",\"location\": {"];
        
        json = [json stringByAppendingString:@"\"street\":"];
        if(self.location.address1 != nil) {
            json = [json stringByAppendingString:@"\""];
            json = [json stringByAppendingString:self.location.address1];
            json = [json stringByAppendingString:@"\""];
        } else {
            json = [json stringByAppendingString:@"\"\""];
        }
        
        json = [json stringByAppendingString:@",\"city\":"];
        if(self.location.city != nil) {
            json = [json stringByAppendingString:@"\""];
            json = [json stringByAppendingString:self.location.city];
            json = [json stringByAppendingString:@"\""];
        } else {
            json = [json stringByAppendingString:@"\"\""];
        }
        
        json = [json stringByAppendingString:@",\"state\":"];
        if(self.location.state != nil) {
            json = [json stringByAppendingString:@"\""];
            json = [json stringByAppendingString:self.location.state];
            json = [json stringByAppendingString:@"\""];
        } else {
            json = [json stringByAppendingString:@"\"\""];
        }
        
        json = [json stringByAppendingString:@",\"zip\":"];
        if(self.location.zip != nil) {
            json = [json stringByAppendingString:@"\""];
            json = [json stringByAppendingString:self.location.zip];
            json = [json stringByAppendingString:@"\""];
        } else {
            json = [json stringByAppendingString:@"\"\""];
        }
        
        json = [json stringByAppendingString:@",\"disclose\":"];
        json = [json stringByAppendingString:@"\""];
        json = [json stringByAppendingString:self.location.discloseLocation];
        json = [json stringByAppendingString:@"\""];
        json = [json stringByAppendingString:@"}"];
    }
    return json;
}
- (NSString*) buildMetaJSON:(NSString*)json {
    if(self.meta != nil) {
        json = [json stringByAppendingString:@",\"meta\": {"];
        BOOL firstItem = TRUE;
        for (NSString* key in self.meta) {
            NSString *value = (NSString*)[self.meta objectForKey:key];
            if(firstItem) {
                firstItem = FALSE;
            } else {
                json = [json stringByAppendingString:@","];
            }
            json = [json stringByAppendingString:@",\""];
            json = [json stringByAppendingString:key];
            json = [json stringByAppendingString:@"\":"];
            json = [json stringByAppendingString:@"\""];
            json = [json stringByAppendingString:value];
            json = [json stringByAppendingString:@"\""];
        }
        json = [json stringByAppendingString:@"}"];
    }
    
    json = [json stringByAppendingString:@"}"];
    return json;
}

- (NSString*) buildImageJSON:(NSString*)json {
    if(self.images != nil) {
        [Base64 initialize];
        json = [json stringByAppendingString:@",\"images\": ["];
        // iterate over the images creating base64 strings for each image
        for (int x=0; x < [self.images count]; x++) {
            NSData *imageData = [UImageUtil compressImageToData:[self.images objectAtIndex:x]];
            if(x > 0) {
                json = [json stringByAppendingString:@","];
            }
            json = [json stringByAppendingString:@"\""];
            json = [json stringByAppendingString:[Base64 encode:imageData]];
            json = [json stringByAppendingString:@"\""];
        }
        json = [json stringByAppendingString:@"]"];
    }
    return json;
}

- (NSString*) buildTagsJSON:(NSString*)json {
    if(self.tags != nil) {
        json = [json stringByAppendingString:@",\"tags\": ["];
        for (int y=0; y<[self.tags count]; y++) {
            if(y > 0) {
                json = [json stringByAppendingString:@","];
            }
            json = [json stringByAppendingString:@"\""];
            json = [json stringByAppendingString:[self.tags objectAtIndex:y]];
            json = [json stringByAppendingString:@"\""];
        }
        json = [json stringByAppendingString:@"]"];
    }
    return json;
}
@end
