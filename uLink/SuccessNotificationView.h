//
//  SuccessNotificationView.h
//  uLink
//
//  Created by Bennie Kingwood on 12/11/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuccessNotificationView : UIView
-(void) showNotification:(UIView*)view;
-(void) setMessage:(NSString*)text;
@end
