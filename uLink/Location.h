//
//  Location.h
//  ulink
//
//  Created by Christopher Cerwinski on 5/11/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject
@property (nonatomic) NSString* address1;
@property (nonatomic) NSString* address2;
@property (nonatomic) NSString* street;
@property (nonatomic) NSString* city;
@property (nonatomic) NSString* state;
@property (nonatomic) NSString* zip;
@property (nonatomic) NSString* latitude;
@property (nonatomic) NSString* longitude;
@end
