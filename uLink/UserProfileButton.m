//
//  UserProfileButton.m
//  uLink
//
//  Created by Bennie Kingwood on 12/27/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "UserProfileButton.h"
#import <QuartzCore/QuartzCore.h>
#import "UserProfileViewController.h"
#import "AppMacros.h"
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import "DataCache.h"
@interface UserProfileButton ()
- (void) removeHighlight;
@end
@implementation UserProfileButton
@synthesize user;
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.highlighted == YES)
    {
        [self setAlpha:0.5];
    }
    else
    {
        // Do custom drawing for normal state
        [self setAlpha:1.0];
    }
}

+ (id)buttonWithType:(UIButtonType)buttonType {
    return [super buttonWithType:buttonType];
}

- (void) initialize {
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self setImage:self.user.profileImage forState:UIControlStateNormal];
    self.layer.cornerRadius = 5;
    self.userInteractionEnabled = YES;
    self.layer.masksToBounds = YES;
    // grab the user's image from the user cache
    UIImage *profileImage = [UDataCache imageExists:self.user.userId cacheModel:IMAGE_CACHE_USER_THUMBS];
    if (profileImage == nil || [profileImage isKindOfClass:[NSNull class]]) {
        if (self.user.userImgURL != nil ) {
            // set the key in the cache to let other processes know that this key is in work
            [UDataCache.userImageThumbs setValue:[NSNull null] forKey:self.user.userId];
            // lazy load the image from the web
            NSURL *url = [NSURL URLWithString:[URL_USER_IMAGE_THUMB stringByAppendingString:self.user.userImgURL]];
            __block ImageActivityIndicatorView *activityIndicator;
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            [imageDownloader downloadImageWithURL:url
                                          options:SDWebImageDownloaderProgressiveDownload
                                         progress:^(NSUInteger receivedSize, long long expectedSize) {
                                             if (!activityIndicator)
                                             {
                                                 activityIndicator = [[ImageActivityIndicatorView alloc] init];
                                                 [activityIndicator showActivityIndicator:self.imageView];
                                             }
                                         }
                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                            if (image && finished)
                                            {
                                                // add the user's image to the image cache
                                                [UDataCache.userImageThumbs setValue:image forKey:self.user.userId];
                                                // set the picture in the view
                                                [self setImage:image forState:UIControlStateNormal];
                                                [activityIndicator hideActivityIndicator:self.imageView];
                                                activityIndicator = nil;
                                            }
                                        }];
        }
    } else if (![profileImage isKindOfClass:[NSNull class]]) {
         [self setImage:profileImage forState:UIControlStateNormal];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if(self.highlighted) {
        [self removeHighlight];
        // Draw a custom gradient
        CAGradientLayer *btnGradient = [CAGradientLayer layer];
        btnGradient.name = @"Highlight";
        btnGradient.frame = self.bounds;
        btnGradient.colors = [NSArray arrayWithObjects:
                              (id)[[UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.4f] CGColor],
                              (id)[[UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.4f] CGColor],
                              nil];
        //[self.layer insertSublayer:btnGradient atIndex:1];
        [self.layer addSublayer:btnGradient];
    }
    else {
        [self removeHighlight];
    }
}

-(void) removeHighlight {
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.name isEqualToString:@"Highlight"]) {
            [layer removeFromSuperlayer];
            break;
        }
    }
}
- (void)dealloc
{
    @try {
        [self removeObserver:self forKeyPath:@"highlighted"];
    }@catch(id anException){} // digest exception
}
@end
