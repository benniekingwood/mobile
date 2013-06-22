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
    
    if(self.type == kListingCategoryTypeDark) {
        UIView* bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.25f];
        self.selectedBackgroundView = bgView;
        
        self.textLabel.font = [UIFont fontWithName:FONT_GLOBAL size:16.0f];
        self.textLabel.shadowOffset = CGSizeMake(0, 2);
        self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
        
        self.imageView.contentMode = UIViewContentModeCenter;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 260, 1)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        [self.textLabel.superview addSubview:bottomLine];
    } else if (self.type == kListingCategoryTypeLight) {
      //  UIView* bgView = [[UIView alloc] init];
      //  bgView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.25f];
       // self.selectedBackgroundView = bgView;
        
        self.textLabel.font = [UIFont fontWithName:FONT_GLOBAL size:16.0f];
        self.textLabel.textColor = [UIColor blackColor];
       // self.textLabel.shadowOffset = CGSizeMake(0, 2);
       // self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
        
        self.imageView.contentMode = UIViewContentModeCenter;
        
       /* UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 260, 1)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        [self.textLabel.superview addSubview:bottomLine]; */
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    /*
    self.textLabel.frame = CGRectZero;
    self.imageView.frame = CGRectZero;
     */
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(type == kListingCategoryTypeDark) {
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
    if (iconImage) {
        self.imageView.image = iconImage;
    }
    else {
        self.imageView.image = nil;
    }
    
    // Reenable user interaction and selection ability based on the cell type
    if(type == kListingCategoryTypeDark) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else if (type == kListingCategoryTypeLight) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    self.userInteractionEnabled = YES;
    [self setNeedsDisplay];
}

@end
