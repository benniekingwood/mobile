//
//  SnapshotsCategoryViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 12/2/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapCell.h"
#import "SnapshotCategory.h"
@interface SnapshotsCategoryViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UICollectionView *snapsCollectionView;
@property (nonatomic) SnapshotCategory *snapCategory;
@end
