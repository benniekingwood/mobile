//
//  UListMapCell.m
//  ulink
//
//  Created by Christopher Cerwinski on 5/13/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListMapCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation UListMapCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        /*
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 119, 320, 2)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        bottomLine.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        bottomLine.layer.shadowColor = [[UIColor blackColor] CGColor];
        bottomLine.layer.shadowOpacity = 0.5;
        [super addSubview:bottomLine];
        */
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
