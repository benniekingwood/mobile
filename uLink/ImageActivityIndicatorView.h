//
//  ImageActivityIndicatorView.h
//  uLink
//
//  Created by Bennie Kingwood on 1/19/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface ImageActivityIndicatorView : UIView
-(void) showActivityIndicator:(UIView*)view;
-(void) hideActivityIndicator:(UIView*)view;
- (void) largeModeOn;
@property (nonatomic) BOOL centerOnScreen;

@end
