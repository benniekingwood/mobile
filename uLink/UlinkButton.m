//
//  UlinkButton.m
//  uLink
//
//  Created by Bennie Kingwood on 11/14/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UlinkButton.h"
#import "ULinkColorPalette.h"
#import <QuartzCore/QuartzCore.h>

@interface UlinkButton ()
-(void) removeHighlight;
-(void) applyDefaultWhiteFontAttrs:(UlinkButton*)btn;
-(void) applyDefaultWhiteSmallFontAttrs:(UlinkButton*)btn;
-(void) applyDefaultBlackSmallFontAttrs:(UlinkButton*)btn;
-(void) applyDefaultBlackFontAttrs:(UlinkButton*)btn;
-(void) buildOrangeButton:(UlinkButton*)btn;
-(void) buildDefaultButton:(UlinkButton*)btn type:(int)type;
@end
@implementation UlinkButton : UIButton
const int kDefaultButtonTypeRegular = 1;
const int kDefaultButtonTypeSmall = 2;
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
- (void) applyDefaultWhiteFontAttrs:(UlinkButton*)btn {
    // Set the button Text Color
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Set default background color
    [btn setBackgroundColor:[UIColor clearColor]];
    
    // Add Custom Font settings
    [[btn titleLabel] setFont:[UIFont fontWithName:FONT_GLOBAL_BOLD size:16.0f]];
}

- (void) applyDefaultWhiteSmallFontAttrs:(UlinkButton*)btn {
    // Set the button Text Color
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Set default background color
    [btn setBackgroundColor:[UIColor clearColor]];
    
    // Add Custom Font settings
    [[btn titleLabel] setFont:[UIFont fontWithName:FONT_GLOBAL_BOLD size:13.0f]];
}

- (void) applyDefaultBlackFontAttrs:(UlinkButton*)btn {
    // Set the button Text Color
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // Set default background color
    [btn setBackgroundColor:[UIColor clearColor]];
    
    // Add Custom Font settings
    [[btn titleLabel] setFont:[UIFont fontWithName:FONT_GLOBAL_BOLD size:16.0f]];
}

- (void) applyDefaultBlackSmallFontAttrs:(UlinkButton*)btn {
    // Set the button Text Color
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // Set default background color
    [btn setBackgroundColor:[UIColor clearColor]];
    
    // Add Custom Font settings
    [[btn titleLabel] setFont:[UIFont fontWithName:FONT_GLOBAL_BOLD size:13.0f]];
}

- (void) buildOrangeButton:(UlinkButton*)btn {
    btn.backgroundColor = [UIColor uLinkOrangeColor];
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
}

- (void) createOrangeButton:(UlinkButton*)btn {
    [self applyDefaultWhiteFontAttrs:btn];
    [self buildOrangeButton:btn];
}

-(void)createOrangeSmallButton:(UlinkButton *)btn {
    [self applyDefaultWhiteSmallFontAttrs:btn];
    [self buildOrangeButton:btn];
}

- (void) createBlueButton:(UlinkButton*)btn {
    [self applyDefaultWhiteFontAttrs:btn];
    
    // update the background color
    btn.backgroundColor = [UIColor uLinkBlueColor];
    
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
}

- (void) createRedButton:(UlinkButton*)btn {
    [self applyDefaultWhiteFontAttrs:btn];
    
    // set background color
    btn.backgroundColor = [UIColor colorWithRed:207.0f / 255.0f green:69.0f / 255.0f blue:63.0f / 255.0f alpha:1.0f];
    
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
}
- (void)buildDefaultButton:(UlinkButton*)btn type:(int)type {
    if(type == kDefaultButtonTypeRegular) {
        [self applyDefaultBlackFontAttrs:btn];
    } else if (type == kDefaultButtonTypeSmall) {
        [self applyDefaultBlackSmallFontAttrs:btn];
    }
    // set the background color
    btn.backgroundColor = [UIColor uLinkGrayColor];
    
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
}

- (void) createFlatBlackButton:(UlinkButton*)btn {
    btn.backgroundColor = [UIColor blackColor];
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    [btnLayer setShadowColor:[UIColor blackColor].CGColor];
    [btnLayer setShadowOpacity:0.8];
    [btnLayer setShadowRadius:3.0];
    [btnLayer setShadowOffset:CGSizeMake(2.0, 2.0)];
}
- (void) createDefaultButton:(UlinkButton*)btn {
    [self buildDefaultButton:btn type:kDefaultButtonTypeRegular];
}

- (void) createDefaultSmallButton:(UlinkButton*)btn {
    [self buildDefaultButton:btn type:kDefaultButtonTypeSmall];
}

- (void)dealloc
{
    @try {
    [self removeObserver:self forKeyPath:@"highlighted"];
    }@catch(id anException){} // digest exception
}

@end
