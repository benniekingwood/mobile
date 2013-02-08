//
//  ImageUtil.m
//  uLink
//
//  Created by Bennie Kingwood on 1/20/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "ImageUtil.h"
#import "AppMacros.h"
@implementation ImageUtil
+ (ImageUtil*) instance {
    static ImageUtil* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) {
            _one = [[ ImageUtil alloc ] init ];
        }
    }
    return _one;
}
-(id)init {
    if (self = [super init]) {
    }
    return self;
}
- (NSData*) compressImageToData:(UIImage*)image {
    NSData *retVal = nil;
    if(image != nil) {
        CGFloat compression = 0.9f; // start the compression at 90% image quality
        CGFloat maxCompression = 0.1f; // go as low as 10% image quality
        int maxFileSize = IMAGE_MAX_FILE_SIZE*1024; // measured in bytes
        retVal = UIImageJPEGRepresentation(image, compression);
        while ([retVal length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            retVal = UIImageJPEGRepresentation(image, compression);
        }
    }
    return retVal;
}
- (UIImage*) compressImage:(UIImage*)image {
    return [UIImage imageWithData:[self compressImageToData:image]];
}
@end
