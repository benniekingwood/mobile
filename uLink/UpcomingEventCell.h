//
//  UpcomingEventCell.h
//  uLink
//
//  Created by Bennie Kingwood on 11/26/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
@interface UpcomingEventCell : UITableViewCell 
@property (nonatomic, strong) IBOutlet UIImageView *eventImageView;
@property (nonatomic, strong) Event *event;
-(void)initialize;
@end
