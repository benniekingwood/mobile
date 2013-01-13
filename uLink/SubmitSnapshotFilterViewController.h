//
//  SubmitSnapshotFilterViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 12/3/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UlinkButton.h"
#import "FilterCell.h"
@interface SubmitSnapshotFilterViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UICollectionView *snapFiltersCollection;
@property (strong, nonatomic) IBOutlet UlinkButton *resetFiltersButton;
@property (strong, nonatomic) IBOutlet UIView *submitSnapSuccessView;
- (IBAction)submitClick:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@end
