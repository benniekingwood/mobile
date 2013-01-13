//
//  UCampusViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/19/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCampusMenuViewController.h"
@interface UCampusViewController : UIViewController <UCampusMenuViewControllerDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)changePage:(UIPageControl *)sender;
@end
