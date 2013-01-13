//
//  AlertView.h
//  uLink
//
//  Created by Bennie Kingwood on 11/12/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AlertView : UIAlertView
- (void) resetAlert:(NSString*)msg;
- (void) resetAlert:(NSString*)msg waitTime:(float)duration;
@end
