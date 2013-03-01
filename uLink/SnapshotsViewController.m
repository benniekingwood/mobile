//
//  SnapshotsViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/30/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SnapshotsViewController.h"
#import "SnapDetailViewController.h"
#import "SnapshotsCategoryViewController.h"
#import "AppMacros.h"
#import "SnapCategoryCell.h"
#import "DataCache.h"
#import "SnapshotUtil.h"
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>

@interface SnapshotsViewController () {
    NSMutableArray *featuredSnaps;
    int featuredSnapTag;
}
-(void)animateBackground;
-(void)setFeaturedSnapImage:(UIButton*)button snap:(Snap*)snap;
@end

@implementation SnapshotsViewController
@synthesize mainView, backgroundView, snapCategoryCollectionView;
@synthesize featBtn1, featBtn2, featBtn3, featBtn4;
@synthesize featLabel1, featLabel2, featLabel3, featLabel4;
@synthesize featLabel1Bg, featLabel2Bg, featLabel3Bg, featLabel4Bg;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mainView.userInteractionEnabled = YES;
    self.snapCategoryCollectionView.dataSource = self;
    self.snapCategoryCollectionView.delegate = self;
    self.snapCategoryCollectionView.backgroundColor = [UIColor clearColor];
    UIFont *featLabelFont = [UIFont fontWithName:FONT_GLOBAL size:12.0f];
    self.featLabel1.font = featLabelFont;
    self.featLabel1.textColor = [UIColor whiteColor];
    self.featLabel1.backgroundColor = [UIColor clearColor];
    self.featLabel1.textAlignment = NSTextAlignmentLeft;
    self.featLabel1.shadowColor = [UIColor blackColor];
    self.featLabel1.shadowOffset = CGSizeMake(0.0f, -1.0f);
    self.featLabel1.text = @"";
    self.featLabel1Bg.alpha = ALPHA_ZERO;
    self.featLabel2.font = featLabelFont;
    self.featLabel2.textColor = [UIColor whiteColor];
    self.featLabel2.backgroundColor = [UIColor clearColor];
    self.featLabel2.textAlignment = NSTextAlignmentLeft;
    self.featLabel2.shadowColor = [UIColor blackColor];
    self.featLabel2.shadowOffset = CGSizeMake(0.0f, -1.0f);
    self.featLabel2.text = @"";
    self.featLabel2Bg.alpha = ALPHA_ZERO;
    self.featLabel3.font = featLabelFont;
    self.featLabel3.textColor = [UIColor whiteColor];
    self.featLabel3.backgroundColor = [UIColor clearColor];
    self.featLabel3.textAlignment = NSTextAlignmentLeft;
    self.featLabel3.shadowColor = [UIColor blackColor];
    self.featLabel3.shadowOffset = CGSizeMake(0.0f, -1.0f);
    self.featLabel3.text = @"";
    self.featLabel3Bg.alpha = ALPHA_ZERO;
    self.featLabel4.font = featLabelFont;
    self.featLabel4.textColor = [UIColor whiteColor];
    self.featLabel4.backgroundColor = [UIColor clearColor];
    self.featLabel4.textAlignment = NSTextAlignmentLeft;
    self.featLabel4.shadowColor = [UIColor blackColor];
    self.featLabel4.shadowOffset = CGSizeMake(0.0f, -1.0f);
    self.featLabel4.text = @"";
    self.featLabel4Bg.alpha = ALPHA_ZERO;
    if(UDataCache.snapshotCategories != nil && [[UDataCache.snapshotCategories allValues] count] > 4) {
        featuredSnaps = [USnapshotUtil getFeaturedSnaps:UDataCache.snapshots snapshotCategories:UDataCache.snapshotCategories];
    }
        NSString *featured = @"Featured ";
    for (int idx = 0; idx < [featuredSnaps count]; idx++) {
            Snap *snap = [featuredSnaps objectAtIndex:idx];
            if (snap.categoryName != nil) {
               // NSLog(@"category name: %@", snap.categoryName);
                if ([self.featLabel1.text isEqualToString:@""]) {
                    self.featBtn1.alpha = ALPHA_HIGH;
                    self.featLabel1.text = [featured stringByAppendingString:snap.categoryName];
                    [featBtn1 setImage:snap.snapImage forState:UIControlStateNormal];
                    [self setFeaturedSnapImage:featBtn1 snap:snap];
                    self.featBtn1.tag = idx;
                    self.featLabel1Bg.alpha = ALPHA_MED;
                } else if ([featLabel2.text isEqualToString:@""]) {
                    featLabel2.text = [featured stringByAppendingString:snap.categoryName];
                    [featBtn2 setImage:snap.snapImage forState:UIControlStateNormal];
                    [self setFeaturedSnapImage:featBtn2 snap:snap];
                    featBtn2.alpha = ALPHA_HIGH;
                    featBtn2.tag = idx;
                    featLabel2Bg.alpha = ALPHA_MED;
                } else if ([featLabel3.text isEqualToString:@""]) {
                    featLabel3.text = [featured stringByAppendingString:snap.categoryName];
                    [featBtn3 setImage:snap.snapImage  forState:UIControlStateNormal];
                    [self setFeaturedSnapImage:featBtn3 snap:snap];
                    featBtn3.alpha = ALPHA_HIGH;
                    featBtn3.tag = idx;
                    featLabel3Bg.alpha = ALPHA_MED;
                } else if ([featLabel4.text isEqualToString:@""]) {
                    featLabel4.text = [featured stringByAppendingString:snap.categoryName];
                    [featBtn4 setImage:snap.snapImage  forState:UIControlStateNormal];
                    [self setFeaturedSnapImage:featBtn4 snap:snap];
                    featBtn4.alpha = ALPHA_HIGH;
                    featBtn4.tag = idx;
                    featLabel4Bg.alpha = ALPHA_MED;
                }
            }
        }
    [self.snapCategoryCollectionView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    for (int idx = 0; idx < [featuredSnaps count]; idx++) {
        Snap *snap = [featuredSnaps objectAtIndex:idx];
        if (snap.categoryName != nil) {
          //  NSLog(@"category name: %@", snap.categoryName);
        }
    }
    backgroundView.alpha = 0.0;
    [backgroundView sizeToFit];
    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         backgroundView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){ //task after an animation ends
                         [self performSelector:@selector(animateBackground) withObject:nil afterDelay:0.0];
                     }];
}

- (void) setFeaturedSnapImage:(UIButton *)button snap:(Snap *)snap {
    // grab the snap image from the snap cache
    UIImage *snapImage = [UDataCache imageExists:snap.snapId cacheModel:IMAGE_CACHE_SNAP_MEDIUM];
  /*  if((snapImage != nil && [snapImage isEqual:@"RELOAD_IMAGE"])) {
        NSLog(@"snap image is equal to reload image");
    }*/
    if (snapImage == nil) {
       // NSLog(@"setFeaturedSnapImage-snap image is nil");
        if(snap.snapImageURL != nil) {
        // set the key in the cache to let other processes know that this key is in work
        [UDataCache.snapImageMedium setValue:[NSNull null]  forKey:snap.snapId];
        NSURL *url = [NSURL URLWithString:[URL_SNAP_IMAGE_MEDIUM stringByAppendingString:snap.snapImageURL]];
        __block ImageActivityIndicatorView *iActivityIndicator;
        SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
        [imageDownloader downloadImageWithURL:url
                                      options:SDWebImageDownloaderProgressiveDownload
                                     progress:^(NSUInteger receivedSize, long long expectedSize) {
                                         if (!iActivityIndicator)
                                         {
                                             iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
                                             [iActivityIndicator showActivityIndicator:button.imageView];
                                             button.userInteractionEnabled = NO;
                                         }
                                     }
                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                        if (image && finished)
                                        {
                                         //   NSLog(@"setFeaturedSnapImage- image is being set");
                                            // add the snap image to the image cache
                                            [UDataCache.snapImageMedium setValue:image forKey:snap.snapId];
                                            // set the picture in the view
                                            [button setImage:image forState:UIControlStateNormal];
                                            [iActivityIndicator hideActivityIndicator:button.imageView];
                                            iActivityIndicator = nil;
                                            button.userInteractionEnabled = YES;
                                        } else {
                                          //  NSLog(@"setFeaturedSnapImage-there was an error %i", error.code);
                                            if(error.code == -1001) {
                                             //  NSLog(@"setFeaturedSnapImage-removing snap image from cache");
                                                //[UDataCache.snapImageMedium removeObjectForKey:snap.snapId];
                                                  [UDataCache.snapImageMedium removeObjectForKey:snap.snapId];
                                                 [iActivityIndicator hideActivityIndicator:button.imageView];
                                                 button.userInteractionEnabled = YES;
                                            }
                                        }
                                    }];
        }
    } else if (![snapImage isKindOfClass:[NSNull class]]){
       // NSLog(@"snap image is not nil");
        [button setImage:snapImage forState:UIControlStateNormal];
    } else {
       // NSLog(@"Snapshots View controllerImage is in weird state %@", snapImage);
    }
}
-(void)animateBackground {
    float newX = self.backgroundView.frame.origin.x-50;
    float newY = self.backgroundView.frame.origin.y+5;
    [UIView animateWithDuration:15.0
                          delay: 0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = self.backgroundView.frame;
                         frame.origin.x = newX;
                         frame.origin.y = newY;
                         self.backgroundView.frame = frame;
                     }
                     completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView section
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [UDataCache.snapshotCategories count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ksnapCategoryCellId = CELL_SNAP_CATEGORY;
    SnapCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ksnapCategoryCellId forIndexPath:indexPath];
    id key = [[UDataCache.snapshotCategories allKeys] objectAtIndex:indexPath.row];
    cell.category = [UDataCache.snapshotCategories objectForKey:key];
    [cell initialize];
    return cell;
}
#pragma mark


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_SNAP_DETAIL_VIEW_CONTROLLER]) {
        SnapDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.snap = [featuredSnaps objectAtIndex:featuredSnapTag];
        detailViewController.inUCampusMode = YES;
    } else if ([[segue identifier] isEqualToString:SEGUE_SHOW_SNAPSHOTS_CATEGORY_VIEW_CONTROLLER]) {
        SnapCategoryCell *cell = (SnapCategoryCell *)sender;
        SnapshotsCategoryViewController *categoryViewController = [segue destinationViewController];
        categoryViewController.snapCategory = cell.category;
    }
}
- (IBAction)featuredSnapClick:(id)sender {
    featuredSnapTag = ((UIButton*)sender).tag;
    [self performSegueWithIdentifier:SEGUE_SHOW_SNAP_DETAIL_VIEW_CONTROLLER sender:self];
}
@end
