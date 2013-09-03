//
//  UListMenuCell.m
//  ulink
//
//  Created by Christopher Cerwinski on 4/24/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListMenuCell.h"
#import "AppMacros.h"

@implementation UListMenuCell
@synthesize glowView, iconImage, enabled, mainCat, subCat, schoolId;
@synthesize type;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void) initialize {
    self.enabled = YES;
    self.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.textLabel.font = [UIFont fontWithName:FONT_GLOBAL size:16.0f];
    if(self.type == kListingCategoryTypeDark  || self.type == kListingCategoryTypeAddListingButton) {
        UIView* bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.25f];
        self.selectedBackgroundView = bgView;
       // self.textLabel.shadowOffset = CGSizeMake(0, 2);
       // self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 260, 1)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        [self.textLabel.superview addSubview:bottomLine];
    } else if (self.type == kListingCategoryTypeLight) {
        self.textLabel.textColor = [UIColor blackColor];
    }
    
    // set the icon image on the image view (if there is one)
    self.imageView.image = self.iconImage;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(self.type == kListingCategoryTypeAddListingButton) {
         self.textLabel.frame = CGRectMake(60, 2, 125, 43);
         self.imageView.frame = CGRectMake(10, 7, 30, 30);
    } 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(type == kListingCategoryTypeDark || self.type == kListingCategoryTypeAddListingButton) {
        if (selected) {
            self.glowView.hidden = NO;
            self.textLabel.textColor = [UIColor colorWithRed:250.0f / 255.0f green:172.0f / 255.0f blue:62.0f / 255.0f alpha:1.0f];
        } else {
            self.glowView.hidden = YES;
            self.textLabel.textColor = [UIColor whiteColor];
        }
    }
}

- (void)setEnabled:(BOOL)newValue {
    // Reenable user interaction and selection ability based on the cell type
    if(type == kListingCategoryTypeDark || self.type == kListingCategoryTypeAddListingButton) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else if (type == kListingCategoryTypeLight) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    self.userInteractionEnabled = YES;
    [self setNeedsDisplay];
}

@end
