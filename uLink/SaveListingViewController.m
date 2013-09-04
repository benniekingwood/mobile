//
//  SaveListingViewController.m
//  ulink
//
//  Created by Bennie Kingwood on 9/2/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//
// TODO: 1. have the forms for each of the types, and have the show/hide on cell selection
//       2. Make the delete cell click present confirm alert, then peform deletion, then return to mylistings view on success
//       3.  Add form validation 
#import "SaveListingViewController.h"
#import "AlertView.h"
#import "ColorConverterUtil.h"

@interface SaveListingViewController () {
    UIBarButtonItem *btnSave;
    AlertView *errorAlertView;
    float defaultCellHeight;
    BOOL listingHasPrice;
    NSIndexPath* previouslySelectedIndexPath;
}
-(UITableViewCell*) buildTitleDescriptionCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildPhotosListingCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildPriceListingCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildLocationListingCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildTagsListingCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildAddOnsListingCell:(UITableViewCell*)cell;
-(UITableViewCell*) buildDeleteListingCell:(UITableViewCell*)cell;
@end

@implementation SaveListingViewController
@synthesize saveMode;
@synthesize listing;
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
    // set the default cell height
    defaultCellHeight = 75;
    
    // set the view's title in the nav bar based on the save mode
    if(self.saveMode == kListingSaveTypeUpdate) {
        self.navigationItem.title = @"Edit Listing";
    } else {
        self.navigationItem.title = @"Add Listing";
    }
    
    // set the table view's background color to black
    self.view.backgroundColor = [UIColor blackColor];
    
    // determine if the listing has a price
    listingHasPrice = [self.listing.mainCategory isEqualToString:@"For Sale"];
    
    // remove the cell separators since we are going flat UI
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // add the "Save" button
    btnSave = [[UIBarButtonItem alloc]
               initWithTitle:@"Save"
               style:UIBarButtonItemStylePlain
               target:self
               action:@selector(saveClick)];
    self.navigationItem.rightBarButtonItem = btnSave;
    btnSave.enabled = FALSE;
    // TODO: initialize alert view ("bring over from AddListingTextViewController")
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Cell Buidling Functions
-(UITableViewCell*) buildTitleDescriptionCell:(UITableViewCell*)cell {
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#EDB232"];
    // add the text properties
    cell.textLabel.text = @"Title & Description";
    //[cell.textLabel.superview addSubview:bgColor];
    return cell;
}

-(UITableViewCell*) buildPhotosListingCell:(UITableViewCell*)cell {
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#1E98D9"];
    // add the text properties
    cell.textLabel.text = @"Photos";
    return cell;
}
-(UITableViewCell*) buildPriceListingCell:(UITableViewCell*)cell {
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#38A640"];
    // add the text properties
    cell.textLabel.text = @"Price";
    return cell;
}
-(UITableViewCell*) buildLocationListingCell:(UITableViewCell*)cell {
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#975FC2"];
    // add the text properties
    cell.textLabel.text = @"Location";
   return cell; 
}
-(UITableViewCell*) buildTagsListingCell:(UITableViewCell*)cell {
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#6B64B0"];
    // add the text properties
    cell.textLabel.text = @"Tags";
    return cell;
}

-(UITableViewCell*) buildAddOnsListingCell:(UITableViewCell*)cell {
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#99683D"];
    // add the text properties
    cell.textLabel.text = @"Add Ons";
    return cell;  
}

-(UITableViewCell*) buildDeleteListingCell:(UITableViewCell*)cell {
    // set the cell background color
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#990000"];
    // add the text properties
    cell.textLabel.text = @"Delete";
    return cell;
}
#pragma mark - 
#pragma mark - Table view data source
- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"heightForRowAtIndexPath");
    CGFloat retVal = defaultCellHeight;
    // grab the selected index path
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    // if the selected indexpath row is the previous row, then we need to expand this form cell
        // show the form for the selected cell
    if (selectedIndexPath.row == indexPath.row-1) {
        switch (indexPath.row) {
            case 1: retVal = 150.0;
                break;
        }
    } else {
        switch (indexPath.row) {
            case 1:
                retVal = 0;
                break;
        }
    }
    return retVal;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int retVal = 1;
    if (self.saveMode == kListingSaveTypeAdd) {
        if(listingHasPrice) {
            retVal = 8;
        } else {
            retVal = 7;
        }
    } else {
        if(listingHasPrice) {
            retVal = 7;
        } else {
            retVal = 6;
        }
    }
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    static NSString *CellIdentifier = CELL_LISTING_SAVE_CELL;
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.clipsToBounds = YES;
        cell.textLabel.font = [UIFont fontWithName:FONT_GLOBAL size:20.0f];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, defaultCellHeight);
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }
    // build the base rows
    switch (indexPath.row) {
        case 0:
            cell = [self buildTitleDescriptionCell:cell];
            break;
        case 1: cell = [self buildLocationListingCell:cell];
            break;
        case 2: cell = [self buildPhotosListingCell:cell];
            break;
        case 3: cell = [self buildLocationListingCell:cell];
            break;
        case 4: cell = [self buildTagsListingCell:cell];
            break;
    }
    // if we are in add mode we can build the "Add On" cell
    if(self.saveMode == kListingSaveTypeAdd) {
        if(listingHasPrice) {
            switch (indexPath.row) {
                // add the price cell if necessary
                case 5: cell = [self buildPriceListingCell:cell];
                    break;
                // add the add ons cell if necessary
                case 6: cell = [self buildAddOnsListingCell:cell];
                    break;
                // finally build the delete listing cell if necessary
                case 7: cell = [self buildDeleteListingCell:cell];
                    break;
            }
        } else {
            // add the add ons cell if necessary
            if(indexPath.row == 5) {
                cell = [self buildAddOnsListingCell:cell];
            }
            // finally build the delete listing cell if necessary
            if(indexPath.row == 6) {
                cell = [self buildDeleteListingCell:cell];
            }
        }
    } else {
        /* since we are just editing, we will not have the Add Ons here, only for when the user creates a new listing
         */
        if(listingHasPrice) {
            // add the price cell
            if(indexPath.row == 5) {
                cell = [self buildPriceListingCell:cell];
            }
            // finally build the delete listing cell if necessary
            if(indexPath.row == 6) {
                cell = [self buildDeleteListingCell:cell];
            }
        } else {
            // finally build the delete listing cell if necessary
            if(indexPath.row == 7) {
                cell = [self buildDeleteListingCell:cell];
            }
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell click.");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    /* TODO: based on the cell "tag" that was selected, we perform either: 
     * 1.  Toggle the cell size to show/hide the form in the cell
     * 2.  If delete cell was clicked, we then show the alert for the user to confirm the deletion
     */
    if(cell.tag == kListingSaveDeleteCell) {
        
    } else {
        if(![indexPath isEqual:previouslySelectedIndexPath]) {
            // simply toggle the size of the cell based on the cell type
            // we need these lines below to show the cell change animations, and to rebuild the tableview
            [self.tableView beginUpdates];
           /* if(previouslySelectedIndexPath != nil) {
                [self.tableView deleteRowsAtIndexPaths:@[previouslySelectedIndexPath,indexPath] withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView insertRowsAtIndexPaths:@[previouslySelectedIndexPath,indexPath] withRowAnimation:UITableViewRowAnimationTop];
            } else {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            }*/
            [self.tableView endUpdates];
            previouslySelectedIndexPath = indexPath;
        } else {
            
        }
       
    }
}
#pragma mark Actions
-(void) saveClick {
    NSLog(@"saving");
}
#pragma mark -
@end
