//
//  UListMenuCell.h
//  ulink
//
//  Created by Christopher Cerwinski on 4/24/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppMacros.h"
#import "UlinkButton.h"

@interface UListMenuCell : UITableViewCell {
    UIImageView *glowView;
    UIImage *iconImage;
}

@property(nonatomic,strong) UIImageView *glowView;
@property(nonatomic,strong) UIImage *iconImage;
@property(nonatomic) BOOL enabled;
@property(nonatomic) NSString *schoolId;
@property(nonatomic) NSString *mainCat;
@property(nonatomic) NSString *subCat;
@property (nonatomic) ListingCategoryCellType type;

- (void) initialize;
- (void) initializeWithoutBG;
@end
