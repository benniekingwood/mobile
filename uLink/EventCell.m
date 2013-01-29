//
//  EventCell.m
//  uLink
//
//  Created by Bennie Kingwood on 12/22/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "EventCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMacros.h"
#import "DataCache.h"
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>
@interface EventCell() {
    UILabel *eventTitle;
    UILabel *eventDate;
}
@end
@implementation EventCell
@synthesize event;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}
- (void)initialize {
    self.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.masksToBounds = YES;
    [eventTitle removeFromSuperview];
    eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, -5, 200, 50)];
    eventTitle.numberOfLines = 2;
    eventTitle.font = [UIFont fontWithName:FONT_GLOBAL size:15.0f];
    eventTitle.textColor = [UIColor blackColor];
    eventTitle.backgroundColor = [UIColor clearColor];
    eventTitle.text = self.event.title;
    
    [eventDate removeFromSuperview];
    eventDate = [[UILabel alloc] initWithFrame:CGRectMake(80, 40, 100, 20)];
    eventDate.font = [UIFont fontWithName:FONT_GLOBAL size:10.0f];
    eventDate.textColor = [UIColor grayColor];
    eventDate.backgroundColor = [UIColor clearColor];
    eventDate.text = self.event.clearDate;
    self.imageView.image  = self.event.image;
    
    // grab the event image from the event cache
    UIImage *eventImage = [UDataCache imageExists:self.event.eventId cacheModel:IMAGE_CACHE_EVENT_THUMBS];
    if (eventImage == nil) {
        if(![self.event.imageURL isKindOfClass:[NSNull class]] && self.event.imageURL != nil && ![self.event.imageURL isEqualToString:@""]) {
            // set the key in the cache to let other processes know that this key is in work
            [UDataCache.eventImageThumbs setValue:[NSNull null]  forKey:self.event.eventId];
            
            NSURL *url = [NSURL URLWithString:[URL_EVENT_IMAGE_THUMB stringByAppendingString:self.event.imageURL]];
            __block ImageActivityIndicatorView *activityIndicator;
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            [imageDownloader downloadImageWithURL:url
                                          options:SDWebImageDownloaderProgressiveDownload
                                         progress:^(NSUInteger receivedSize, long long expectedSize) {
                                             if (!activityIndicator)
                                             {
                                                 activityIndicator = [[ImageActivityIndicatorView alloc] init];
                                                 [activityIndicator showActivityIndicator:self.imageView];
                                                 self.userInteractionEnabled = NO;
                                             }
                                         }
                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                            if (image && finished)
                                            {
                                                // add the event image to the image cache
                                                [UDataCache.eventImageThumbs setValue:image forKey:self.event.eventId];
                                                // set the picture in the view
                                                self.imageView.image = image;
                                                [activityIndicator hideActivityIndicator:self.imageView];
                                                activityIndicator = nil;
                                                self.userInteractionEnabled = YES;
                                            }
                                        }];
        }
    } else if(![eventImage isKindOfClass:[NSNull class]]) {
        self.imageView.image = eventImage;
    }
    
    [self.contentView addSubview:eventDate];
    [self.contentView addSubview:eventTitle];
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(20, 4, 50, 50);
}
@end
