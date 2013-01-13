//
//  SnapCategoryCell.h
//  uLink
//
//  Created by Bennie Kingwood on 12/18/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapshotCategory.h"
@interface SnapCategoryCell : UICollectionViewCell
@property (strong, nonatomic) SnapshotCategory *category;
@property (strong, nonatomic) IBOutlet UILabel *snapCategoryLabel;
-(void)initialize;
@end
