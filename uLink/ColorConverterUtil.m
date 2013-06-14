//
//  ColorConverterUtil.m
//  ulink
//
//  Created by Christopher Cerwinski on 6/10/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "ColorConverterUtil.h"

@implementation UIColor(MBCategory)

// takes #0123456
+ (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [UIColor colorWithHex:x];
}

// takes 0x123456
+ (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}
@end
