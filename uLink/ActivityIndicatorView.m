//
//  ActivityIndicatorView.m
//  uLink
//
//  Created by Bennie Kingwood on 12/4/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "ActivityIndicatorView.h"

@implementation ActivityIndicatorView {
    UIView *spinnerView;
    UILabel *backgroundOverlay;
    UIActivityIndicatorView *spinner;
    UIView *modalOverlay;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        spinnerView = [[UIView alloc] initWithFrame:CGRectMake(-2, -100, 324, 50)];
        backgroundOverlay = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 324, 50)];
        backgroundOverlay.backgroundColor = [UIColor blackColor];
        backgroundOverlay.alpha = 0.6;
        [spinnerView.layer setBorderWidth:0.3f];
        [spinnerView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.center = CGPointMake(162, 34);
        spinner.hidesWhenStopped = YES;
        modalOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 1000)];
        modalOverlay.backgroundColor = [UIColor blackColor];
        modalOverlay.alpha = 0;
        [spinnerView addSubview:backgroundOverlay];
        [spinnerView addSubview:spinner];
    }
    return self;
}
- (void) showActivityIndicator:(UIView*)view {
    view.userInteractionEnabled = NO;
    [spinner startAnimating];
    [view addSubview:modalOverlay];
    [view addSubview:spinnerView];
    [UIView animateWithDuration:0.2
                          delay: 0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = spinnerView.frame;
                         frame.origin.y+=80;
                         spinnerView.frame = frame;
                         modalOverlay.alpha = 0.5;
                     }
                     completion:nil];
}
- (void) hideActivityIndicator:(UIView*)view {
    view.userInteractionEnabled = YES;
    [spinner stopAnimating];
    [spinnerView removeFromSuperview];
    CGRect frame = spinnerView.frame;
    frame.origin.y-=80;
    spinnerView.frame = frame;
    [modalOverlay removeFromSuperview];
}

-(void) initWhiteIndicator {
    backgroundOverlay.backgroundColor = [UIColor whiteColor];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [spinnerView.layer setBorderColor:[[UIColor blackColor] CGColor]];
}
@end
