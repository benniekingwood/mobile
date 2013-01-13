//
//  TextUtil.m
//  uLink
//
//  Created by Bennie Kingwood on 12/6/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "TextUtil.h"
@interface TextUtil() {
    NSDateFormatter *eventDateFormatter;
}
@end
@implementation TextUtil
+ (TextUtil*) instance {
    static TextUtil* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) {
            _one = [[ TextUtil alloc ] init ];
        }
    }
    return _one;
}
-(id)init {
    if (self = [super init]) {
        eventDateFormatter = [[NSDateFormatter alloc] init];
        [eventDateFormatter setDateFormat:@"MM/d/yy"];
    }
    return self;
}
- (BOOL) validEmail:(NSString*)text {
    bool retVal = FALSE;
    NSString *expression = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if (match){
        retVal = TRUE;
    }
    return retVal;
}

- (BOOL) validEventDateFormat:(NSString*)text {
    BOOL retVal = FALSE;
    NSDate *eventDate = [eventDateFormatter dateFromString:text];
    NSDate *today = [NSDate date];
    if ([today compare:eventDate] == NSOrderedAscending) {
        retVal = TRUE;
    } else if (eventDate != NULL) {
        retVal = TRUE;
    }
    return retVal;
}

- (BOOL) isDigitsOnly:(NSString*)text {
    bool retVal = FALSE;
    NSString *expression = @"\\d+";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    if (match){
        retVal = TRUE;
    }
    return retVal;
}
/**
 * This function will take in a NSString and
 * capitalize the first letter of the NSString
 */
- (NSString *) capitalizeString:(NSString*)text {
    // get first char
    NSString *firstChar = [text substringToIndex:1];
    
    // remove any diacritic mark
    NSString *folded = [firstChar stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:LOCALE_EN_US];
    
    // create the new string
    NSString *retVal = [[folded uppercaseString] stringByAppendingString:[text substringFromIndex:1]];
    return retVal;
}

- (PasswordStrength) evaluatePasswordStrength:(NSString *)password {
    PasswordStrength retVal = kNoStrength;
    int strength = 0;
    NSString *regAlphaLower = @"[a-z]+";
    NSString *regAlphaUpper = @"[A-Z]+";
    NSString *regDigit = @"\\d+";
    NSString *regSpecial = @"[\\-_,;.:#+*?=!$%&/()@]+";
    NSError *error = NULL;
    NSRegularExpression *regexAlphaLower = [NSRegularExpression regularExpressionWithPattern:regAlphaLower options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *hasAlphaLower = [regexAlphaLower firstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
    
    NSError *error2 = NULL;
    NSRegularExpression *regexAlphaUpper = [NSRegularExpression regularExpressionWithPattern:regAlphaUpper options:NSRegularExpressionCaseInsensitive error:&error2];
    NSTextCheckingResult *hasAlphaUpper = [regexAlphaUpper firstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
    
    NSError *err = NULL;
    NSRegularExpression *regexDigit = [NSRegularExpression regularExpressionWithPattern:regDigit options:NSRegularExpressionCaseInsensitive error:&err];
    NSTextCheckingResult *hasDigit = [regexDigit firstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
    
    NSError *errr = NULL;
    NSRegularExpression *regexSpecial = [NSRegularExpression regularExpressionWithPattern:regSpecial options:NSRegularExpressionCaseInsensitive error:&errr];
    NSTextCheckingResult *hasSpecial = [regexSpecial firstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
    
    if(hasAlphaLower) {
        strength++;
    }
    if(hasAlphaUpper) {
        strength++;
    }
    if(hasDigit) {
        strength++;
    }
    if(hasSpecial) {
        strength+=2;
    }
    if(password.length<8) {
        strength--;
    } else {
        strength+=2;
    }
    if(strength > 0 && strength < 5) {
        retVal = kWeakStrength;
    } else if (strength==5) {
        retVal = kMediumStrength;
    } else if (strength > 5) {
        retVal = kStrongStrength;
    }
    return retVal;
}
@end
