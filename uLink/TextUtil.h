//
//  TextUtil.h
//  uLink
//
//  Created by Bennie Kingwood on 12/6/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppMacros.h"
#define UTextUtil ((TextUtil *)[TextUtil instance])
typedef enum  {
    kNoStrength = 0,
    kWeakStrength = 1,
    kMediumStrength = 2,
    kStrongStrength = 3
} PasswordStrength;

@interface TextUtil : NSObject
+ (TextUtil*) instance;
- (BOOL) validEmail:(NSString*)text;
- (BOOL) validEventDateFormat:(NSString*)text;
- (NSString *) capitalizeString:(NSString*)text;
- (PasswordStrength) evaluatePasswordStrength:(NSString*)password;
- (BOOL) isDigitsOnly:(NSString*)text;
- (NSString*) trimWhitespace:(NSString*)text;
@end
