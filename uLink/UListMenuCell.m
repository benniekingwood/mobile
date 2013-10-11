//
//  UListMenuCell.m
//  ulink
//
//  Created by Christopher Cerwinski on 4/24/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListMenuCell.h"
#import "AppMacros.h"
#import "ULinkColorPalette.h"
#import "ImageUtil.h"

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
    self.imageView.backgroundColor = [UIColor clearColor];
    self.enabled = YES;
    self.clipsToBounds = YES;
    //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"side-menu-bg.png"]];
    self.backgroundColor = [UIColor uLinkWhiteColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.textLabel.font = [UIFont fontWithName:FONT_GLOBAL size:16.0f];
    self.textLabel.textColor = [UIColor blackColor];
    
    if(self.type == kListingCategoryTypeDark  || self.type == kListingCategoryTypeAddListingButton) {
        //UIView* bgView = [[UIView alloc] init];
        //bgView.backgroundColor = [UIColor uLinkDarkGrayColor];
        //bgView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
        //self.selectedBackgroundView = bgView;
       // self.textLabel.shadowOffset = CGSizeMake(0, 2);
       // self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
        //UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 265, 1)];
        //bottomLine.backgroundColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
        //[self.textLabel.superview addSubview:bottomLine];
        
        self.textLabel.textColor = [UIColor blackColor];
    } else if (self.type == kListingCategoryTypeLight) {
        self.textLabel.textColor = [UIColor blackColor];
    }
    
    // set the icon image on the image view (if there is one)
    self.imageView.image = [UImageUtil makeThumbnailOfSizeWithImage:self.iconImage size:CGSizeMake(30, 30)];
}

- (void) initializeWithoutBG {
    self.imageView.backgroundColor = [UIColor clearColor];
    self.enabled = YES;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor uLinkWhiteColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.textLabel.font = [UIFont fontWithName:FONT_GLOBAL size:16.0f];
    self.textLabel.textColor = [UIColor blackColor];
    
    if(self.type == kListingCategoryTypeDark  || self.type == kListingCategoryTypeAddListingButton) {
        //UIView* bgView = [[UIView alloc] init];
        //bgView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
        //self.selectedBackgroundView = bgView;
        // self.textLabel.shadowOffset = CGSizeMake(0, 2);
        // self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
        //UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        //bottomLine.backgroundColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
        //[self.textLabel.superview addSubview:bottomLine];
        
        self.textLabel.textColor = [UIColor blackColor];
    } else if (self.type == kListingCategoryTypeLight) {
        self.textLabel.textColor = [UIColor blackColor];
    }
    
    // set the icon image on the image view (if there is one)
    self.imageView.image = [UImageUtil makeThumbnailOfSizeWithImage:self.iconImage size:CGSizeMake(30, 30)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(self.type == kListingCategoryTypeAddListingButton) {
        self.textLabel.frame = CGRectMake(60, 2, 125, 43);
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.autoresizingMask = UIViewAutoresizingNone;
        self.imageView.frame = CGRectMake(0, 0, 55, 45);
        self.imageView.backgroundColor = [UIColor uLinkGreenColor]; // randomize this...
    } 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(type == kListingCategoryTypeDark || self.type == kListingCategoryTypeAddListingButton) {
        if (selected) {
            self.glowView.hidden = NO;
            //self.textLabel.textColor = [UIColor blackColor];
            //[UIColor colorWithRed:250.0f / 255.0f green:172.0f / 255.0f blue:62.0f / 255.0f alpha:1.0f];
        } else {
            self.glowView.hidden = YES;
            //self.textLabel.textColor = [UIColor blackColor];
        }
    }
}

- (void)setEnabled:(BOOL)newValue {
    // Reenable user interaction and selection ability based on the cell type
    if(type == kListingCategoryTypeDark || self.type == kListingCategoryTypeAddListingButton) {
        //self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (type == kListingCategoryTypeLight) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    self.userInteractionEnabled = YES;
    [self setNeedsDisplay];
}

@end
