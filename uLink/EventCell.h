//
//  EventCell.h
//  uLink
//
//  Created by Bennie Kingwood on 12/22/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
@interface EventCell : UITableViewCell
@property (nonatomic) Event *event;
-(void)initialize;
@end
