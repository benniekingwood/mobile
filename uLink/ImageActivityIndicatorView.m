//
//  ImageActivityIndicatorView.m
//  uLink
//
//  Created by Bennie Kingwood on 1/19/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "ImageActivityIndicatorView.h"
#import "ActivityIndicatorView.h"

@interface ImageActivityIndicatorView() {
    UIView *spinnerView;
    UILabel *backgroundOverlay;
    UIActivityIndicatorView *spinner;
}
@end
@implementation ImageActivityIndicatorView
@synthesize centerOnScreen;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        spinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        backgroundOverlay = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 35, 35)];
        
        spinnerView.layer.cornerRadius = 5;
        spinnerView.layer.masksToBounds = YES;
        backgroundOverlay.backgroundColor = [UIColor blackColor];
        backgroundOverlay.alpha = 0.6;
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.center = spinnerView.center;
        spinner.hidesWhenStopped = YES;
        [spinnerView addSubview:backgroundOverlay];
        [spinnerView addSubview:spinner];
    }
    return self;
}
- (void) largeModeOn {
    // readjust the sizing for the 
    CGRect frame = spinnerView.frame;
    frame.size.width += 65;
    frame.size.height += 65;
    spinnerView.frame = frame;
    frame = backgroundOverlay.frame;
    frame.size.width += 65;
    frame.size.height += 65;
    backgroundOverlay.frame = frame;
    // readjust the center of the spinner
    spinner.center = spinnerView.center;
    // make the background dark
    backgroundOverlay.alpha = 0.8;
}
- (void) showActivityIndicator:(UIView*)view {
    [view addSubview:spinnerView];
    if(centerOnScreen) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        spinnerView.center = CGPointMake(screenRect.size.width / 2, screenRect.size.height / 2);
    } else {
        spinnerView.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2);
    }
    [spinner startAnimating];
}
- (void) hideActivityIndicator:(UIView*)view {
    [spinner stopAnimating];
    [spinnerView removeFromSuperview];
}

@end
