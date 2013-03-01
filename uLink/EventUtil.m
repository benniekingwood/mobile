//
//  EventUtil.m
//  uLink
//
//  Created by Bennie Kingwood on 12/22/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "EventUtil.h"
#import "Event.h"
#import "DataCache.h"
@interface EventUtil() {
    NSDateFormatter *dateFormatter;
    NSDateFormatter *clearDateFormatter;
}
- (Event*) buildEvent:(NSDictionary*)eventRawData event:(Event*)event;
@end
@implementation EventUtil
+ (EventUtil*) instance {
    static EventUtil* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) {
            _one = [[ EventUtil alloc ] init ];
        }
    }
    return _one;
}
-(id)init {
    if (self = [super init]) {
        // Initialization code here
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-d HH:m:s"];
        clearDateFormatter = [[NSDateFormatter alloc] init];
        [clearDateFormatter setDateFormat:@"MMMM d yyyy"];
    }
    return self;
}
- (void) removeEvent:(Event*)event {
    int matchedIdx = -1;
    for (int x=0; x < [UDataCache.events count]; x++) {
        if([((Event*)UDataCache.events[x]).eventId isEqualToString:event.eventId]) {
            matchedIdx = x;
            break;
        }
    }
     if(matchedIdx != -1) {
         [UDataCache.events removeObjectAtIndex:matchedIdx];
     }
}
- (Event*) buildEvent:(NSDictionary*)eventRawData event:(Event*)event {
    if(event == nil) {
        event = [[Event alloc] init];
    }
    event.eventId = [eventRawData objectForKey:@"_id"];
    event.title = [eventRawData objectForKey:@"eventTitle"];
    event.information = [eventRawData objectForKey:@"eventInfo"];
    event.location = [eventRawData objectForKey:@"eventLocation"];
    event.time = [eventRawData objectForKey:@"eventTime"];
    event.date = [dateFormatter dateFromString:[eventRawData objectForKey:@"eventDate"]];
    event.featured = [[eventRawData objectForKey:@"featured"] stringValue];
    event.clearDate = [clearDateFormatter stringFromDate:event.date];
    event.cacheAge = [NSDate date];
    // set the image url for the event
    event.imageURL =[eventRawData objectForKey:@"imageURL"];
    
    if([@"1" isEqualToString:event.featured]) {
        event.image = [UDataCache.images objectForKey:KEY_DEFAULT_FEATURED_EVENT_IMAGE];
    } else {
        event.image = [UDataCache.images objectForKey:KEY_DEFAULT_EVENT_IMAGE];
    }
    // hydrate the event user
    event = [self hydrateEventUser:[eventRawData objectForKey:@"user"] event:event];
    return event;
}
- (NSMutableArray*) hydrateEvents:(id)rawEventData eventCollection:(NSMutableArray*)eventsList hydrationType:(EventHydrationType)hydrationType {
  
    if(eventsList == nil) {
        eventsList = [[NSMutableArray alloc] init];
    }
    // iterate over the raw event data, creating Event objects
    for (int idx = 0; idx < [rawEventData count]; idx++) {
        NSDictionary *currRawEvent = [(NSDictionary*)rawEventData[idx] objectForKey:@"Event"];
        Event *event = [[Event alloc] init];
        event = [self buildEvent:currRawEvent event:event];
        switch (hydrationType) {
            case kEventHydrationFeatured:
                if([@"1" isEqualToString:event.featured]) {
                    [eventsList addObject:event];
                }
                break;
            case kEventHydrationRegular:
                if(![@"1" isEqualToString:event.featured]) {
                    [eventsList addObject:event];
                }
                break;
            case kEventHydrationAll: [eventsList addObject:event];
                break;
        }
    }
    return eventsList;
}

- (Event*) hydrateEventUser:(id)rawEventUser event:(Event*)event {
    User *user = [[User alloc] init];
    [user hydrateUser:[(NSDictionary*)rawEventUser objectForKey:@"User"] isSessionUser:NO];
    event.user = user;
    return event;
}
- (NSString*)getClearDate:(NSDate*)eventDate {
    return [clearDateFormatter stringFromDate:eventDate];
}
@end
