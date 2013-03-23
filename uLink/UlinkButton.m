//
//  UlinkButton.m
//  uLink
//
//  Created by Bennie Kingwood on 11/14/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UlinkButton.h"
#import <QuartzCore/QuartzCore.h>
@interface UlinkButton ()
-(void) removeHighlight;
-(void) applyDefaultWhiteFontAttrs:(UlinkButton*)btn;
-(void) applyDefaultWhiteSmallFontAttrs:(UlinkButton*)btn;
-(void) applyDefaultBlackSmallFontAttrs:(UlinkButton*)btn;
-(void) applyDefaultBlackFontAttrs:(UlinkButton*)btn;
-(void) buildOrangeButton:(UlinkButton*)btn;
-(void) buildDefaultButton:(UlinkButton*)btn;
@end
@implementation UlinkButton : UIButton
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
    [[btn titleLabel] setFont:[UIFont fontWithName:FONT_GLOBAL size:16.0f]];
    [[btn titleLabel] setShadowColor:[UIColor blackColor]];
    [[btn titleLabel] setShadowOffset:CGSizeMake(0.0f, -0.5f)];
}

- (void) applyDefaultWhiteSmallFontAttrs:(UlinkButton*)btn {
    // Set the button Text Color
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Set default background color
    [btn setBackgroundColor:[UIColor clearColor]];
    
    // Add Custom Font settings
    [[btn titleLabel] setFont:[UIFont fontWithName:FONT_GLOBAL size:13.0f]];
    [[btn titleLabel] setShadowColor:[UIColor blackColor]];
    [[btn titleLabel] setShadowOffset:CGSizeMake(0.0f, -0.5f)];
}

- (void) applyDefaultBlackFontAttrs:(UlinkButton*)btn {
    // Set the button Text Color
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // Set default background color
    [btn setBackgroundColor:[UIColor clearColor]];
    
    // Add Custom Font settings
    [[btn titleLabel] setFont:[UIFont fontWithName:FONT_GLOBAL size:16.0f]];
    [[btn titleLabel] setShadowColor:[UIColor yellowColor]];
    [[btn titleLabel] setShadowOffset:CGSizeMake(0.0f, -0.5f)];
}

- (void) applyDefaultBlackSmallFontAttrs:(UlinkButton*)btn {
    // Set the button Text Color
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // Set default background color
    [btn setBackgroundColor:[UIColor clearColor]];
    
    // Add Custom Font settings
    [[btn titleLabel] setFont:[UIFont fontWithName:FONT_GLOBAL size:13.0f]];
    [[btn titleLabel] setShadowColor:[UIColor yellowColor]];
    [[btn titleLabel] setShadowOffset:CGSizeMake(0.0f, -0.5f)];
}
- (void) buildOrangeButton:(UlinkButton*)btn {
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = btn.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:250.0f / 255.0f green:172.0f / 255.0f blue:62.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:248.0f / 255.0f green:150.0f / 255.0f blue:11.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [btn.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border around Buy Button
    [btnLayer setBorderWidth:0.2f];
    [btnLayer setBorderColor:[[UIColor orangeColor] CGColor]];
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
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = btn.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:0.0f / 255.0f green:130.0f / 255.0f blue:204.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:0.0f / 255.0f green:87.0f / 255.0f blue:204.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [btn.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border around Buy Button
    [btnLayer setBorderWidth:0.2f];
    [btnLayer setBorderColor:[[UIColor blueColor] CGColor]];
}

- (void) createRedButton:(UlinkButton*)btn {
    [self applyDefaultWhiteFontAttrs:btn];
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = btn.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:207.0f / 255.0f green:69.0f / 255.0f blue:63.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:189.0f / 255.0f green:54.0f / 255.0f blue:47.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [btn.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border around Buy Button
    [btnLayer setBorderWidth:0.2f];
    [btnLayer setBorderColor:[[UIColor redColor] CGColor]];
}
- (void)buildDefaultButton:(UlinkButton*)btn {
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = btn.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:230.0f / 255.0f green:230.0f / 255.0f blue:230.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [btn.layer addSublayer:btnGradient];
    //[btn.layer insertSublayer:btnGradient atIndex:btn.layer.sublayers.count];
    
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border around Buy Button
    [btnLayer setBorderWidth:0.2f];
    [btnLayer setBorderColor:[[UIColor darkGrayColor] CGColor]];
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
    
    // Apply a 1 pixel, black border around Buy Button
   // [btnLayer setBorderWidth:0.2f];
   // [btnLayer setBorderColor:[[UIColor darkGrayColor] CGColor]];
}
- (void) createDefaultButton:(UlinkButton*)btn {
    [self applyDefaultBlackFontAttrs:btn];
    [self buildDefaultButton:btn];
}

- (void) createDefaultSmallButton:(UlinkButton*)btn {
    [self applyDefaultBlackSmallFontAttrs:btn];
    [self buildDefaultButton:btn];
}

- (void)dealloc
{
    @try {
    [self removeObserver:self forKeyPath:@"highlighted"];
    }@catch(id anException){} // digest exception
}

@end
