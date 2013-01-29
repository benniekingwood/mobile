//
//  SnapDetailViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/16/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SnapDetailViewController.h"
#import "AlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMacros.h"
#import "DataCache.h"
#import "SnapshotComment.h"
#import "ActivityIndicatorView.h"
#import "SuccessNotificationView.h"
#import "UserProfileButton.h"
#import "UserProfileViewController.h"
#import "SnapshotUtil.h"
#import "ImageActivityIndicatorView.h"
#import <SDWebImage/SDWebImageDownloader.h>

@interface SnapDetailViewController () {
    AlertView *customAlertView;
    AlertView *errorAlertView;
    NSString *defaultValidationMsg;
    ActivityIndicatorView *activityIndicator;
    SuccessNotificationView *successNotification;
    NSHashTable *validationErrors;
    UIView *commentForm;
    UIToolbar *commentToolbar;
    UITextField *commentTextField;
    float commentToolbarY;
    float commentFormY;
    NSDateFormatter *dateFormatter;
}
-(void)saveComment;
- (void)deleteSnap;
- (void) popController;
- (void) reloadComments;
- (void) viewUserProfileClick:(UserProfileButton*)sender;
@end
static NSString *kSnapCommentCellId = CELL_SNAP_COMMENT_CELL;
@implementation SnapDetailViewController
@synthesize inUCampusMode,deleteButton, snap, snapCaptionLabel, snapUserImageView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // build snap user image button
    UserProfileButton *snapUserImageButton = [UserProfileButton buttonWithType:UIButtonTypeCustom];
    [snapUserImageButton addTarget:self
                            action:@selector(viewUserProfileClick:)
                  forControlEvents:UIControlEventTouchDown];
    snapUserImageButton.frame = CGRectMake(15, 144, 40, 40);
    snapUserImageButton.user = self.snap.user;
    [snapUserImageButton initialize];
    [self.view addSubview:snapUserImageButton];
    if(inUCampusMode) {
        commentToolbarY = self.view.frame.size.height-94.0f;
        commentFormY = self.view.frame.size.height-84.0f;
        // hide the delete button
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
        
        // show the submit comments in toolbar
        commentToolbar = [[UIToolbar alloc] init];
        commentToolbar.barStyle = UIBarStyleBlackOpaque;
        [commentToolbar sizeToFit];
        commentToolbar.frame = CGRectMake(0, commentToolbarY, 320, 50);
        [self.view addSubview:commentToolbar];

        // create the comment text
        commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 6, 300, 30)];
        commentTextField.placeholder = @"Post Comment";
        commentTextField.font = [UIFont fontWithName:FONT_GLOBAL size:13.0f];
        commentTextField.textColor = [UIColor whiteColor];
        commentTextField.returnKeyType = UIReturnKeySend;
        commentTextField.delegate = self;
        commentTextField.tag = kTextFieldSnapComment;
        commentTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        [commentTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        commentForm = [[UIView alloc] init];
        commentForm.frame = CGRectMake(10, commentFormY, 300, 30);
        commentForm.backgroundColor = [UIColor blackColor];
        [commentForm.layer setBorderWidth:0.8f];
        [commentForm.layer setBorderColor:[[UIColor grayColor] CGColor]];
        commentForm.layer.cornerRadius = 5;
        [commentForm addSubview:commentTextField];
        validationErrors = [[NSHashTable alloc] init];
        [self.view addSubview:commentForm];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d, yyyy"];
    }
    
    [self.commentHeader setFont:[UIFont fontWithName:FONT_GLOBAL size:12.0f]];
    [self.commentHeader setShadowColor:[UIColor whiteColor]];
    [self.commentHeader setTextColor: [UIColor darkGrayColor]];
    [self.commentHeader setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    self.commentsTableView.layer.cornerRadius = 5;
    self.commentsTableView.layer.masksToBounds = YES;
    [self.commentsTableView.layer setBorderWidth:0.3f];
    [self.commentsTableView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    
    self.snapCaptionLabel.font = [UIFont fontWithName:FONT_GLOBAL size:11.0f];
    self.snapCaptionLabel.textColor = [UIColor whiteColor];
    self.snapCaptionLabel.numberOfLines = 4;
    self.snapCaptionLabel.textAlignment = NSTextAlignmentLeft;
    
    customAlertView = [[AlertView alloc] initWithTitle:@""
                                               message:@"Are you sure you would like delete this snap?  This action cannot be undone."
                                              delegate:self
                                     cancelButtonTitle:BTN_CANCEL
                                     otherButtonTitles:BTN_DELETE,nil];
    defaultValidationMsg = @"Please enter your comment.";
    errorAlertView = [[AlertView alloc] initWithTitle:@""
                                              message: defaultValidationMsg
                                             delegate:self
                                    cancelButtonTitle:BTN_OK
                                    otherButtonTitles:nil];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    successNotification = [[SuccessNotificationView alloc] init];
    self.snapImageView.layer.cornerRadius = 5;
    self.snapImageView.layer.masksToBounds = YES;
    self.snapUserImageView.layer.cornerRadius = 5;
    self.snapUserImageView.layer.masksToBounds = YES;
    [self applyUlinkTableFooter];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.snapImageView.image = self.snap.snapImage;
    // grab the snap image from the snap cache
    UIImage *snapImage = [UDataCache imageExists:self.snap.snapId cacheModel:IMAGE_CACHE_SNAP_MEDIUM];
    if (snapImage == nil) {
        if(self.snap.snapImageURL != nil) {
        // set the key in the cache to let other processes know that this key is in work
        [UDataCache.snapImageMedium setValue:[NSNull null]  forKey:self.snap.snapId];
        NSURL *url = [NSURL URLWithString:[URL_SNAP_IMAGE_MEDIUM stringByAppendingString:self.snap.snapImageURL]];
        __block ImageActivityIndicatorView *iActivityIndicator;
        SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
        [imageDownloader downloadImageWithURL:url
                                      options:SDWebImageDownloaderProgressiveDownload
                                     progress:^(NSUInteger receivedSize, long long expectedSize) {
                                         if (!iActivityIndicator)
                                         {
                                             iActivityIndicator = [[ImageActivityIndicatorView alloc] init];
                                             [iActivityIndicator showActivityIndicator:self.snapImageView];
                                         }
                                     }
                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                        if (image && finished)
                                        {
                                            // add the snap image to the image cache
                                            [UDataCache.snapImageMedium setValue:image forKey:self.snap.snapId];
                                            // set the picture in the view
                                            self.snapImageView.image = image;
                                            [iActivityIndicator hideActivityIndicator:self.snapImageView];
                                            iActivityIndicator = nil;
                                        }
                                    }];
        }
    } else if (![snapImage isKindOfClass:[NSNull class]]) {
       self.snapImageView.image  = snapImage;
    }

    self.snapCaptionLabel.text = self.snap.caption;
    // if there are no comments hide the comments table
    if([self.snap.snapComments count] == 0) {
        self.commentsTableView.alpha = ALPHA_ZERO;
        self.commentHeader.text = @"There are no comments for this snapshot";
    } else {
        self.commentHeader.text = [NSString stringWithFormat:@"%i Comments", [self.snap.snapComments count]];
    }
}

- (void) reloadComments {
    [self.commentsTableView reloadData];
    self.commentsTableView.alpha = ALPHA_HIGH;
}
- (void)applyUlinkTableFooter {
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 55)];
	footer.backgroundColor = [UIColor clearColor];
    UIImageView *shortLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(135, 5, 24, 56)];
    shortLogoImageView.image = [UIImage imageNamed:@"ulink_short_logo.png"];
    [footer addSubview:shortLogoImageView];
	self.commentsTableView.tableFooterView = footer;
}
- (void)viewUserProfileClick:(UserProfileButton*)sender {
    UserProfileViewController *viewProfileController = [self.storyboard instantiateViewControllerWithIdentifier:CONTROLLER_USER_PROFILE_VIEW_CONTROLLER_ID];
    viewProfileController.user = sender.user;
    [self.navigationController presentViewController:viewProfileController animated:YES completion:nil];
}
-(void)snapCommentUserClick:(User*)user {
    UserProfileViewController *viewProfileController = [self.storyboard instantiateViewControllerWithIdentifier:CONTROLLER_USER_PROFILE_VIEW_CONTROLLER_ID];
    viewProfileController.user = user;
    [self.navigationController presentViewController:viewProfileController animated:YES completion:nil];
}
#pragma mark - UITextField section
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL retVal = NO;
    if([string isEqualToString:@""]) {
        retVal = YES;
    } else {
        retVal = commentTextField.text.length < 140;
    }
    return retVal;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if ([commentTextField isFirstResponder] && [touch view] != commentTextField) {
        [commentTextField  resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self saveComment];
    [textField resignFirstResponder];
    return YES;
}
- (void)validateField:(int)tag {
    if (tag == kTextFieldSnapComment) {
        if (commentTextField.text.length < 1) {
            [validationErrors addObject:defaultValidationMsg];
        } else {
            [validationErrors removeObject:defaultValidationMsg];
        }
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.2
                          delay: 0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = commentForm.frame;
                         frame.origin.y = commentFormY;
                         commentForm.frame = frame;
                         CGRect frame1 = commentToolbar.frame;
                         frame1.origin.y = commentToolbarY;
                         commentToolbar.frame = frame1;
                     }
                     completion:nil];
    if(textField.tag == kTextFieldSnapComment) {
        [self validateField:kTextFieldSnapComment];
    }
}

- (void)textFieldDidBeginEditing:(UITextView *)textField {
    [UIView animateWithDuration:0.2
                          delay: 0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         CGRect frame = commentForm.frame;
                         frame.origin.y = commentFormY-215.0f;
                         commentForm.frame = frame;
                         CGRect frame1 = commentToolbar.frame;
                         frame1.origin.y = commentToolbarY-215.0f;
                         commentToolbar.frame = frame1;
                     }
                     completion:nil];

}
#pragma mark 
#pragma mark - UITableView section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.snap.snapComments count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SnapCommentCell *cell = (SnapCommentCell *)[self.commentsTableView dequeueReusableCellWithIdentifier:kSnapCommentCellId];
    
    if (cell == nil) {
        cell = [[SnapCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSnapCommentCellId] ;
    }
    
    cell.snapComment = [self.snap.snapComments objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell initialize];
    [cell layoutSubviews];
    return cell;
}
#pragma mark

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        [self deleteSnap];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) popController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showDeleteAlert:(UIBarButtonItem *)sender {
    [customAlertView show];
}
- (void)saveComment {
    @try {
        [self validateField:kTextFieldSnapComment];
        if([validationErrors count] > 0) {
            errorAlertView.message = @"";
            for (NSString *error in validationErrors) {
                errorAlertView.message = [errorAlertView.message stringByAppendingString:error];
            }
            [errorAlertView show];
            return;
        }
        [activityIndicator showActivityIndicator:self.view];
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t insertSnapCommentQueue = dispatch_queue_create(DISPATCH_INSERT_SNAP_COMMENT, NULL);
        dispatch_async(insertSnapCommentQueue, ^{
            NSString *requestData = [@"data[SnapshotComment][comment]=" stringByAppendingString:commentTextField.text];
            requestData = [requestData stringByAppendingString:[@"&data[SnapshotComment][snapId]=" stringByAppendingString:snap.snapId]];
            requestData = [requestData stringByAppendingString:[@"&data[userId]=" stringByAppendingString:UDataCache.sessionUser.userId]];
            requestData = [requestData stringByAppendingString:[@"&data[mobile_auth]=" stringByAppendingString:UDataCache.sessionUser.userId]];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_SNAPSHOTS_INSERT_COMMENT]]];
            [req setHTTPMethod:HTTP_POST];
            [req setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSThread sleepForTimeInterval:2];
                    [activityIndicator hideActivityIndicator:self.view];
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        NSString *response = (NSString*)[json objectForKey:JSON_KEY_RESPONSE];
                        
                        if([response isEqualToString:@"true"]) {
                            // create the SnapComment object and add it to the user cache
                            SnapshotComment *snapComment = [[SnapshotComment alloc] init];
                            snapComment.comment = commentTextField.text;
                            snapComment.created = [NSDate date];
                            snapComment.createdShort = [dateFormatter stringFromDate:snapComment.created];
                            snapComment.user = UDataCache.sessionUser;
                            if (self.snap.snapComments == nil) {
                                self.snap.snapComments = [[NSMutableArray alloc] init];
                            }
                            [self.snap.snapComments addObject:snapComment];
                            
                            // reload the table data
                            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reloadComments) userInfo:nil repeats:NO];
                           
                            [successNotification setMessage:@"Comment Submitted."];
                            [successNotification showNotification:self.view];
                            // update the number of comments label
                            self.commentHeader.text = [NSString stringWithFormat:@"%i Comments", [self.snap.snapComments count]];
                            commentTextField.text = @"";
                           
                        } else {
                            errorAlertView.message = @"There was a problem adding your comment.  Please try again later or contact help@theulink.com.";
                            [errorAlertView show];
                        }
                    } else {
                        errorAlertView.message = @"There was a problem adding your comment.  Please try again later or contact help@theulink.com.";
                        // show alert to user
                        [errorAlertView show];
                    }
               });
            }];
        });
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        // show alert to user
        [errorAlertView show];
    }
}
- (void)deleteSnap {
    @try {
        [activityIndicator showActivityIndicator:self.view];
        self.deleteButton.enabled = FALSE;
        // how we stop refresh from freezing the main UI thread
        dispatch_queue_t deleteSnapshotQueue = dispatch_queue_create(DISPATCH_DELETE_SNAP, NULL);
        dispatch_async(deleteSnapshotQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_SNAPSHOTS_DELETE_SNAPSHOT];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:snap.snapId];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.userId];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.userId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [activityIndicator hideActivityIndicator:self.view];
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        NSString *response = (NSString*)[json objectForKey:JSON_KEY_RESPONSE];
                        NSString* result = (NSString*)[json objectForKey:JSON_KEY_RESULT];
                        if([result isEqualToString:@"true"]) {
                            [successNotification setMessage:@"Snapshot Deleted."];
                            [successNotification showNotification:self.view];
                            // delete snapshot from the snap cache
                            [UDataCache.sessionUser.snaps removeObject:snap];
                            // remove the snap from the global snap cache
                            [USnapshotUtil removeSnap:snap];
                            // remove the old snap image
                            [UDataCache removeImage:snap.snapId cacheModel:IMAGE_CACHE_SNAP_MEDIUM];
                            [UDataCache removeImage:snap.snapId cacheModel:IMAGE_CACHE_SNAP_THUMBS];
                            // pop the controller
                            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(popController) userInfo:nil repeats:NO];
                        } else {
                            self.deleteButton.enabled = TRUE;
                            if (response != nil && [response isEqualToString:@""] ) {
                                errorAlertView.message = response;
                            } else {
                                errorAlertView.message = @"There was a problem deleting your snapshot.  Please try again later or contact help@theulink.com.";
                            }
                            [errorAlertView show];
                        }
                    } else {
                        self.deleteButton.enabled = TRUE;
                        errorAlertView.message = @"There was a problem deleting your snapshot.  Please try again later or contact help@theulink.com.";
                        // show alert to user
                        [errorAlertView show];
                    }
                });
            }];
        });
    }
    @catch (NSException *exception) {
        self.view.userInteractionEnabled = YES;
        self.deleteButton.enabled = TRUE;
        // show alert to user
        [errorAlertView show];
    }
}
@end
