//
//  SnapCell.m
//  uLink
//
//  Created by Bennie Kingwood on 11/15/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SnapCell.h"

@implementation SnapCell
@synthesize snap, snapImage;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSnapShot:(Snap *)newSnap {
    if(newSnap != nil) {
        self.snap = newSnap;
        self.snapImage.image = newSnap.snapImage;
    }
}
@end
