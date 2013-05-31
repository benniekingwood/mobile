//
//  UListListingCell.m
//  ulink
//
//  Created by Christopher Cerwinski on 5/14/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListListingCell.h"
#import "AppMacros.h"
#import <QuartzCore/QuartzCore.h>

@implementation UListListingCell
@synthesize uListListing;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) initialize {
    self.clipsToBounds = YES;
    
    if ([uListListing.type isEqualToString:@"headline"]) {
        /* create background view */
        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
        bgView.backgroundColor = [UIColor colorWithRed:0.901 green:0.882 blue:0.89 alpha:1.0];
        
        /* add image to list view background */
        UIImageView *listView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 310, 170)];
        listView.image = [UIImage imageNamed:@"wisc_splash.png"];
        listView.layer.cornerRadius = 3;
        listView.layer.masksToBounds = YES;
        
        /* add alpha black background to list view */
        // Do any additional setup after loading the view.
        UIView *listDetailBG = [[UIView alloc] initWithFrame:CGRectMake(0, 130, 310, 50)];
        listDetailBG.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:ALPHA_MED_HIGH];
        
        /* set title */    
        UILabel *uListTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
        uListTitle.backgroundColor = [UIColor clearColor];
        uListTitle.text = uListListing.title;
        uListTitle.textColor = [UIColor whiteColor];
        uListTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:14.0];
        uListTitle.numberOfLines = 1;
        uListTitle.textAlignment = NSTextAlignmentLeft;
        
        /* add short description */
        
        self.imageView.contentMode = UIViewContentModeCenter;
        
        /* add subviews */
        [listDetailBG addSubview:uListTitle];
        [listView addSubview:listDetailBG];
        [bgView addSubview:listView];
        [self addSubview:bgView];
    } else if ([uListListing.type isEqualToString:@"bold"]) {
        /* bolded listing */
        /* create background view */
        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
        bgView.backgroundColor = [UIColor colorWithRed:0.901 green:0.882 blue:0.89 alpha:1.0];
        
        /* add text view to background view */
        UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 320, 70)];
        listView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        listView.layer.cornerRadius = 1;
        listView.layer.masksToBounds = YES;
        
        /* set title */
        UILabel *uListTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        uListTitle.backgroundColor = [UIColor clearColor];
        uListTitle.text = uListListing.title;
        uListTitle.textColor = [UIColor blackColor];
        uListTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:14.0];
        uListTitle.numberOfLines = 1;
        uListTitle.textAlignment = NSTextAlignmentLeft;
        
        [listView addSubview:uListTitle];
        [bgView addSubview:listView];
        [self addSubview:bgView];
    } else {
        /* regular listing */
        /* create background view */
        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 130)];
        bgView.backgroundColor = [UIColor colorWithRed:0.901 green:0.882 blue:0.89 alpha:1.0];
        
        /* add text view to background view */
        UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 320, 120)];
        listView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        listView.layer.cornerRadius = 1;
        listView.layer.masksToBounds = YES;
        
        /* set title */
        UILabel *uListTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        uListTitle.backgroundColor = [UIColor clearColor];
        uListTitle.text = uListListing.title;
        uListTitle.textColor = [UIColor blackColor];
        uListTitle.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
        uListTitle.numberOfLines = 1;
        uListTitle.textAlignment = NSTextAlignmentLeft;
        
        [listView addSubview:uListTitle];
        [bgView addSubview:listView];
        [self addSubview:bgView];
    }
    
    /* set to no selection style */
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
