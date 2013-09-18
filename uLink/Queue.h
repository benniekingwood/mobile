//
//  Queue.h
//  ulink
//
//  Created by Christopher Cerwinski on 7/29/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray(Queue)
-(void) enqueue:(id)object;
-(id) dequeue;
-(BOOL) empty;
-(BOOL) full;

@end
