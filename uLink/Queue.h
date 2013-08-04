//
//  Queue.h
//  ulink
//
//  Created by Christopher Cerwinski on 7/29/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Queue : NSObject
@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger front;
@property (nonatomic) NSInteger rear;
@property (strong, nonatomic) NSMutableArray *queue;

-(id) initWithSize:(NSInteger)capacity;
-(void) enqueue:(id)object;
-(void) dequeue;
-(BOOL) empty;
-(BOOL) full;

@end
