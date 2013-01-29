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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        spinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        spinnerView.layer.cornerRadius = 5;
        spinnerView.layer.masksToBounds = YES;
        backgroundOverlay = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 35, 35)];
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

- (void) showActivityIndicator:(UIView*)view {
    [view addSubview:spinnerView];
    spinnerView.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2);
    [spinner startAnimating];
}
- (void) hideActivityIndicator:(UIView*)view {
    [spinner stopAnimating];
    [spinnerView removeFromSuperview];
}

@end
