//
//  SnapshotsViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/30/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnapshotsViewController : UIViewController <UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UILabel *featLabel3Bg;
@property (strong, nonatomic) IBOutlet UILabel *featLabel4Bg;
@property (strong, nonatomic) IBOutlet UILabel *featLabel2Bg;
@property (strong, nonatomic) IBOutlet UILabel *featLabel1Bg;
@property (strong, nonatomic) IBOutlet UILabel *featLabel3;
@property (strong, nonatomic) IBOutlet UILabel *featLabel4;
@property (strong, nonatomic) IBOutlet UILabel *featLabel2;
@property (strong, nonatomic) IBOutlet UILabel *featLabel1;
@property (strong, nonatomic) IBOutlet UIButton *featBtn4;
@property (strong, nonatomic) IBOutlet UIButton *featBtn3;
@property (strong, nonatomic) IBOutlet UIButton *featBtn2;
@property (strong, nonatomic) IBOutlet UIButton *featBtn1;
@property (strong, nonatomic) IBOutlet UIView *mainView;
- (IBAction)featuredSnapClick:(id)sender;
@property (strong, nonatomic) IBOutlet UICollectionView *snapCategoryCollectionView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@end
