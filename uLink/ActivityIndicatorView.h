//
//  ActivityIndicatorView.h
//  uLink
//
//  Created by Bennie Kingwood on 12/4/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface ActivityIndicatorView : UIView
-(void) showActivityIndicator:(UIView*)view;
-(void) hideActivityIndicator:(UIView*)view;
-(void) initWhiteIndicator;
@end
