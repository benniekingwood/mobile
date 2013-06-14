//
//  ColorConverterUtil.h
//  ulink
//
//  Created by Christopher Cerwinski on 6/10/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

@interface UIColor(MBCategory)
+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHexString:(NSString *)str;
@end
