//
//  UListMapCell.m
//  ulink
//
//  Created by Christopher Cerwinski on 5/13/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListMapCell.h"

@implementation UListMapCell

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

@end
