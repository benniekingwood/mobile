//
//  MySnapsViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/15/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "MySnapsViewController.h"
#import "SnapDetailViewController.h"
#import "DataCache.h"
#import "AppMacros.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import "ImageActivityIndicatorView.h"

@implementation MySnapsViewController
static NSString *cellId = CELL_MY_SNAP_CELL;
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
    self.snapsCollection.delegate = self;
    self.snapsCollection.dataSource = self;
    self.snapsCollection.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.snapsCollection reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [UDataCache.sessionUser.snaps count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SnapCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    Snap *snap = [UDataCache.sessionUser.snaps objectAtIndex:indexPath.item];
    [cell setSnapShot:snap];
    
    // grab the snap image from the snap cache
    UIImage *snapImage = [UDataCache imageExists:snap.snapId cacheModel:IMAGE_CACHE_SNAP_MEDIUM];
    if (snapImage == nil) {
        if(snap.snapImageURL != nil) {
        // set the key in the cache to let other processes know that this key is in work
        [UDataCache.snapImageMedium setValue:[NSNull null]  forKey:snap.snapId];
        NSURL *url = [NSURL URLWithString:[URL_SNAP_IMAGE_MEDIUM stringByAppendingString:snap.snapImageURL]];
        __block ImageActivityIndicatorView *activityIndicator;
        SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
        [imageDownloader downloadImageWithURL:url
                options:SDWebImageDownloaderProgressiveDownload
                 progress:^(NSUInteger receivedSize, long long expectedSize) {
                     if (!activityIndicator)
                     {
                         activityIndicator = [[ImageActivityIndicatorView alloc] init];
                         [activityIndicator showActivityIndicator:cell.snapImage];
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
                [activityIndicator hideActivityIndicator:cell.snapImage];
                activityIndicator = nil;
                cell.userInteractionEnabled = YES;
            }
        }];
        }
    } else if (![snapImage isKindOfClass:[NSNull class]]){
        cell.snapImage.image = snapImage;
    }
    cell.alpha = 0.0;
    [UIView animateWithDuration:0.8 animations:^{
        cell.alpha = 1.0;
    }];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_SNAP_DETAIL_VIEW_CONTROLLER])
    {
        SnapCell *cell = (SnapCell *)sender;        
        SnapDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.snap = cell.snap;
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retval;
    float width = 80.0f;
    float height = 80.0f;
    retval = CGSizeMake(width, height);
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {}


#pragma mark - Button Actions
- (IBAction)snapCellClick:(UIButton *)sender {
     [self performSegueWithIdentifier:SEGUE_SHOW_SNAP_DETAIL_VIEW_CONTROLLER sender:self];
}
@end
