//
//  Queue.m
//  ulink
//
//  Created by Christopher Cerwinski on 7/29/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "Queue.h"
#import "AppMacros.h"

@implementation NSMutableArray(Queue)

//
// Push object to the rear of the queue
// FIFO
//
-(void) enqueue:(id)object {
    [self addObject:object];
}

//
// dequeue the oldest object in the queue
// front queue element
//
-(id) dequeue {
    // if queue is not empty, then delete
    if (![self empty]) {
        // if ([self count] == 0) return nil; // to avoid raising exception (Quinn)
        id headObject = [self objectAtIndex:0];
        if (headObject != nil) {
            [self removeObjectAtIndex:0];
        }
        return headObject;
    }
    return nil;
}

//
// Determine if queue is empty, or not
//
-(BOOL) empty {
    return (self.count == 0);
}

//
// if queue has reached max allowance, we're full
//
-(BOOL) full {
    return (self.count == ULIST_CACHE_ALLOWANCE);
}

@end
