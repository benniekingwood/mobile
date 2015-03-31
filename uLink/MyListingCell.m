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
#import "ULinkColorPalette.h"
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
    
    // clear any old subviews from the form since they are reused
    [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // create the new label that will hold the listing title
    if([self.listing.type isEqualToString:@"bold"] || [self.listing.type isEqualToString:@"highlight"]) {
        title = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 200, 70)];
    } else {
        title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 70)];
    }
    
    title.numberOfLines = 0;
    title.font = [UIFont fontWithName:FONT_GLOBAL size:15.0f];
    title.textColor = [UIColor blackColor];
    title.backgroundColor = [UIColor clearColor];
    title.text = self.listing.title;
    
    // we need to remove the old title from the previous cell since the cell is reused in memory
    if([self.listing.type isEqualToString:@"bold"] || [self.listing.type isEqualToString:@"highlight"]) {
        typeView = [[UIView alloc] initWithFrame:CGRectMake(15, 20, 30, 30)];
        
        typeView.layer.cornerRadius = 5;
        typeView.layer.masksToBounds = YES;
        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 6, 20, 20)];
        typeLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:20.0f];
        typeLabel.textColor = [UIColor whiteColor];
        typeLabel.backgroundColor = [UIColor clearColor];
        // add the bold or headline label image if the listing is bolded or highlighted
        if([self.listing.type isEqualToString:@"bold"]) {
            typeView.backgroundColor = [UIColor uLinkLightBlueColor];
            typeLabel.text = @"B";
        } else if([self.listing.type isEqualToString:@"highlight"]) {
            typeView.backgroundColor = [UIColor uLinkOrangeColor];
            typeLabel.text = @"H";
        }
        [typeView addSubview:typeLabel];
        [self.contentView addSubview:typeView];
    }
    
    [self.contentView addSubview:title];
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}


@end
