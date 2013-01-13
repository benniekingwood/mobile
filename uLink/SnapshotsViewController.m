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

@interface SnapshotsViewController () {
    NSMutableArray *featuredSnaps;
    int featuredSnapTag;
}
-(void)animateBackground;
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
    featLabel1.font = featLabelFont;
    featLabel1.textColor = [UIColor whiteColor];
    featLabel1.backgroundColor = [UIColor clearColor];
    featLabel1.textAlignment = NSTextAlignmentLeft;
    featLabel1.shadowColor = [UIColor blackColor];
    featLabel1.shadowOffset = CGSizeMake(0.0f, -1.0f);
    featLabel1.text = @"";
    featLabel1Bg.alpha = ALPHA_ZERO;
    featLabel2.font = featLabelFont;
    featLabel2.textColor = [UIColor whiteColor];
    featLabel2.backgroundColor = [UIColor clearColor];
    featLabel2.textAlignment = NSTextAlignmentLeft;
    featLabel2.shadowColor = [UIColor blackColor];
    featLabel2.shadowOffset = CGSizeMake(0.0f, -1.0f);
    featLabel2.text = @"";
    featLabel2Bg.alpha = ALPHA_ZERO;
    featLabel3.font = featLabelFont;
    featLabel3.textColor = [UIColor whiteColor];
    featLabel3.backgroundColor = [UIColor clearColor];
    featLabel3.textAlignment = NSTextAlignmentLeft;
    featLabel3.shadowColor = [UIColor blackColor];
    featLabel3.shadowOffset = CGSizeMake(0.0f, -1.0f);
    featLabel3.text = @"";
    featLabel3Bg.alpha = ALPHA_ZERO;
    featLabel4.font = featLabelFont;
    featLabel4.textColor = [UIColor whiteColor];
    featLabel4.backgroundColor = [UIColor clearColor];
    featLabel4.textAlignment = NSTextAlignmentLeft;
    featLabel4.shadowColor = [UIColor blackColor];
    featLabel4.shadowOffset = CGSizeMake(0.0f, -1.0f);
    featLabel4.text = @"";
    featLabel4Bg.alpha = ALPHA_ZERO;
    if(UDataCache.snapshotCategories != nil && [[UDataCache.snapshotCategories allValues] count] > 4) {
        featuredSnaps = [USnapshotUtil getFeaturedSnaps:UDataCache.snapshots snapshotCategories:UDataCache.snapshotCategories];
    }
        NSString *featured = @"Featured ";
    for (int idx = 0; idx < [featuredSnaps count]; idx++) {
            Snap *snap = [featuredSnaps objectAtIndex:idx];
            if (snap.categoryName != nil) {
                if ([featLabel1.text isEqualToString:@""]) {
                    featLabel1.text = [featured stringByAppendingString:snap.categoryName];
                    [featBtn1 setImage:snap.snapImage forState:UIControlStateNormal];
                    featBtn1.alpha = ALPHA_HIGH;
                    featBtn1.tag = idx;
                    featLabel1Bg.alpha = ALPHA_MED;
                } else if ([featLabel2.text isEqualToString:@""]) {
                    featLabel2.text = [featured stringByAppendingString:snap.categoryName];
                    [featBtn2 setImage:snap.snapImage forState:UIControlStateNormal];
                    featBtn2.alpha = ALPHA_HIGH;
                    featBtn2.tag = idx;
                    featLabel2Bg.alpha = ALPHA_MED;
                } else if ([featLabel3.text isEqualToString:@""]) {
                    featLabel3.text = [featured stringByAppendingString:snap.categoryName];
                    [featBtn3 setImage:snap.snapImage forState:UIControlStateNormal];
                    featBtn3.alpha = ALPHA_HIGH;
                    featBtn3.tag = idx;
                    featLabel3Bg.alpha = ALPHA_MED;
                } else if ([featLabel4.text isEqualToString:@""]) {
                    featLabel4.text = [featured stringByAppendingString:snap.categoryName];
                    [featBtn4 setImage:snap.snapImage forState:UIControlStateNormal];
                    featBtn4.alpha = ALPHA_HIGH;
                    featBtn4.tag = idx;
                    featLabel4Bg.alpha = ALPHA_MED;
                }
            }
        }
    [self.snapCategoryCollectionView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
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
