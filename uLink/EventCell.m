//
//  EventCell.m
//  uLink
//
//  Created by Bennie Kingwood on 12/22/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "EventCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMacros.h"
@interface EventCell() {
    UILabel *eventTitle;
    UILabel *eventDate;
}
@end
@implementation EventCell
@synthesize event;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}
- (void)initialize {
    self.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.masksToBounds = YES;
    [eventTitle removeFromSuperview];
    eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, -5, 200, 50)];
    eventTitle.numberOfLines = 2;
    eventTitle.font = [UIFont fontWithName:FONT_GLOBAL size:15.0f];
    eventTitle.textColor = [UIColor blackColor];
    eventTitle.backgroundColor = [UIColor clearColor];
    eventTitle.text = self.event.title;
    
    [eventDate removeFromSuperview];
    eventDate = [[UILabel alloc] initWithFrame:CGRectMake(80, 40, 100, 20)];
    eventDate.font = [UIFont fontWithName:FONT_GLOBAL size:10.0f];
    eventDate.textColor = [UIColor grayColor];
    eventDate.backgroundColor = [UIColor clearColor];
    eventDate.text = self.event.clearDate;
    self.imageView.image  = self.event.image;
    [self.contentView addSubview:eventDate];
    [self.contentView addSubview:eventTitle];
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(20, 4, 50, 50);
}
@end
