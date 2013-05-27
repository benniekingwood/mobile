//
//  MyListingCell.m
//  ulink
//
//  Created by Bennie Kingwood on 5/26/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "MyListingCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMacros.h"
#import "DataCache.h"
@interface MyListingCell() {
    UILabel *title;
    UIView *typeView;
    UILabel *typeLabel;
}
@end
@implementation MyListingCell
@synthesize listing = _listing;
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

- (void)initialize {
    self.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.masksToBounds = YES;
    
    // we need to remove the old title from the previous cell since the cell is reused in memory
    [title removeFromSuperview];
    // create the new label that will hold the listing title
    title = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 200, 50)];
    title.numberOfLines = 2;
    title.font = [UIFont fontWithName:FONT_GLOBAL size:15.0f];
    title.textColor = [UIColor blackColor];
    title.backgroundColor = [UIColor clearColor];
    title.text = self.listing.title;
    
    typeView = [[UIView alloc] initWithFrame:CGRectMake(15, 7, 30, 30)];
    typeView.layer.cornerRadius = 5;
    typeView.layer.masksToBounds = YES;
    typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 6, 20, 20)];
    typeLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:20.0f];
    typeLabel.textColor = [UIColor whiteColor];
    typeLabel.backgroundColor = [UIColor clearColor];
    // add the bold or headline label image if the listing is bolded or highlighted
    if([self.listing.type isEqualToString:@"bold"]) {
        typeView.backgroundColor = [UIColor colorWithRed:(19.0 / 255.0) green:(122.0 / 255.0) blue:(188.0 / 255.0) alpha: 1];
        typeLabel.text = @"B";
    } else if([self.listing.type isEqualToString:@"highlight"]) {
        typeView.backgroundColor = [UIColor colorWithRed:(255.0 / 255.0) green:(146.0 / 255.0) blue:(23.0 / 255.0) alpha: 1];
        typeLabel.text = @"H";
    }
    [typeView addSubview:typeLabel];
    [self.contentView addSubview:typeView];
   
    [self.contentView addSubview:title];
    
    
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}


@end
