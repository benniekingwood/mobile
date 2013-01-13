//
//  SubmitSnapshotFilterViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 12/3/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SubmitSnapshotFilterViewController.h"
#import "SubmitSnapshotViewController.h"

@interface SubmitSnapshotFilterViewController ()
{
     NSArray *filters;
}
-(void)doneClick;
@end

@implementation SubmitSnapshotFilterViewController
static NSString *kfilterCellId = @"filtercell";
@synthesize resetFiltersButton, submitSnapSuccessView;
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
    self.submitSnapSuccessView.alpha = 0.0;
	// Do any additional setup after loading the view.
    [resetFiltersButton createOrangeButton:resetFiltersButton];
    UIImage *al = [UIImage imageNamed:@"80s.jpg"];
    UIImage *nat = [UIImage imageNamed:@"nature.jpg"];
    UIImage *home = [UIImage imageNamed:@"home-bg-1.png"];
    UIImage *b = [UIImage imageNamed:@"bleach-characters.jpg"];
    UIImage *bb = [UIImage imageNamed:@"alfred.png"];
    filters = [[NSArray alloc] initWithObjects:al,b,home,home,bb,al,nat,bb,al,b,bb,al, nil];
    
	// Do any additional setup after loading the view.
    [[self snapFiltersCollection] setDataSource:self];
    [[self snapFiltersCollection] setDelegate:self];
    self.snapFiltersCollection.backgroundColor = [UIColor clearColor];
    self.snapFiltersCollection.showsHorizontalScrollIndicator = NO;
    self.snapFiltersCollection.showsVerticalScrollIndicator = NO;
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView section
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [filters count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kfilterCellId forIndexPath:indexPath];
    [[cell filterImage] setImage:[filters objectAtIndex:indexPath.item]];
    [cell setFilterName:[NSString stringWithFormat:@"Filter %i",indexPath.item]];
    [cell initialize];
    cell.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        cell.alpha = 1.0;
    }];
    return cell;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    //NSLog(@"selected");
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (IBAction)submitClick:(UIBarButtonItem *)sender {
    self.submitSnapSuccessView.alpha = 1.0;
    self.submitButton.enabled = NO;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(doneClick)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem  = doneButton;
  
}
-(void)doneClick {
    id previousController = [[self.navigationController viewControllers] objectAtIndex:0];
    SubmitSnapshotViewController  *submitSnapshotController = (SubmitSnapshotViewController*)previousController;
    submitSnapshotController.dismissImmediately = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
