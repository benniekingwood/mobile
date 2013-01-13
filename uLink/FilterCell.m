//
//  FilterCell.m
//  uLink
//
//  Created by Bennie Kingwood on 12/3/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "FilterCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FilterCell
@synthesize filterImage, filterName;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)initialize {
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}
@end
