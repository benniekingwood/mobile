//
//  ImageUtil.h
//  uLink
//
//  Created by Bennie Kingwood on 1/20/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#define UImageUtil ((ImageUtil *)[ImageUtil instance])
@interface ImageUtil : NSObject
+ (ImageUtil*) instance;
- (NSData*) compressImageToData:(UIImage*)image;
- (UIImage*) compressImage:(UIImage*)image;
-(NSString *) generateRandomString: (int) length;
@end
