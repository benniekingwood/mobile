//
//  EventDetailViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/26/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface EventDetailViewController : UIViewController <UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UILabel *eventLocation;
@property (strong, nonatomic) IBOutlet UILabel *eventDateTime;
@property (strong, nonatomic) IBOutlet UILabel *eventUsername;
@property (strong, nonatomic) IBOutlet UILabel *eventTitle;
@property (strong, nonatomic) IBOutlet UIImageView *eventImageView;
@property (strong, nonatomic) IBOutlet UIImageView *eventUserPicView;
@property (nonatomic, strong) Event *event;
@property (strong, nonatomic) IBOutlet UITextView *eventInfoView;
@end
