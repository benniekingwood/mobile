//
//  CampusEventsViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/26/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "CampusEventsViewController.h"
#import "EventCell.h"
#import <QuartzCore/QuartzCore.h>
#import "EventDetailViewController.h"
#import "UserProfileViewController.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "UserProfileButton.h"
#import "AlertView.h"
@interface CampusEventsViewController () {
    UIScrollView *featuredEventScroll;
}
- (void) applyUlinkTableFooter;
- (void) buildFeaturedEventViews;
- (void) viewUserProfileClick:(UserProfileButton*)sender;
- (void) showEventDetail:(UIButton*)sender;
@end

@implementation CampusEventsViewController
static NSString *kUpcomingEventCellId = CELL_EVENT_CELL;
@synthesize upcomingHeader,eventsTableView, featuredEventsHeader;
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
    featuredEventScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,28,320,146)];
    featuredEventScroll.delegate = self;
    featuredEventScroll.pagingEnabled = YES;
    featuredEventScroll.showsHorizontalScrollIndicator = NO;
    featuredEventScroll.userInteractionEnabled = YES;
    
    [self.upcomingHeader setText:@"Upcoming Events"];
    [self.upcomingHeader setFont:[UIFont fontWithName:FONT_GLOBAL size:12.0f]];
    [self.upcomingHeader setShadowColor:[UIColor whiteColor]];
    [self.upcomingHeader setTextColor: [UIColor darkGrayColor]];
    [self.upcomingHeader setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    self.eventsTableView.dataSource = self;
    self.eventsTableView.delegate = self;
    self.eventsTableView.layer.cornerRadius = 5;
    self.eventsTableView.layer.masksToBounds = YES;
    [self.eventsTableView.layer setBorderWidth:0.5f];
    [self.eventsTableView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self applyUlinkTableFooter];
    
    UIAlertView *noEventsAlert = [[AlertView alloc] initWithTitle:@""
                                              message: @"There are no scheduled upcoming events for your school."
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    if([UDataCache.events count] == 0 && [UDataCache.featuredEvents count] == 0) {
        [noEventsAlert show];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
      self.featuredEventsHeader.text = [UDataCache.sessionUser.schoolName stringByAppendingFormat:@" %@", @"Featured Events"];
    [self buildFeaturedEventViews];
    [self.eventsTableView reloadData];
    // TODO: have automatic scrolling of featured events
}

- (void)applyUlinkTableFooter {
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 55)];
	footer.backgroundColor = [UIColor clearColor];
    UIImageView *shortLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(135, 5, 24, 56)];
    shortLogoImageView.image = [UIImage imageNamed:@"ulink_short_logo.png"];
    [footer addSubview:shortLogoImageView];
	self.eventsTableView.tableFooterView = footer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) buildFeaturedEventViews {
    [featuredEventScroll removeFromSuperview];
    self.pageControl.numberOfPages = 0;
    float currentX = 0;
    // create the main view for the featured events
    UIView *featuredEventsView = [[UIView alloc] initWithFrame:CGRectMake(currentX, 0, featuredEventScroll.frame.size.width, 146)];
    featuredEventsView.backgroundColor = [UIColor clearColor];
    featuredEventsView.userInteractionEnabled = YES;
    
    if ([UDataCache.featuredEvents count] == 0) {
        UIImageView *dummyFeatureView = [[UIImageView alloc] init];
        dummyFeatureView.frame = CGRectMake(currentX, 0, featuredEventScroll.frame.size.width, featuredEventScroll.frame.size.height);
        dummyFeatureView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URL_DEFAULT_FEATURED_EVENT_IMAGE]]];
        dummyFeatureView.contentMode = UIViewContentModeScaleAspectFill;
        [featuredEventsView addSubview:dummyFeatureView];
    } else {
        // iterate over each featured event in the cache
        for (int idx = 0; idx < [UDataCache.featuredEvents count]; idx++) {
            Event *featuredEvent = ((Event*)[UDataCache.featuredEvents objectAtIndex:idx]);
            // build event image button
            UIButton *eventImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [eventImageButton addTarget:self
                                     action:@selector(showEventDetail:)
                           forControlEvents:UIControlEventTouchDown];
            eventImageButton.frame = CGRectMake(currentX, 0, featuredEventScroll.frame.size.width, featuredEventScroll.frame.size.height);
            [eventImageButton setImage:featuredEvent.image forState:UIControlStateNormal];
            eventImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            eventImageButton.userInteractionEnabled = YES;
            eventImageButton.tag = idx;
            [featuredEventsView addSubview:eventImageButton];
            
            // build black label background
            UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(currentX, 95, featuredEventScroll.frame.size.width, 51)];
            footerLabel.backgroundColor = [UIColor blackColor];
            footerLabel.alpha = ALPHA_MED;
            [featuredEventsView addSubview:footerLabel];
            
            // add event title label
            UILabel *eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(currentX+58, 100, 243, 40)];
            eventTitle.font = [UIFont fontWithName:FONT_GLOBAL size:16.0];
            eventTitle.numberOfLines = 2;
            eventTitle.textAlignment = NSTextAlignmentLeft;
            eventTitle.textColor = [UIColor whiteColor];
            eventTitle.backgroundColor = [UIColor clearColor];
            eventTitle.text = featuredEvent.title;
            [featuredEventsView addSubview:eventTitle]; 
            
            // build user image button
            UserProfileButton *eventUserImageButton = [UserProfileButton buttonWithType:UIButtonTypeCustom];
            [eventUserImageButton addTarget:self
                                     action:@selector(viewUserProfileClick:)
             forControlEvents:UIControlEventTouchDown];
            eventUserImageButton.frame = CGRectMake(currentX+10, 101, 40, 40);
            eventUserImageButton.user = featuredEvent.user;
            [eventUserImageButton initialize];
            [featuredEventsView addSubview:eventUserImageButton];
            

            // increment currentX
            currentX += 320;
            
            // increment number of pages
            self.pageControl.numberOfPages++;
        }
    }
    CGRect frame = featuredEventsView.frame;
    frame.size.width = featuredEventScroll.frame.size.width*self.pageControl.numberOfPages;
    featuredEventsView.frame = frame;
    // add the featured events to scroll view
    [featuredEventScroll addSubview:featuredEventsView];
    // set this to be 320 x number of pages
    featuredEventScroll.contentSize = CGSizeMake(320*self.pageControl.numberOfPages, 146);
    // We want the view to be on top every time the it is shown
    [featuredEventScroll setContentOffset:CGPointMake(0,0) animated:NO];
    
    self.pageControl.currentPage = 0;
    if(self.pageControl.numberOfPages == 1) {
        self.pageControl.alpha = ALPHA_ZERO;
    } else {
        self.pageControl.alpha = ALPHA_HIGH;
    }
    
    // add the scroll view to the main view
    [self.view addSubview:featuredEventScroll];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:SEGUE_SHOW_EVENT_DETAIL_VIEW_CONTROLLER]) {
        if ([sender isKindOfClass:[UIButton class]]) {
            EventDetailViewController *detailViewController = [segue destinationViewController];
            detailViewController.event = [UDataCache.featuredEvents objectAtIndex:((UIButton*)sender).tag];
        } else {
            EventCell *cell = (EventCell *)sender;
            EventDetailViewController *detailViewController = [segue destinationViewController];
            detailViewController.event = cell.event;
        }
    }
}

- (void) showEventDetail:(UIButton *)sender {
     [self performSegueWithIdentifier:SEGUE_SHOW_EVENT_DETAIL_VIEW_CONTROLLER sender:sender];
}

#pragma mark - UITableView section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [UDataCache.events count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = (EventCell *)[self.eventsTableView dequeueReusableCellWithIdentifier:kUpcomingEventCellId];
    
    if (cell == nil) {
        cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUpcomingEventCellId] ;
    }
    cell.event = [UDataCache.events objectAtIndex:indexPath.item];
    [cell initialize];
    return cell;
}
#pragma mark

- (void)viewUserProfileClick:(UserProfileButton*)sender {
    UserProfileViewController *viewProfileController = [self.storyboard instantiateViewControllerWithIdentifier:CONTROLLER_USER_PROFILE_VIEW_CONTROLLER_ID];
    viewProfileController.user = sender.user;
    [self.navigationController presentViewController:viewProfileController animated:YES completion:nil];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = featuredEventScroll.frame.size.width;
    int page = floor((featuredEventScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
}
- (IBAction)changePage:(id)sender {
    int page = self.pageControl.currentPage;
    CGRect frame = featuredEventScroll.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [featuredEventScroll scrollRectToVisible:frame animated:YES];
}
@end
