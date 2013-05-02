//
//  UListMenuCell.h
//  ulink
//
//  Created by Christopher Cerwinski on 4/24/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UListMenuCell : UITableViewCell {
    UIImageView *glowView;
    UIImage *iconImage;
}

@property(nonatomic,strong) UIImageView *glowView;
@property(nonatomic,strong) UIImage *iconImage;
@property(nonatomic) BOOL enabled;
@end
