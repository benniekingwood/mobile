//
//  UListListingCell.m
//  ulink
//
//  Created by Christopher Cerwinski on 5/14/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "UListListingCell.h"
#import "AppMacros.h"
#import "ColorConverterUtil.h"
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
        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        //bgView.backgroundColor = [UIColor colorWithRed:0.901 green:0.882 blue:0.89 alpha:1.0];
        bgView.backgroundColor = [UIColor clearColor];
        
        /* background frame */
        UIView *bgView2 = [[UIView alloc] initWithFrame:CGRectMake(8, 10, 304, 300)];
        bgView2.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
        bgView2.layer.borderColor = [[UIColor colorWithRed:0.95 green:0.94 blue:0.93 alpha:1.0] CGColor];
        bgView2.layer.borderWidth = 0.75f;
        bgView2.layer.cornerRadius = 2;
        [bgView2.layer setShadowOffset:CGSizeMake(.25f, .25f)];
        [bgView2.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [bgView2.layer setShadowOpacity:0.25];
        
        /* highlight listing header */
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 304, 40)];
        header.backgroundColor = [UIColor clearColor];
        
        UILabel *user = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 304, 40)];
        user.backgroundColor = [UIColor clearColor];
        user.text = [[NSString alloc] initWithFormat:@"%@", uListListing.username];
        user.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0];
        user.textAlignment = NSTextAlignmentLeft;
        
        UILabel *expiration = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 304, 40)];
        expiration.backgroundColor = [UIColor clearColor];
        expiration.text = [[NSString alloc] initWithFormat:@"%@", uListListing.expires];
        expiration.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
        expiration.textAlignment = NSTextAlignmentRight;
        
        /* add labels to header */
        [header addSubview:user];
        [header addSubview:expiration];
        
        /* add image to list view background */
        UIImageView *listView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 40, 314, 225)];
        listView.image = [UIImage imageNamed:@"wisc_splash.png"];
        listView.layer.cornerRadius = 0.5;
        listView.layer.masksToBounds = YES;
        listView.layer.borderWidth = 3.0f;
        listView.layer.borderColor = [[UIColor blackColor] CGColor];
        
        /* add alpha black background to list view */
        UIView *listDetailBG = [[UIView alloc] initWithFrame:CGRectMake(0, 150, 314, 75)];
        listDetailBG.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:ALPHA_MED_HIGH];
        
        /* set title */    
        UILabel *uListTitle = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 311, 20)];
        uListTitle.backgroundColor = [UIColor clearColor];
        uListTitle.text = uListListing.title;
        uListTitle.textColor = [UIColor whiteColor];
        uListTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:14.0];
        uListTitle.numberOfLines = 1;
        uListTitle.textAlignment = NSTextAlignmentLeft;
        
        /* add short description */
        UILabel *shortDesc = [[UILabel alloc] initWithFrame:CGRectMake(3, 21, 311, 20)];
        shortDesc.backgroundColor = [UIColor clearColor];
        shortDesc.text = uListListing.shortDescription;
        shortDesc.textColor = [UIColor whiteColor];
        shortDesc.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
        shortDesc.numberOfLines = 1;
        shortDesc.textAlignment = NSTextAlignmentLeft;
        
        /* location */
        UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 311, 20)];
        location.backgroundColor = [UIColor clearColor];
        location.text = [[NSString alloc] initWithFormat:@"%@, %@", uListListing.location.city, uListListing.location.state];
        location.textColor = [UIColor whiteColor];
        location.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
        location.numberOfLines = 1;
        location.textAlignment = NSTextAlignmentRight;
        
        UIView *div = [[UIView alloc] initWithFrame:CGRectMake(0, 259, 304, 1)];
        div.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        //[self.textLabel.superview addSubview:div];
        
        /* create view for listing actions (will include instant reply, etc.) */
        UIView *listingActions = [[UIView alloc] initWithFrame:CGRectMake(0, 260, 304, 40)];
        listingActions.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        listingActions.layer.masksToBounds = YES;
        listingActions.layer.borderWidth = 2.0f;
        listingActions.layer.borderColor = [[UIColor whiteColor] CGColor];
        listingActions.layer.opacity = ALPHA_LOW;
        
        /* add reply to button */
        UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        replyBtn.layer.masksToBounds = YES;
        replyBtn.layer.borderWidth = 2.0f;
        replyBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
        replyBtn.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0f];
        replyBtn.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [replyBtn setFrame:CGRectMake(0, 0, 304, 40)];
        [replyBtn setTitle:@"Reply" forState:UIControlStateNormal];
        [replyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [replyBtn setImage:[UIImage imageNamed:@"options.png"] forState:UIControlStateNormal];
        [replyBtn addTarget:self action:@selector(emailLister) forControlEvents:UIControlEventTouchUpInside];
        
        // add insets
        CGFloat spacing = 6.0;
        CGSize imageSize = replyBtn.imageView.frame.size;
        CGSize titleSize = replyBtn.titleLabel.frame.size;
        replyBtn.titleEdgeInsets = UIEdgeInsetsMake(
                                                    0.0, -(imageSize.width)/2, 0.0,  0.0);
        titleSize = replyBtn.titleLabel.frame.size;
        replyBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0, -((titleSize.width)/2 + spacing), 0.0, 0.0);

        
        /* add to subviews */
        [listingActions addSubview:replyBtn];
        
        /* add subviews */
        [listDetailBG addSubview:shortDesc];
        [listDetailBG addSubview:uListTitle];
        [listDetailBG addSubview:location];
        [listView addSubview:listDetailBG];
        [bgView2 addSubview:div];
        [bgView2 addSubview:listingActions];
        [bgView2 addSubview:header];
        [bgView addSubview:bgView2];
        [bgView addSubview:listView];
        [self addSubview:bgView];
    } else if ([uListListing.type isEqualToString:@"bold"]) {
        /* bolded listing */
        /* create background view */
        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
        bgView.backgroundColor = [UIColor clearColor];
        
        /* add text view to background view */
        UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 120)];
        listView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        listView.layer.cornerRadius = 2;
        //listView.layer.masksToBounds = YES;
        listView.layer.borderColor = [[UIColor colorWithRed:0.95 green:0.94 blue:0.93 alpha:1.0] CGColor];
        listView.layer.borderWidth = 0.5f;
        [listView.layer setShadowOffset:CGSizeMake(.25f, .25f)];
        [listView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [listView.layer setShadowOpacity:.25];
        
        /* highlight listing header */
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
        header.backgroundColor = [UIColor clearColor];
        
        UILabel *user = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
        user.backgroundColor = [UIColor clearColor];
        user.text = [[NSString alloc] initWithFormat:@"%@", uListListing.username];
        user.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0];
        user.textAlignment = NSTextAlignmentLeft;
        
        UILabel *expiration = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
        expiration.backgroundColor = [UIColor clearColor];
        expiration.text = [[NSString alloc] initWithFormat:@"%@", uListListing.expires];
        expiration.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0];
        expiration.textAlignment = NSTextAlignmentRight;
        
        /* add labels to header */
        [header addSubview:user];
        [header addSubview:expiration];
        
        /* set title */
        UILabel *uListTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 310, 20)];
        uListTitle.backgroundColor = [UIColor clearColor];
        uListTitle.text = uListListing.title;
        uListTitle.textColor = [UIColor blackColor];
        uListTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:14.0];
        uListTitle.numberOfLines = 1;
        uListTitle.textAlignment = NSTextAlignmentLeft;
        
        /* add short description */
        UILabel *shortDesc = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 310, 30)];
        shortDesc.backgroundColor = [UIColor clearColor];
        shortDesc.text = uListListing.shortDescription;
        shortDesc.textColor = [UIColor whiteColor];
        shortDesc.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
        shortDesc.numberOfLines = 1;
        shortDesc.textAlignment = NSTextAlignmentLeft;
        
        /* location */
        UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 310, 10)];
        location.backgroundColor = [UIColor clearColor];
        location.text = [[NSString alloc] initWithFormat:@"%@, %@", uListListing.location.city, uListListing.location.state];
        location.textColor = [UIColor blackColor];
        location.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0];
        location.numberOfLines = 1;
        location.textAlignment = NSTextAlignmentRight;
        
        /* create view for listing actions (will include instant reply, etc.) */
        UIView *listingActions = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 310, 40)];
        listingActions.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        listingActions.layer.masksToBounds = YES;
        listingActions.layer.borderWidth = 2.0f;
        listingActions.layer.borderColor = [[UIColor whiteColor] CGColor];
        listingActions.layer.opacity = ALPHA_LOW;
        
        /* add reply to button */
        UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        replyBtn.layer.masksToBounds = YES;
        replyBtn.layer.borderWidth = 2.0f;
        replyBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
        replyBtn.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0f];
        replyBtn.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [replyBtn setFrame:CGRectMake(0, 0, 310, 40)];
        [replyBtn setTitle:@"Reply" forState:UIControlStateNormal];
        [replyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [replyBtn setImage:[UIImage imageNamed:@"options.png"] forState:UIControlStateNormal];
        [replyBtn addTarget:self action:@selector(emailLister) forControlEvents:UIControlEventTouchUpInside];
        
        // add insets
        CGFloat spacing = 6.0;
        CGSize imageSize = replyBtn.imageView.frame.size;
        CGSize titleSize = replyBtn.titleLabel.frame.size;
        replyBtn.titleEdgeInsets = UIEdgeInsetsMake(
                                                    0.0, -(imageSize.width)/2, 0.0,  0.0);
        titleSize = replyBtn.titleLabel.frame.size;
        replyBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0, -((titleSize.width)/2 + spacing), 0.0, 0.0);
        
        
        /* add to subviews */
        [listingActions addSubview:replyBtn];
        [listView addSubview:listingActions];
        [listView addSubview:header];
        [listView addSubview:uListTitle];
        [listView addSubview:shortDesc];
        [listView addSubview:location];
        [bgView addSubview:listView];
        [self addSubview:bgView];
    } else {
        /* regular listing */
        /* create background view */
        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
        bgView.backgroundColor = [UIColor clearColor];
        
        /* add text view to background view */
        UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 120)];
        listView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        listView.layer.cornerRadius = 2;
        listView.layer.masksToBounds = YES;
        listView.layer.borderColor = [[UIColor colorWithRed:0.95 green:0.94 blue:0.93 alpha:1.0] CGColor];
        listView.layer.borderWidth = 0.75f;
        [listView.layer setShadowOffset:CGSizeMake(.25f, .25f)];
        [listView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [listView.layer setShadowOpacity:0.25];
        
        /* highlight listing header */
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
        header.backgroundColor = [UIColor clearColor];
        
        UILabel *user = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
        user.backgroundColor = [UIColor clearColor];
        user.text = [[NSString alloc] initWithFormat:@"%@", uListListing.username];
        user.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
        user.textAlignment = NSTextAlignmentLeft;
        
        UILabel *expiration = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
        expiration.backgroundColor = [UIColor clearColor];
        expiration.text = [[NSString alloc] initWithFormat:@"%@", uListListing.expires];
        expiration.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
        expiration.textAlignment = NSTextAlignmentRight;
        
        /* add labels to header */
        [header addSubview:user];
        [header addSubview:expiration];
        
        /* set title */
        UILabel *uListTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 310, 20)];
        uListTitle.backgroundColor = [UIColor clearColor];
        uListTitle.text = uListListing.title;
        uListTitle.textColor = [UIColor blackColor];
        uListTitle.font = [UIFont fontWithName:FONT_GLOBAL size:14.0];
        uListTitle.numberOfLines = 1;
        uListTitle.textAlignment = NSTextAlignmentLeft;
        
        /* add short description */
        UILabel *shortDesc = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 310, 30)];
        shortDesc.backgroundColor = [UIColor clearColor];
        shortDesc.text = uListListing.shortDescription;
        shortDesc.textColor = [UIColor whiteColor];
        shortDesc.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
        shortDesc.numberOfLines = 1;
        shortDesc.textAlignment = NSTextAlignmentLeft;
        
        /* location */
        UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 310, 10)];
        location.backgroundColor = [UIColor clearColor];
        location.text = [[NSString alloc] initWithFormat:@"%@, %@", uListListing.location.city, uListListing.location.state];
        location.textColor = [UIColor blackColor];
        location.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
        location.numberOfLines = 1;
        location.textAlignment = NSTextAlignmentRight;
        
        /* create view for listing actions (will include instant reply, etc.) */
        UIView *listingActions = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 310, 40)];
        listingActions.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        listingActions.layer.masksToBounds = YES;
        listingActions.layer.borderWidth = 2.0f;
        listingActions.layer.borderColor = [[UIColor whiteColor] CGColor];
        listingActions.layer.opacity = ALPHA_LOW;
        
        /* add reply to button */
        UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        replyBtn.layer.masksToBounds = YES;
        replyBtn.layer.borderWidth = 2.0f;
        replyBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
        replyBtn.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0f];
        replyBtn.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [replyBtn setFrame:CGRectMake(0, 0, 310, 40)];
        [replyBtn setTitle:@"Reply" forState:UIControlStateNormal];
        [replyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [replyBtn setImage:[UIImage imageNamed:@"options.png"] forState:UIControlStateNormal];
        [replyBtn addTarget:self action:@selector(emailLister) forControlEvents:UIControlEventTouchUpInside];
        
        // add insets
        CGFloat spacing = 6.0;
        CGSize imageSize = replyBtn.imageView.frame.size;
        CGSize titleSize = replyBtn.titleLabel.frame.size;
        replyBtn.titleEdgeInsets = UIEdgeInsetsMake(
                                                    0.0, -(imageSize.width)/2, 0.0,  0.0);
        titleSize = replyBtn.titleLabel.frame.size;
        replyBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0, -((titleSize.width)/2 + spacing), 0.0, 0.0);
        
        
        /* add to subviews */
        [listingActions addSubview:replyBtn];
        [listView addSubview:listingActions];
        [listView addSubview:header];
        [listView addSubview:uListTitle];
        [listView addSubview:shortDesc];
        [listView addSubview:location];
        [bgView addSubview:listView];
        [self addSubview:bgView];
    }
    
    /* set to no selection style */
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

/**
 * Directly Reply to Lister:
 * This function will open up the mail client on the phone, and
 * auto populate the email to field with the reply to data from the
 * listing model.
 */
- (void) emailLister{
    NSLog(@"replying to user: %@", self.uListListing.replyTo);
    /* create the URL */
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:?to=%@&subject=%@",
                                                [self.uListListing.replyTo stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                                [@"uLink Listing Inquiry" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    
    /* load the URL */
    [[UIApplication sharedApplication] openURL:url];
}

@end
