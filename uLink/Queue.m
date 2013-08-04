//
//  Queue.m
//  ulink
//
//  Created by Christopher Cerwinski on 7/29/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "Queue.h"

@implementation Queue
@synthesize size, front, rear, queue;

-(id) initWithSize:(NSInteger)capacity {
    if (self = [super init]) {
        self.front = 0;
        self.rear = -1;
        self.size = capacity;
        
        queue = [[NSMutableArray alloc] initWithCapacity:capacity];
    }
    return self;
}

//
// Push object to the rear of the queue
// FIFO
//
-(void) enqueue:(id)object {
    if ([self full]) {
        // if full, then remove the front of queue,
        // readjust front
        // rear becomes old front
        
        NSInteger newFront = 0;
        NSInteger newRear = front;
        
        // if front is at the end of the queue, then reset
        if (front != (size-1)) {
            newFront = front++;
        }

        // insert object at 
        [queue insertObject:object atIndex:front];
        front = newFront;
        rear = newRear;

        return;
    }

    // set item to rear + 1
    [queue addObject:object];
    rear++;
}

//
// dequeue the oldest object in the queue
// front queue element
//
-(void) dequeue {
    // if queue is not empty, then delete
    if (![self empty]) {
        
        if (front != (size-1)) {
            front = 0;
        }
        else {
            front++;
        }
        
        // remove object at front
        [queue removeObjectAtIndex:front];
        
        // now if empty then reset rear
        if ([self empty]) {
            rear = -1;
        }
    }
}

//
// Determine if queue is empty, or not
//
-(BOOL) empty {
    return (queue.count == 0);
}

//
// 
//
-(BOOL) full {
    return (queue.count == size);
}

@end
