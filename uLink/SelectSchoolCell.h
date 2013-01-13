//
//  SelectSchoolCell.h
//  uLink
//
//  Created by Bennie Kingwood on 12/6/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UlinkButton.h"

@interface SelectSchoolCell : UITableViewCell {
    NSString *schoolId;
    NSString *schoolName;
}
@property (nonatomic, strong) NSString *schoolId;
@property (nonatomic, strong) NSString *schoolName;
-(void)initialize:(UlinkButton*)suggestBtn;
@end
