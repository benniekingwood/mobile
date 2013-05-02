//
//  SelectCategoryCell.m
//  ulink
//
//  Created by Christopher Cerwinski on 4/29/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "SelectCategoryCell.h"

@implementation SelectCategoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
