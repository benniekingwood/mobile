//
//  SnapshotsCategoryViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 12/2/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SnapshotsCategoryViewController.h"
#import "SnapDetailViewController.h"
#import "AppMacros.h"
#import "DataCache.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>

@interface SnapshotsCategoryViewController () {
    int cellSizeRotator;
}
@end

@implementation SnapshotsCategoryViewController
static NSString *ksnapCellId = CELL_SNAP_CELL;
@synthesize category, snapCategory;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.snapsCollectionView.dataSource = self;
    self.snapsCollectionView.delegate = self;

    if([[UDataCache.snapshots objectForKey:self.snapCategory.snapCategoryId] count] == 0) {
        UILabel *noSnaps = [[UILabel alloc] init];
        noSnaps.font = [UIFont fontWithName:FONT_GLOBAL size:17.0f];
        noSnaps.textColor = [UIColor blackColor];
        noSnaps.frame = CGRectMake(20, 150, 280, 100);
        noSnaps.numberOfLines = 0;
        noSnaps.textAlignment = NSTextAlignmentCenter;
        noSnaps.backgroundColor = [UIColor whiteColor];
        noSnaps.layer.cornerRadius = 5;
        noSnaps.text = @"There are no snapshots for this category at this time.  It's up to you to start snapping!";
        [self.view addSubview:noSnaps];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.category.text = self.snapCategory.name;
    cellSizeRotator = 0;
    [self.snapsCollectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UICollectionView section
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[UDataCache.snapshots objectForKey:self.snapCategory.snapCategoryId] count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SnapCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ksnapCellId forIndexPath:indexPath];
    Snap *snap = [[UDataCache.snapshots objectForKey:self.snapCategory.snapCategoryId]  objectAtIndex:indexPath.item];
    [cell setSnapShot:snap];
    // grab the snap image from the snap cache
    UIImage *snapImage = [UDataCache imageExists:snap.snapId cacheModel:IMAGE_CACHE_SNAP_MEDIUM];
    if (snapImage == nil) {
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
                                             [iActivityIndicator showActivityIndicator:cell.snapImage];
                                             cell.userInteractionEnabled = NO;
                                         }
                                     }
                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                        if (image && finished)
                                        {
                                            // add the snap image to the image cache
                                            [UDataCache.snapImageMedium setValue:image forKey:snap.snapId];
                                            // set the picture in the view
                                            cell.snapImage.image = image;
                                            [iActivityIndicator hideActivityIndicator:cell.snapImage];
                                            iActivityIndicator = nil;
                                            cell.userInteractionEnabled = YES;
                                        } else {
                                          //  NSLog(@"setFeaturedSnapImage-there was an error %i", error.code);
                                            if(error.code == -1001) {
                                              //  NSLog(@"setFeaturedSnapImage-removing snap image from cache");
                                                [UDataCache.snapImageMedium removeObjectForKey:snap.snapId];
                                                [iActivityIndicator hideActivityIndicator:cell.snapImage];
                                            }
                                        }

                                    }];
        }
    } else if (![snapImage isKindOfClass:[NSNull class]]){
        cell.snapImage.image = snapImage;
    }else {
       // NSLog(@"Image is in weird state %@", snapImage);
    }

    cell.alpha = 0.0;
    [UIView animateWithDuration:0.8 animations:^{
        cell.alpha = 1.0;
    }];
    return cell;
}

#pragma mark
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_SNAP_DETAIL_VIEW_CONTROLLER]) {
        SnapCell *cell = (SnapCell *)sender;
        SnapDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.snap = cell.snap;
        detailViewController.inUCampusMode = YES;
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retval;
    float width = 105.0f;
    float height = 110.0f;
    switch(cellSizeRotator) {
        case 0: retval = CGSizeMake(320, height);
            break;
        case 1: retval = CGSizeMake(width, height);
            break;
        case 2: retval = CGSizeMake(width, height);
            break;
        case 3: retval = CGSizeMake(width, height);
            break;
        case 4: retval = CGSizeMake(159, height);
            break;
        case 5: retval = CGSizeMake(159, height);
            break;
        case 6: retval = CGSizeMake(width, height);
            break;
        case 7: retval = CGSizeMake(width, height);
            break;
        case 8: retval = CGSizeMake(width, height);
            break;
        case 9: retval = CGSizeMake(320, height);
            cellSizeRotator = -1;
            break;
    }
    cellSizeRotator++;
    return retval;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(22, 0, 0, 0);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {}
@end
