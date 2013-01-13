//
//  UpcomingEventCell.m
//  uLink
//
//  Created by Bennie Kingwood on 11/26/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UpcomingEventCell.h"
#import "AppMacros.h"
#import <QuartzCore/QuartzCore.h>
@implementation UpcomingEventCell 
@synthesize eventImageView;
@synthesize event;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initialize {
    self.clipsToBounds = YES;
  
}
- (void)layoutSubviews {
    [super layoutSubviews];
    //self.textLabel.frame = CGRectMake(80, 0, 250, 70);
    self.imageView.frame = CGRectMake(24, 16, 40, 40);
}
- (void)setEnabled:(BOOL)newValue {
    if(eventImageView.image) {
        self.imageView.image = eventImageView.image;
        eventImageView.image = nil;
    }

    // Reenable user interaction and selection ability
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.userInteractionEnabled = YES;
    [self setNeedsDisplay];
}
@end
