//
//  SelectSchoolCell.m
//  uLink
//
//  Created by Bennie Kingwood on 12/6/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SelectSchoolCell.h"
#import "AppMacros.h"

@implementation SelectSchoolCell
@synthesize schoolId, schoolName;
@synthesize school = _school;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initialize:(UlinkButton*)suggestBtn {
    self.textLabel.font = [UIFont fontWithName:FONT_GLOBAL size:15.0f];;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.text = @"Don't see your school?";
    [self.textLabel.superview addSubview:suggestBtn];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
-(void)initialize {
    if(self.school != nil)
    {
        self.schoolId = self.school.schoolId;
        self.schoolName = self.school.name;
        self.textLabel.text = self.school.name;
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
}
@end
