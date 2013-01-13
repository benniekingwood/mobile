//
//  SnapCell.h
//  uLink
//
//  Created by Bennie Kingwood on 11/15/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snap.h"

@interface SnapCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView *snapImage;
@property (nonatomic) Snap *snap;
- (void) setSnapShot:(Snap *)newSnap;
@end
