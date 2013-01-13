//
//  SnapCategoryCell.m
//  uLink
//
//  Created by Bennie Kingwood on 12/18/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SnapCategoryCell.h"
#import "AppMacros.h"
@implementation SnapCategoryCell
@synthesize category, snapCategoryLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) initialize {
    //create the category buttons
    self.snapCategoryLabel.frame = CGRectMake(0,0,self.contentView.frame.size.width,self.contentView.frame.size.height);
    self.snapCategoryLabel.textColor = [UIColor whiteColor];
    self.snapCategoryLabel.backgroundColor = [UIColor clearColor];
    self.snapCategoryLabel.font = [UIFont fontWithName:FONT_GLOBAL size:13.0f];
    self.snapCategoryLabel.shadowColor = [UIColor blackColor];
    self.snapCategoryLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.snapCategoryLabel.text = self.category.name;
    self.snapCategoryLabel.textAlignment = NSTextAlignmentCenter;
}
@end
