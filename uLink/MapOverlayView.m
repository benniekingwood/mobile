//
//  MapOverlayView.m
//  ulink
//
//  Created by Christopher Cerwinski on 6/21/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "MapOverlayView.h"
#import "AppMacros.h"
#import <QuartzCore/QuartzCore.h>

@implementation MapOverlayView {
    CGFloat spacer;
}

@synthesize backgroundColor;
@synthesize title;
@synthesize message;
@synthesize customView;
@synthesize titleColor;
@synthesize titleFont;
@synthesize textColor;
@synthesize textFont;
@synthesize titleAlignment;
@synthesize textAlignment;
@synthesize borderColor;
@synthesize borderWidth;
@synthesize maxWidth;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.opaque = NO;
        
		cornerRadius = 4.0;
		topMargin = 2.0;
		pointerSize = 12.0;
		sidePadding = 2.0;
        borderWidth = 2.0;
        spacer = 4.0;
        
		self.titleFont = [UIFont fontWithName:FONT_GLOBAL_BOLD size:14.0];
        self.titleColor = [UIColor blackColor];
        self.titleAlignment = NSTextAlignmentCenter;
		self.textFont = [UIFont fontWithName:FONT_GLOBAL size:12.0];
		self.textColor = [UIColor whiteColor];
		self.textAlignment = NSTextAlignmentCenter;
		self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        
        overlaySize = CGSizeMake(frame.size.width, frame.size.height-(pointerSize+topMargin+borderWidth));
        
        CGFloat fullHeight = overlaySize.height + pointerSize + 4.0;
        targetPoint = CGPointMake(overlaySize.width/2, fullHeight-2.0);
    }
    return self;
}

- (id)initWithListing:(Listing*)listing withFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.opaque = NO;
        
		cornerRadius = 4.0;
		topMargin = 2.0;
		pointerSize = 12.0;
		sidePadding = 2.0;
        borderWidth = 2.0;
        spacer = 4.0;
        
        self.titleFont = [UIFont fontWithName:FONT_GLOBAL_BOLD size:14.0];
        self.titleColor = [UIColor blackColor];
        self.titleAlignment = NSTextAlignmentCenter;
		self.textFont = [UIFont fontWithName:FONT_GLOBAL size:12.0];
		self.textColor = [UIColor blackColor];
		self.textAlignment = NSTextAlignmentCenter;
		self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        
        overlaySize = CGSizeMake(frame.size.width, frame.size.height-(pointerSize+topMargin+borderWidth));
        
        CGFloat fullHeight = overlaySize.height + pointerSize + 4.0;
        targetPoint = CGPointMake(overlaySize.width/2, fullHeight-2.0);
        
        // set up listing joints
        self.title = listing.title;
        self.message = listing.shortDescription;
    }
    return self;
}

- (CGRect)overlayFrame {
	CGRect overlayFrame;
    
    NSLog(@"overlayframe: CGRectMake(2.0, %f, %f, %f)", targetPoint.y-pointerSize-overlaySize.height, overlaySize.width, overlaySize.height);
    overlayFrame = CGRectMake(0, targetPoint.y-pointerSize-overlaySize.height, overlaySize.width, overlaySize.height);
	
    return overlayFrame;
}

- (CGRect)contentFrame {
	CGRect overlayFrame = [self overlayFrame];
	CGRect contentFrame = CGRectMake(overlayFrame.origin.x + cornerRadius,
									 overlayFrame.origin.y + cornerRadius,
									 overlayFrame.size.width - cornerRadius*2,
									 overlayFrame.size.height - cornerRadius*2);
	return contentFrame;
}

- (void)layoutSubviews {
	if (self.customView) {
		CGRect contentFrame = [self contentFrame];
        [self.customView setFrame:contentFrame];
    }
}

//draw overlay
- (void)drawRect:(CGRect)rect
{
    CGRect overlayRect = [self overlayFrame];
    
	CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(c, 0.0, 0.0, 0.0, 1.0);	// black
	CGContextSetLineWidth(c, borderWidth);
    
	CGMutablePathRef overlayPath = CGPathCreateMutable();
    
    /*NSLog(@"CGPathMoveToPoint(overlayPath, NULL, %f, %f)", targetPoint.x, targetPoint.y);*/
    CGPathMoveToPoint(overlayPath, NULL, targetPoint.x, targetPoint.y);
    
    /*NSLog(@"CGPathAddLineToPoint(overlayPath, NULL, %f, %f)", targetPoint.x-pointerSize, targetPoint.y-pointerSize);*/
    CGPathAddLineToPoint(overlayPath, NULL, targetPoint.x-pointerSize, targetPoint.y-pointerSize);
    
    /*NSLog(@"CGPathAddArcToPoint(overlayPath, NULL, %f, %f, %f, %f, %f)", overlayRect.origin.x, overlayRect.origin.y+overlayRect.size.height,
          overlayRect.origin.x, overlayRect.origin.y+overlayRect.size.height-cornerRadius,
          cornerRadius);*/
    CGPathAddArcToPoint(overlayPath, NULL,
                        overlayRect.origin.x, overlayRect.origin.y+overlayRect.size.height,
                        overlayRect.origin.x, overlayRect.origin.y+overlayRect.size.height-cornerRadius,
                        cornerRadius);
    
    /*NSLog(@"CGPathAddArcToPoint(overlayPath, NULL, %f, %f, %f, %f, %f)",
          overlayRect.origin.x, overlayRect.origin.y,
          overlayRect.origin.x+cornerRadius, overlayRect.origin.y,
          cornerRadius);*/
    CGPathAddArcToPoint(overlayPath, NULL,
                        overlayRect.origin.x, overlayRect.origin.y,
                        overlayRect.origin.x+cornerRadius, overlayRect.origin.y,
                        cornerRadius);
    
    /*NSLog(@"CGPathAddArcToPoint(overlayPath, NULL, %f, %f, %f, %f, %f)",
          overlayRect.origin.x+overlayRect.size.width, overlayRect.origin.y,
          overlayRect.origin.x+overlayRect.size.width, overlayRect.origin.y+cornerRadius,
          cornerRadius);*/
    CGPathAddArcToPoint(overlayPath, NULL,
                        overlayRect.origin.x+overlayRect.size.width, overlayRect.origin.y,
                        overlayRect.origin.x+overlayRect.size.width, overlayRect.origin.y+cornerRadius,
                        cornerRadius);
    
    /*NSLog(@"CGPathAddArcToPoint(overlayPath, NULL, %f, %f, %f, %f, %f)",
          overlayRect.origin.x+overlayRect.size.width, overlayRect.origin.y+overlayRect.size.height,
          overlayRect.origin.x+overlayRect.size.width-cornerRadius, overlayRect.origin.y+overlayRect.size.height,
          cornerRadius);*/
    CGPathAddArcToPoint(overlayPath, NULL,
                        overlayRect.origin.x+overlayRect.size.width, overlayRect.origin.y+overlayRect.size.height,
                        overlayRect.origin.x+overlayRect.size.width-cornerRadius, overlayRect.origin.y+overlayRect.size.height,
                        cornerRadius);
    
    /*NSLog(@"CGPathAddLineToPoint(overlayPath, NULL, %f, %f)", targetPoint.x+pointerSize, targetPoint.y-pointerSize);*/
    CGPathAddLineToPoint(overlayPath, NULL, targetPoint.x+pointerSize, targetPoint.y-pointerSize);
    
    CGPathCloseSubpath(overlayPath);
    
	// Draw shadow
	CGContextAddPath(c, overlayPath);
    CGContextSaveGState(c);
	CGContextSetShadow(c, CGSizeMake(0, 3), 5);
	CGContextSetRGBFillColor(c, 0.0, 0.0, 0.0, 0.9);
	CGContextFillPath(c);
    CGContextRestoreGState(c);
    
    
	// Draw clipped background gradient
	CGContextAddPath(c, overlayPath);
	CGContextClip(c);
    
	CGFloat overlayMiddle = (overlayRect.origin.y+(overlayRect.size.height/2)) / self.bounds.size.height;
    
	CGGradientRef myGradient;
	CGColorSpaceRef myColorSpace;
	size_t locationCount = 5;
	CGFloat locationList[] = {0.0, overlayMiddle-0.03, overlayMiddle, overlayMiddle+0.03, 1.0};
    
	CGFloat colourHL = 0.0;
	if (highlight) {
		colourHL = 0.25;
	}
    
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	CGFloat alpha;
	int numComponents = CGColorGetNumberOfComponents([backgroundColor CGColor]);
	const CGFloat *components = CGColorGetComponents([backgroundColor CGColor]);
	if (numComponents == 2) {
		red = components[0];
		green = components[0];
		blue = components[0];
		alpha = components[1];
	}
	else {
		red = components[0];
		green = components[1];
		blue = components[2];
		alpha = components[3];
	}
	CGFloat colorList[] = {
		//red, green, blue, alpha
		red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
		red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
		red*1.08+colourHL, green*1.08+colourHL, blue*1.08+colourHL, alpha,
		red     +colourHL, green     +colourHL, blue     +colourHL, alpha,
		red     +colourHL, green     +colourHL, blue     +colourHL, alpha
	};
	myColorSpace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents(myColorSpace, colorList, locationList, locationCount);
	CGPoint startPoint, endPoint;
	startPoint.x = 0;
	startPoint.y = 0;
	endPoint.x = 0;
	endPoint.y = CGRectGetMaxY(self.bounds);
    
	CGContextDrawLinearGradient(c, myGradient, startPoint, endPoint,0);
	CGGradientRelease(myGradient);
	CGColorSpaceRelease(myColorSpace);
    
    //Draw Border
    int numBorderComponents = CGColorGetNumberOfComponents([borderColor CGColor]);
    const CGFloat *borderComponents = CGColorGetComponents(borderColor.CGColor);
    CGFloat r, g, b, a;
	if (numBorderComponents == 2) {
		r = borderComponents[0];
		g = borderComponents[0];
		b = borderComponents[0];
		a = borderComponents[1];
	}
	else {
		r = borderComponents[0];
		g = borderComponents[1];
		b = borderComponents[2];
		a = borderComponents[3];
	}
     
	CGContextSetRGBStrokeColor(c, r, g, b, a);
	CGContextAddPath(c, overlayPath);
	CGContextDrawPath(c, kCGPathStroke);
    
	CGPathRelease(overlayPath);
    
	// Draw title and text
    if (self.title) {
        [self.titleColor set];
        CGRect titleFrame = [self contentFrame];
        [self.title drawInRect:titleFrame
                      withFont:self.titleFont
                 lineBreakMode:NSLineBreakByClipping
                     alignment:self.titleAlignment];
    }
    
	if (self.message) {
		[textColor set];
		CGRect textFrame = [self contentFrame];
        
        // Move down to make room for title
        if (self.title) {
            textFrame.origin.y += [self.title sizeWithFont:self.titleFont
                                         constrainedToSize:CGSizeMake(textFrame.size.width, 99999.0)
                                             lineBreakMode:NSLineBreakByClipping].height;
        }
        
        [self.message drawInRect:textFrame
                        withFont:textFont
                   lineBreakMode:NSLineBreakByWordWrapping
                       alignment:self.textAlignment];
    }
    
    // draw image indicating user can tap
    //UIImage *nextImg = [UIImage imageNamed:@"10-dark-back-button.png"];
    UIImage *nextImg = [UIImage imageNamed:@"AviarySDKResources.bundle/list_arrow.png"];

    CGPoint imagePoint = CGPointMake(overlayRect.origin.x+overlayRect.size.width-nextImg.size.width-spacer, overlayRect.origin.y+overlayRect.size.height-nextImg.size.height-spacer);
    [nextImg drawAtPoint:imagePoint];
    
}


@end
