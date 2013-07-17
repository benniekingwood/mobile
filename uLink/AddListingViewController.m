//
//  AddListingViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 6/22/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "AddListingViewController.h"
#import "AppMacros.h"
#import "AddListingTextViewController.h"
#import "AddListingLocationViewController.h"
#import "AddListingAddOnViewController.h"
#import "AddListingPhotoViewController.h"
#import "ColorConverterUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "DataCache.h"

@interface AddListingViewController () {
    UILabel *titleRequired;
    UILabel *descriptionRequired;
    UILabel *priceRequired;
    UIImageView *titleSuccessImageView;
    UIImageView *descriptionSuccessImageView;
    UILabel *priceSuccessLabel;
    UIImageView *locationSuccessImageView;
    UIImageView *tagsSuccessImageView;
}
@end

@implementation AddListingViewController
@synthesize mainCategory, subCategory, listing;
@synthesize titleCell, descriptionCell, locationCell, tagsCell, priceCell;
@synthesize nextButton;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Add Listing";
    // create the basic info table
    [self.tableView setBackgroundView: nil];
    
    // set up the basic default values for the listing
    self.listing = [[Listing alloc] init];
    self.listing.created = [NSDate date];
    self.listing.price = -37;
    self.listing.schoolId = [UDataCache.sessionUser.schoolId intValue];
    self.listing.userId = [UDataCache.sessionUser.userId intValue];
    self.listing.replyTo = UDataCache.sessionUser.email;
    self.listing.username = UDataCache.sessionUser.username;
    self.listing.mainCategory = self.mainCategory;
    self.listing.category = self.subCategory;
    
    // title required label
    titleRequired = [[UILabel alloc] initWithFrame:CGRectMake(250, 7, 50, 30)];
    titleRequired.font = [UIFont fontWithName:FONT_GLOBAL size:12];
    titleRequired.textColor = [UIColor colorWithHexString:@"#990000"];
    titleRequired.backgroundColor = [UIColor clearColor];
    titleRequired.text = @"Required";
    [self.titleCell addSubview:titleRequired];
    
    // description required label
    descriptionRequired = [[UILabel alloc] initWithFrame:CGRectMake(250, 7, 50, 30)];
    descriptionRequired.font = [UIFont fontWithName:FONT_GLOBAL size:12];
    descriptionRequired.textColor = [UIColor colorWithHexString:@"#990000"];
    descriptionRequired.backgroundColor = [UIColor clearColor];
    descriptionRequired.text = @"Required";
    [self.descriptionCell addSubview:descriptionRequired];
    
    // price required label (only if in for sale category)
    if([self.mainCategory isEqualToString:@"For Sale"]) {
        priceRequired = [[UILabel alloc] initWithFrame:CGRectMake(250, 7, 50, 30)];
        priceRequired.font = [UIFont fontWithName:FONT_GLOBAL size:12];
        priceRequired.textColor = [UIColor colorWithHexString:@"#990000"];
        priceRequired.backgroundColor = [UIColor clearColor];
        priceRequired.text = @"Required";
        [self.priceCell addSubview:priceRequired];
        // build the price success label
        priceSuccessLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 7, 200, 30)];
        priceSuccessLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:16];
        priceSuccessLabel.textColor = [UIColor colorWithRed:(19.0 / 255.0) green:(122.0 / 255.0) blue:(188.0 / 255.0) alpha: 1];
        priceSuccessLabel.backgroundColor = [UIColor clearColor];
        priceSuccessLabel.textAlignment = NSTextAlignmentRight;
    }
    
    // create the success icon views for the cells
    titleSuccessImageView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 11, 20, 20)];
    titleSuccessImageView.image = [UIImage imageNamed:@"success-check"];
    descriptionSuccessImageView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 11, 20, 20)];
    descriptionSuccessImageView.image = [UIImage imageNamed:@"success-check"];
    locationSuccessImageView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 13, 20, 20)];
    locationSuccessImageView.image = [UIImage imageNamed:@"success-check"];
    tagsSuccessImageView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 11, 20, 20)];
    tagsSuccessImageView.image = [UIImage imageNamed:@"success-check"];
}

- (void) viewWillAppear:(BOOL)animated {
    BOOL validListing = TRUE;
    // remove the required labels and add the success icons where necessary
    if(self.listing.title != nil && ![self.listing.title isEqualToString:EMPTY_STRING]) {
        [titleRequired removeFromSuperview];
        [self.titleCell addSubview:titleSuccessImageView];
    } else {
        validListing = FALSE;
    }
    
    if(self.listing.listDescription != nil && ![self.listing.listDescription isEqualToString:EMPTY_STRING]) {
        [descriptionRequired removeFromSuperview];
        [self.descriptionCell addSubview:descriptionSuccessImageView];
    } else {
        validListing = FALSE;
    }
    
    if(self.listing.location != nil) {
        [self.locationCell addSubview:locationSuccessImageView];
    }
    if(self.listing.tags != nil && self.listing.tags.count > 0) {
        [self.tagsCell addSubview:tagsSuccessImageView];
    }
    if([self.mainCategory isEqualToString:@"For Sale"]) {
        if(self.listing.price > -37) {
            [priceRequired removeFromSuperview];
            NSNumber *price = [NSNumber numberWithDouble:self.listing.price];
            priceSuccessLabel.text = [price stringValue];
            [self.priceCell addSubview:priceSuccessLabel];
        } else {
            validListing = FALSE;
        }
    }
    // determine if the next button is enabled based on the validation
    self.nextButton.enabled = validListing;
}
- (UIView*)createSectionView:(NSString*)sectionText {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    view.backgroundColor = [UIColor clearColor];
    UILabel *sectionLabel = [[UILabel alloc] init];
    sectionLabel.frame = CGRectMake(10, 10, 320, 20);
    sectionLabel.textColor = [UIColor whiteColor];
    sectionLabel.font = [UIFont fontWithName:FONT_GLOBAL_BOLD size:15];
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.text = sectionText;
    [view addSubview:sectionLabel];
    return view;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_ADD_LISTING_TEXT_VIEW_CONTROLLER] ||
        [[segue identifier] isEqualToString:SEGUE_SHOW_ADD_LISTING_TEXT_VIEW_CONTROLLER_2] ||
        [[segue identifier] isEqualToString:SEGUE_SHOW_ADD_LISTING_TEXT_VIEW_CONTROLLER_3] ||
        [[segue identifier] isEqualToString:SEGUE_SHOW_ADD_LISTING_TEXT_VIEW_CONTROLLER_4])
    {
        UITableViewCell *cell = (UITableViewCell *)sender;
        AddListingTextViewController *addListingTextViewController = [segue destinationViewController];
        switch (cell.tag) {
            case 1:
                addListingTextViewController.mode = kAddListingTextModeTitle;
                break;
            case 2:
                addListingTextViewController.mode = kAddListingTextModeDescription;
                break;
            case 3:
                addListingTextViewController.mode = kAddListingTextModePrice;
                break;
            case 5: addListingTextViewController.mode = kAddListingTextModeTags;
                break;

        }
        addListingTextViewController.listing = self.listing;
    } else if ([[segue identifier] isEqualToString:SEGUE_SHOW_ADD_LISTING_LOCATION_VIEW_CONTROLLER]) {
        AddListingLocationViewController *addListingLocationViewController = [segue destinationViewController];
        addListingLocationViewController.listing = self.listing;

    } else if ([[segue identifier] isEqualToString:SEGUE_SHOW_ADD_LISTING_ADDON_VIEW_CONTROLLER]){
        AddListingAddOnViewController *addOnController = [segue destinationViewController];
        addOnController.listing = self.listing;
    } else if ([[segue identifier] isEqualToString:SEGUE_SHOW_ADD_LISTING_PHOTO_VIEW_CONTROLLER]){
        AddListingPhotoViewController *photoController = [segue destinationViewController];
        photoController.listing = self.listing;
    }
}

#pragma mark TableView delegate
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = [indexPath section];
    if(section == 0) {
        if([indexPath row] == 3) {
            // hide the price static cell if this is not a "for sale" category
            if(![self.mainCategory isEqualToString:@"For Sale"]) {
                cell.alpha = 0;
            }
        }
    }
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    if (section == 0) {
        view = [self createSectionView:@"Basic Information"];
    } else {
        view = [self createSectionView:@"Optional"];
    }
    return view;
}
#pragma mark -
#pragma mark TableView delegate
- (IBAction)nextClick:(id)sender {
}
#pragma mark -
@end
