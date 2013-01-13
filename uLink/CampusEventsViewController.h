//
//  CampusEventsViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/26/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CampusEventsViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
- (IBAction)changePage:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *featuredEventsHeader;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *upcomingHeader;
@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;
@end
