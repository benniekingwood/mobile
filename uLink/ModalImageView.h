//
//  ModalImageView.h
//  uLink
//
//  Created by Bennie Kingwood on 2/3/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalImageView : UIView 
@property (nonatomic) BOOL imageVisible;
- (void) toggleImageView:(UIView*)parentView image:(UIImage*)image;
@end
