//
//  MapOverlayView.h
//  ulink
//
//  Created by Christopher Cerwinski on 6/21/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"

@interface MapOverlayView : UIView {
	UIColor					*backgroundColor;
    NSString                *title;
	NSString				*message;
    UIColor                 *titleColor;
    UIFont                  *titleFont;
	UIColor					*textColor;
	UIFont					*textFont;
    UIColor                 *borderColor;
    CGFloat                 borderWidth;

// accessible only by MapOverlayView class
@private
	CGSize					overlaySize;
	CGFloat					cornerRadius;
	BOOL					highlight;
	CGFloat					sidePadding;
	CGFloat					topMargin;
	CGFloat					pointerSize;
	CGPoint					targetPoint;
}

@property (nonatomic, retain)			UIColor					*backgroundColor;
@property (nonatomic, retain)			NSString				*title;
@property (nonatomic, retain)			NSString				*message;
@property (nonatomic, retain)           UIView	                *customView;
@property (nonatomic, retain)			UIColor					*titleColor;
@property (nonatomic, retain)			UIFont					*titleFont;
@property (nonatomic, retain)			UIColor					*textColor;
@property (nonatomic, retain)			UIFont					*textFont;
@property (nonatomic, assign)			UITextAlignment			titleAlignment;
@property (nonatomic, assign)			UITextAlignment			textAlignment;
@property (nonatomic, retain)			UIColor					*borderColor;
@property (nonatomic, assign)			CGFloat					borderWidth;
@property (nonatomic, assign)           CGFloat                 maxWidth;

/* initialize with a listing */
- (id)initWithListing:(Listing*)listing withFrame:(CGRect)frame;

@end
