//
//  EventUtil.h
//  uLink
//
//  Created by Bennie Kingwood on 12/22/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "AppMacros.h"
#define UEventUtil ((EventUtil *)[EventUtil instance])
@interface EventUtil : NSObject
+ (EventUtil*) instance;
- (NSMutableArray*) hydrateEvents:(id)rawEventData eventCollection:(NSMutableArray*)eventsList hydrationType:(EventHydrationType)hydrationType;
- (Event*) hydrateEventUser:(id)rawEventUser event:(Event*)event;
- (NSString*)getClearDate:(NSDate*)eventDate;
- (void) removeEvent:(Event*)event;
@end
