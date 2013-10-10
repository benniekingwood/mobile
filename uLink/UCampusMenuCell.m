//
//  UCampusMenuCell.m
//  uLink
//
//  Created by Bennie Kingwood on 11/26/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UCampusMenuCell.h"
#import "AppMacros.h"

@implementation UCampusMenuCell
@synthesize glowView;
@synthesize iconImage;
@synthesize enabled;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        enabled = YES;
        self.clipsToBounds = YES;
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"side-menu-bg.png"]];
        
        UIView* bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = bgView;
        
        self.textLabel.font = [UIFont fontWithName:FONT_GLOBAL size:16.0f];
        self.textLabel.shadowOffset = CGSizeMake(0, 2);
        self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
        
        self.imageView.contentMode = UIViewContentModeCenter;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 265, 1)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
        [self.textLabel.superview addSubview:bottomLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(60, 2, 125, 43);
    self.imageView.frame = CGRectMake(10, 5, 30, 30);
}

- (void)setSelected:(BOOL)sel animated:(BOOL)animated {
    [super setSelected:sel animated:animated];
    if (sel) {
        self.glowView.hidden = NO;
        self.textLabel.textColor = [UIColor colorWithRed:250.0f / 255.0f green:172.0f / 255.0f blue:62.0f / 255.0f alpha:1.0f];
    } else {
        self.glowView.hidden = YES;
        self.textLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setEnabled:(BOOL)newValue {
    if (iconImage) {
        self.imageView.image = iconImage;
        iconImage = nil;
    }
    
    // Reenable user interaction and selection ability
    //self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userInteractionEnabled = YES;
    [self setNeedsDisplay];
}

@end
