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
#import "ULinkColorPalette.h"
#import <QuartzCore/QuartzCore.h>
#import "DataCache.h"
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>

@interface UListListingCell() {
    UIImageView *listView;
}
@end
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d"];
    if ([self.uListListing.type isEqualToString:@"highlight"]) {
        /* create background view */
        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 285)];
        //bgView.backgroundColor = [UIColor clearColor];
        bgView.backgroundColor = [UIColor uLinkLightGrayColor];
        
        /* background frame */
        UIView *bgView2 = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 265)];
        bgView2.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
        bgView2.layer.borderColor = [[UIColor colorWithRed:0.95 green:0.94 blue:0.93 alpha:1.0] CGColor];
        bgView2.layer.borderWidth = 0.5f;
        bgView2.layer.cornerRadius = 2.0f;
        //[bgView2.layer setShadowOffset:CGSizeMake(0,0)];
        //[bgView2.layer setShadowColor:[[UIColor blackColor] CGColor]];
        //[bgView2.layer setShadowOpacity:0.15];
        
        /* highlight listing header */
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
        header.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:ALPHA_MED];
        //header.backgroundColor = [UIColor clearColor];
        
        UILabel *created = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 285, 20)];
        created.backgroundColor = [UIColor clearColor];
        created.text = [dateFormatter stringFromDate:self.uListListing.created];
        created.textColor = [UIColor whiteColor];
        created.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0];
        created.textAlignment = NSTextAlignmentRight;
        
        /* add labels to header */
        [header addSubview:created];
        
        /* add image to list view background */
        listView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 310, 230)];
        listView.contentMode = UIViewContentModeScaleAspectFill;
        listView.layer.cornerRadius = 0.0f;
        listView.layer.masksToBounds = YES;
        listView.layer.borderWidth = 0.0f;
        listView.layer.borderColor = [[UIColor blackColor] CGColor];
        [self loadListingImage];
        
        /* add alpha black background to list view */
        UIView *listDetailBG = [[UIView alloc] initWithFrame:CGRectMake(0, 175, 310, 55)];
        listDetailBG.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:ALPHA_MED];
        
        /* set title */    
        UILabel *uListTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 310, 20)];
        uListTitle.backgroundColor = [UIColor clearColor];
        uListTitle.text = self.uListListing.title;
        uListTitle.textColor = [UIColor whiteColor];
        uListTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:15.0];
        uListTitle.numberOfLines = 1;
        uListTitle.textAlignment = NSTextAlignmentLeft;
        
        /* add short description */
        UILabel *shortDesc = [[UILabel alloc] initWithFrame:CGRectMake(5, 21, 310, 20)];
        shortDesc.backgroundColor = [UIColor clearColor];
        shortDesc.text = self.uListListing.shortDescription;
        shortDesc.textColor = [UIColor whiteColor];
        shortDesc.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
        shortDesc.numberOfLines = 1;
        shortDesc.textAlignment = NSTextAlignmentLeft;
        
        UIView *div = [[UIView alloc] initWithFrame:CGRectMake(0, 230, 310, 1)];
        div.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        
        /* create view for listing actions (will include instant reply, etc.) */
        UIView *listingActions = [[UIView alloc] initWithFrame:CGRectMake(0, 230, 310, 35)];
        //listingActions.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        //listingActions.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];;
        listingActions.backgroundColor = [UIColor uLinkDarkGrayColor];
        listingActions.layer.masksToBounds = YES;
        listingActions.layer.borderWidth = 0.0f;
        listingActions.layer.cornerRadius = 0.0f;
        listingActions.layer.borderColor = [[UIColor whiteColor] CGColor];
        //listingActions.layer.opacity = ALPHA_LOW;
        
        /* add reply to button */
        UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        replyBtn.layer.masksToBounds = YES;
        replyBtn.layer.borderWidth = 0.0f;
        replyBtn.layer.cornerRadius = 0.0f;
        replyBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
        replyBtn.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0f];
        //replyBtn.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        replyBtn.backgroundColor = [UIColor uLinkDarkGrayColor];
        [replyBtn setFrame:CGRectMake(0, 0, 310, 36)];
        [replyBtn setTitle:BTN_REPLY forState:UIControlStateNormal];
        [replyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [replyBtn setImage:[UIImage imageNamed:@"ulink-mobile-reply-icon.png"] forState:UIControlStateNormal];
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
        [listView addSubview:listDetailBG];
        [listView addSubview:header];
        [bgView2 addSubview:div];
        [bgView2 addSubview:listingActions];
        //[bgView2 addSubview:header];
        [bgView addSubview:bgView2];
        [bgView addSubview:listView];
        [self addSubview:bgView];
    } else {
        /* bolded and regular listing */
        /* create background view */
        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
        bgView.backgroundColor = [UIColor uLinkLightGrayColor];
        
        /* add text view to background view */
        UIView *basiclistView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 120)];
        basiclistView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        basiclistView.layer.cornerRadius = 2.0f;
        //listView.layer.masksToBounds = YES;
        basiclistView.layer.borderColor = [[UIColor colorWithRed:0.95 green:0.94 blue:0.93 alpha:1.0] CGColor];
        basiclistView.layer.borderWidth = 0.5f;
        //[listView.layer setShadowOffset:CGSizeMake(0,0)];
        //[listView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        //[listView.layer setShadowOpacity:0.15];
        
        /* highlight listing header */
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
        header.backgroundColor = [UIColor clearColor];
        
        UILabel *created = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 285, 40)];
        created.backgroundColor = [UIColor clearColor];
        created.textColor = [UIColor blackColor];
        created.text = [dateFormatter stringFromDate:self.uListListing.created];
        created.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0];
        created.textAlignment = NSTextAlignmentRight;
        
        /* add labels to header */
        [header addSubview:created];
        
        /* set title */
        UILabel *uListTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 310, 20)];
        uListTitle.backgroundColor = [UIColor clearColor];
        uListTitle.text = self.uListListing.title;
        uListTitle.textColor = [UIColor blackColor];
        // if "bold" type bold the title 
        if ([self.uListListing.type isEqualToString:@"bold"]) {
            uListTitle.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:15.0];
        } else { // else it's just a regular listing
            uListTitle.font = [UIFont fontWithName:FONT_GLOBAL size:15.0];
        }
        uListTitle.numberOfLines = 1;
        uListTitle.textAlignment = NSTextAlignmentLeft;
        
        /* add short description */
        UILabel *shortDesc = [[UILabel alloc] initWithFrame:CGRectMake(5, 45, 310, 30)];
        shortDesc.backgroundColor = [UIColor clearColor];
        shortDesc.text = self.uListListing.shortDescription;
        shortDesc.textColor = [UIColor blackColor];
        shortDesc.font = [UIFont fontWithName:FONT_GLOBAL size:12.0];
        shortDesc.numberOfLines = 1;
        shortDesc.textAlignment = NSTextAlignmentLeft;

        /* create view for listing actions (will include instant reply, etc.) */
        UIView *listingActions = [[UIView alloc] initWithFrame:CGRectMake(0, 85, 310, 35)];
        //listingActions.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        //listingActions.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
        listingActions.backgroundColor = [UIColor uLinkDarkGrayColor];
        listingActions.layer.masksToBounds = YES;
        listingActions.layer.borderWidth = 0.0f;
        listingActions.layer.cornerRadius = 0.0f;
        listingActions.layer.borderColor = [[UIColor whiteColor] CGColor];
        //listingActions.layer.opacity = ALPHA_LOW;
        
        /* add reply to button */
        UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        replyBtn.layer.masksToBounds = YES;
        replyBtn.layer.borderWidth = 0.0f;
        replyBtn.layer.cornerRadius = 0.0f;
        replyBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
        replyBtn.titleLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:12.0f];
        //replyBtn.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        replyBtn.backgroundColor = [UIColor uLinkDarkGrayColor];
        [replyBtn setFrame:CGRectMake(0, 0, 310, 36)];
        [replyBtn setTitle:BTN_REPLY forState:UIControlStateNormal];
        [replyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [replyBtn setImage:[UIImage imageNamed:@"ulink-mobile-reply-icon.png"] forState:UIControlStateNormal];
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
        [basiclistView addSubview:listingActions];
        [basiclistView addSubview:header];
        [basiclistView addSubview:uListTitle];
        [basiclistView addSubview:shortDesc];
        [bgView addSubview:basiclistView];
        [self addSubview:bgView];
    }     
    /* set to no selection style */
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void) loadListingImage {
    // first grab the listing images for the school
    NSMutableDictionary *schoolListingImages = [UDataCache.listingImageMedium objectForKey:[NSString stringWithFormat:@"%d", self.uListListing.schoolId]];
    
    // initialize the school listing image cache for the current school
    if(schoolListingImages == nil) {
        schoolListingImages = [[NSMutableDictionary alloc] init];
    }
    
    // first check to see if this listing has images in the medium cache, if it is not, load a default image
    if (self.uListListing.imageUrls == nil || self.uListListing.imageUrls.count == 0) {
        listView.image = [UDataCache.images objectForKey:KEY_DEFAULT_LISTING_IMAGE];
    } else {
        
        /*
         * grab the first image url to check to see if there is an image
         * for the url in the listing image cache.  If there ever is a case where there
         * isn't an image, we need to load it in the background with SDwebImage.
         */
        NSString *imageURL  = [self.uListListing.imageUrls objectAtIndex:0];
        NSArray* tokens = [imageURL componentsSeparatedByString: @"/"];
        NSString* imageFilename = [tokens objectAtIndex:([tokens count]-1)];
    
        // grab the event image from the listing cache
        UIImage *listingImage = [schoolListingImages objectForKey:imageFilename];
        if (listingImage == nil) {
            // set the key in the cache to let other processes know that this key is in work
            [schoolListingImages setValue:[NSNull null]  forKey:imageFilename];
            NSURL *url = [NSURL URLWithString:[URL_LISTING_IMAGE_MEDIUM stringByAppendingString:imageFilename]];
            __block ImageActivityIndicatorView *iActivityIndicator;
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            [imageDownloader downloadImageWithURL:url
                                          options:SDWebImageDownloaderProgressiveDownload
                                         progress:^(NSUInteger receivedSize, long long expectedSize) {
                                             if (!iActivityIndicator)
                                             {
                                                 iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
                                                 [iActivityIndicator showActivityIndicator:listView];
                                             }
                                         }
                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                            if (image && finished)
                                            {
                                                // add the event image to the image cache
                                                [schoolListingImages setValue:image forKey:imageFilename];
                                                // set the picture in the view
                                                listView.image = image;
                                                [iActivityIndicator hideActivityIndicator:listView];
                                                iActivityIndicator = nil;
                                            }
                                        }];
        } else if (![listingImage isKindOfClass:[NSNull class]]){
            listView.image = listingImage;
        }
        
        // set the school listing images back in the cache
        [UDataCache.listingImageMedium setValue:schoolListingImages forKey:[NSString stringWithFormat:@"%d", self.uListListing.schoolId]];
    }
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
