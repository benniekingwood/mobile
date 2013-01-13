//
//  UCampusMenuCell.h
//  uLink
//
//  Created by Bennie Kingwood on 11/26/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCampusMenuCell : UITableViewCell {
    UIImageView *glowView;
    UIImage *iconImage;
}
@property(nonatomic,strong) UIImageView *glowView;
@property(nonatomic,strong) UIImage *iconImage;
@property(nonatomic) BOOL enabled;
@end
