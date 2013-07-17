//
//  PreviewPhotoView.h
//  uLink
//
//  Created by Bennie Kingwood on 12/31/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewPhotoView : UIView
@property (strong, nonatomic) UIImageView *previewImageView;
-(void) showPreviewPhoto:(UIView*)view;
-(void) hidePreviewPhoto;
- (id)initWithBackgroundColor:(UIColor*)backgroundColor frame:(CGRect)frame;
@end
