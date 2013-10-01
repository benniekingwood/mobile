//
//  AlertView.m
//  uLink
//
//  Created by Bennie Kingwood on 11/12/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "AlertView.h"
#define kDefaultWaitTime 0.2f
@interface AlertView() {
    NSString *defaultMessage;
}
@end
@implementation AlertView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // build the initial alert window
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect activeBounds = self.bounds;
    CGFloat cornerRadius = 10.0f;
    CGFloat inset = 6.5f;
    CGFloat originX = activeBounds.origin.x + inset;
    CGFloat originY = activeBounds.origin.y + inset;
    CGFloat width = activeBounds.size.width - (inset*2.0f);
    CGFloat height = activeBounds.size.height - (inset*2.0f);
    CGRect bPathFrame = CGRectMake(originX, originY, width, height);
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:bPathFrame cornerRadius:cornerRadius].CGPath;
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:0.0f].CGColor);
    //CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 6.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor);
    CGContextDrawPath(context, kCGPathFill);
    CGContextSaveGState(context); //Save Context State Before Clipping To "path"
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    // now draw the background gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t count = 3;
    CGFloat locations[3] = {0.0f, 0.57f, 1.0f};
    CGFloat components[12] =
    {
        0.0f/255.0f, 0.0f/255.0f, 0.0f/255.0f, 0.6f,     
        0.0f/255.0f, 0.0f/255.0f, 0.0f/255.0f, 0.6f,     
        0.0f/255.0f, 0.0f/255.0f, 0.0f/255.0f, 0.6f      
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, count);
    CGPoint startPoint = CGPointMake(activeBounds.size.width * 0.5f, 0.0f);
    CGPoint endPoint = CGPointMake(activeBounds.size.width * 0.5f, activeBounds.size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);

    // redraw path to avoid pixelation
    CGContextRestoreGState(context); 
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 0.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.1f].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
}


- (void)layoutSubviews {
    for (UIView *subview in self.subviews){ //Fast Enumeration
        if ([subview isMemberOfClass:[UIImageView class]]) {
            subview.hidden = YES; 
        }
        if ([subview isMemberOfClass:[UILabel class]]) { 
            UILabel *label = (UILabel*)subview; 
            label.textColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f];
            label.shadowColor = [UIColor blackColor];
            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        }
    }
}

- (void) resetAlert:(NSString*)msg waitTime:(float)duration {
    [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(setDefaultMessage:) userInfo:msg repeats:NO];
}
- (void) resetAlert:(NSString*)msg {
    [NSTimer scheduledTimerWithTimeInterval:kDefaultWaitTime target:self selector:@selector(setDefaultMessage:) userInfo:msg repeats:NO];
}
-(void)setDefaultMessage:(NSTimer*)timer {
    defaultMessage = timer.userInfo;
    [self setMessage:defaultMessage];
}
@end