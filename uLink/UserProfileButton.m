//
//  UserProfileButton.m
//  uLink
//
//  Created by Bennie Kingwood on 12/27/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UserProfileButton.h"
#import <QuartzCore/QuartzCore.h>
#import "UserProfileViewController.h"
#import "AppMacros.h"
@interface UserProfileButton ()
- (void) removeHighlight;
@end
@implementation UserProfileButton
@synthesize user;
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.highlighted == YES)
    {
        [self setAlpha:0.5];
    }
    else
    {
        // Do custom drawing for normal state
        [self setAlpha:1.0];
    }
}

+ (id)buttonWithType:(UIButtonType)buttonType {
    return [super buttonWithType:buttonType];
}

- (void) initialize {
    [self setBackgroundImage:self.user.profileImage forState:UIControlStateNormal];
    self.layer.cornerRadius = 5;
    self.userInteractionEnabled = YES;
    self.layer.masksToBounds = YES;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if(self.highlighted) {
        [self removeHighlight];
        // Draw a custom gradient
        CAGradientLayer *btnGradient = [CAGradientLayer layer];
        btnGradient.name = @"Highlight";
        btnGradient.frame = self.bounds;
        btnGradient.colors = [NSArray arrayWithObjects:
                              (id)[[UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.4f] CGColor],
                              (id)[[UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.4f] CGColor],
                              nil];
        //[self.layer insertSublayer:btnGradient atIndex:1];
        [self.layer addSublayer:btnGradient];
    }
    else {
        [self removeHighlight];
    }
}

-(void) removeHighlight {
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.name isEqualToString:@"Highlight"]) {
            [layer removeFromSuperlayer];
            break;
        }
    }
}
- (void)dealloc
{
    @try {
        [self removeObserver:self forKeyPath:@"highlighted"];
    }@catch(id anException){} // digest exception
}
@end
