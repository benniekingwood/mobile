//
//  FilterCell.h
//  uLink
//
//  Created by Bennie Kingwood on 12/3/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView *filterImage;
@property (nonatomic, strong) IBOutlet NSString *filterName;
-(void)initialize;
@end
