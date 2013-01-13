//
//  MySnapsViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/15/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapCell.h"

@interface MySnapsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (IBAction)snapCellClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *snapsCollection;
@end
