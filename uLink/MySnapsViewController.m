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

@interface MySnapsViewController ()
@end

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
    [[self snapsCollection] setDataSource:self];
    [[self snapsCollection] setDelegate:self];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cork.png"]];
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
    [cell setSnapShot:[UDataCache.sessionUser.snaps objectAtIndex:indexPath.item]];
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
    
    UIImage *snapImage = ((Snap*)[UDataCache.sessionUser.snaps objectAtIndex:indexPath.row]).snapImage;
    CGSize retval;
    float oldWidth = snapImage.size.width;
    float oldHeight = snapImage.size.height;
    float newWidth = 0.0f;
    float newHeight = 0.0f;
    if (oldWidth >= oldHeight && oldWidth > 70.0f) {
        float scaleFactor = 50.0f / oldWidth;
         newHeight = oldHeight * scaleFactor;
         newWidth = oldWidth * scaleFactor;
         retval = CGSizeMake(newWidth, newHeight);
    } else if(oldHeight > oldWidth && oldHeight > 70.0f) {
        float scaleFactor = 50.0f / oldHeight;
         newWidth = oldWidth * scaleFactor;
         newHeight = oldHeight * scaleFactor;
         retval = CGSizeMake(newWidth, newHeight);
    } else {
         retval = CGSizeMake(oldWidth, oldHeight);
    }
 
    retval.height += 35; retval.width += 35;
    
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 20, 10, 20);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {}


#pragma mark - Button Actions
- (IBAction)snapCellClick:(UIButton *)sender {
     [self performSegueWithIdentifier:SEGUE_SHOW_SNAP_DETAIL_VIEW_CONTROLLER sender:self];
}
@end
