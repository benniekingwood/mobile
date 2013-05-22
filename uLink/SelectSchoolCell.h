//
//  SelectSchoolCell.h
//  uLink
//
//  Created by Bennie Kingwood on 12/6/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UlinkButton.h"
#import "School.h"

@interface SelectSchoolCell : UITableViewCell {
    NSString *schoolId;
    NSString *schoolName;
    School *_school;
}
@property (nonatomic, strong) NSString *schoolId;
@property (nonatomic, strong) NSString *schoolName;
@property (nonatomic, strong) School *school;
-(void)initialize:(UlinkButton*)suggestBtn;
-(void) initialize;
@end
