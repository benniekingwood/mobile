//
//  AppMacros
//  uLink
//
//  Created by Bennie Kingwood on 11/13/12.
//  Copyright 2012 uLink, Inc. All rights reserved.
//

// Defined Functions
#pragma mark FUNCTIONS
#define RANDOM_SEED() srandom(time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))

#pragma mark MISC CONSTANTS
#define SLEEP_TIME_LOGIN 0
#define SLEEP_TIME_APP_LOAD 1.5
#define SLEEP_TIME_QUERY 1.0
#define AUTO_SCROLL_EVENT_TIME 6
#define AUTO_SCROLL_UCAMPUS_HOME_TIME 7
#define IMAGE_MAX_CONCURRENT_DOWNLOADS 5
#define IMAGE_MAX_FILE_SIZE 600
#define ULIST_LISTING_BATCH_SIZE 10
#define MIN_RETRIES 3
#define EMPTY_STRING @""
#define REFRESH_HEADER_HEIGHT 52.0f
#define VERSION_NUMBER @"0.2.7"

#pragma mark APPEARANCE CONSTANTS
#define ALPHA_HIGH 1.00
#define ALPHA_MED_HIGH 0.8
#define ALPHA_MED 0.6
#define ALPHA_LOW 0.2
#define ALPHA_ZERO 0.00

#pragma mark DEV_URLS
#define URL_SERVER_3737 @"http://localhost:3737/"
#define URL_SERVER @"http://localhost:8888/"
#define URL_USER_IMAGE_THUMB @"http://localhost:8888/img/files/users/thumbs/"
#define URL_USER_IMAGE_MEDIUM @"http://localhost:8888/img/files/users/medium/"
#define URL_DEFAULT_USER_IMAGE @"http://localhost:8888/img/defaults/default_user.jpg"
#define URL_SNAP_IMAGE_THUMB @"http://localhost:8888/img/files/snaps/thumbs/"
#define URL_SNAP_IMAGE_MEDIUM @"http://localhost:8888/img/files/snaps/medium/"
#define URL_DEFAULT_SNAP_IMAGE @"http://localhost:8888/img/defaults/default_snap.png"
#define URL_EVENT_IMAGE_THUMB @"http://localhost:8888/img/files/events/thumbs/"
#define URL_EVENT_IMAGE_MEDIUM @"http://localhost:8888/img/files/events/medium/"
#define URL_DEFAULT_EVENT_IMAGE @"http://localhost:8888/img/defaults/default_campus_event.png"
#define URL_DEFAULT_FEATURED_EVENT_IMAGE @"http://localhost:8888/img/defaults/default_featured_event.png"
#define URL_SCHOOL_IMAGE @"http://localhost:8888/img/files/schools/"
/*
#pragma mark PROD_URLS
#define URL_SERVER @"http://www.theulink.com/"
#define URL_USER_IMAGE_THUMB @"https://s3.amazonaws.com/ulink_images/img/files/users/thumbs/"
#define URL_USER_IMAGE_MEDIUM @"https://s3.amazonaws.com/ulink_images/img/files/users/medium/"
#define URL_DEFAULT_USER_IMAGE @"http://www.theulink.com/img/defaults/default_user.jpg"
#define URL_SNAP_IMAGE_THUMB @"https://s3.amazonaws.com/ulink_images/img/img/files/snaps/thumbs/"
#define URL_SNAP_IMAGE_MEDIUM @"https://s3.amazonaws.com/ulink_images/img/files/snaps/medium/"
#define URL_DEFAULT_SNAP_IMAGE @"http://www.theulink.com/img/defaults/default_snap.png"
#define URL_EVENT_IMAGE_THUMB @"https://s3.amazonaws.com/ulink_images/img/files/events/thumbs/"
#define URL_EVENT_IMAGE_MEDIUM @"https://s3.amazonaws.com/ulink_images/img/files/events/medium/"
#define URL_DEFAULT_EVENT_IMAGE @"http://www.theulink.com/img/defaults/default_campus_event.png"
#define URL_DEFAULT_FEATURED_EVENT_IMAGE @"http://www.theulink.com/img/defaults/default_featured_event.png"
#define URL_SCHOOL_IMAGE @"https://s3.amazonaws.com/ulink_images/img/files/schools/"
*/
#pragma mark IMAGE CACHE KEYS
#define KEY_DEFAULT_USER_IMAGE @"KEY_DEFAULT_USER_IMAGE"
#define KEY_DEFAULT_SNAP_IMAGE @"KEY_DEFAULT_SNAP_IMAGE"
#define KEY_DEFAULT_EVENT_IMAGE @"KEY_DEFAULT_EVENT_IMAGE"
#define KEY_DEFAULT_FEATURED_EVENT_IMAGE @"KEY_DEFAULT_FEATURED_EVENT_IMAGE"
#define KEY_SESSION_USER_SCHOOL @"KEY_SESSION_USER_SCHOOL"
#define IMAGE_CACHE_EVENT_THUMBS @"IMAGE_CACHE_EVENT_THUMBS"
#define IMAGE_CACHE_SNAP_THUMBS @"IMAGE_CACHE_SNAP_THUMBS"
#define IMAGE_CACHE_USER_THUMBS @"IMAGE_CACHE_USER_THUMBS"
#define IMAGE_CACHE_EVENT_MEDIUM @"IMAGE_CACHE_EVENT_MEDIUM"
#define IMAGE_CACHE_SNAP_MEDIUM @"IMAGE_CACHE_SNAP_MEDIUM"
#define IMAGE_CACHE_USER_MEDIUM @"IMAGE_CACHE_USER_MEDIUM"
#define IMAGE_CACHE_TWEET_PROFILE @"IMAGE_CACHE_TWEET_PROFILE"
#define IMAGE_CACHE @"IMAGE_CACHE_SCHOOL"

#pragma mark API FUNCTIONS
#define API_SCHOOLS_SUGGESTION @"schools/suggestion"
#define API_SCHOOLS_SCHOOL @"schools/school"
#define API_ULIST_CATEGORIES @"api/categories/"
#define API_ULIST_LISTINGS @"api/listings/"
#define API_USERS_RESET_PASSWORD @"users/reset_password"
#define API_USERS_SIGN_UP @"users/sign_up"
#define API_USERS_LOG_IN @"users/login"
#define API_USERS_USER @"users/user"
#define API_USERS_UPDATE_PASSWORD @"users/update_password"
#define API_USERS_UPDATE_SOCIAL @"users/update_social"
#define API_USERS_UPDATE_USER @"users/update_user"
#define API_SNAPSHOTS_INSERT_COMMENT @"snapshots/insert_snap_comment"
#define API_SNAPSHOTS_DELETE_SNAPSHOT @"snapshots/delete_snapshot"
#define API_SNAPSHOTS_DELETE_SNAPSHOT_COMMENT @"snapshots/delete_snap_comment"
#define API_SNAPSHOTS_INSERT_SNAPSHOT @"snapshots/insert_snap"
#define API_SNAPSHOTS_SNAP_CATEGORIES @"snapshots/snap_categories"
#define API_SNAPSHOTS_SNAPS @"snapshots/snaps"
#define API_UCAMPUS_TRENDS @"ucampus/trends"
#define API_UCAMPUS_TWEETS @"ucampus/tweets"
#define API_EVENTS_INSERT_EVENT @"events/insert_event"
#define API_EVENTS_DELETE_EVENT @"events/delete_event"
#define API_EVENTS_UPDATE_EVENT @"events/update_event"
#define API_EVENTS_EVENTS @"events/events"
#define API_FLAGS_INSERT_FLAG @"flags/insert_flag"

#pragma mark HTTP 
#define HTTP_POST @"POST"
#define HTTP_GET @"GET"

#pragma mark JSON
#define JSON_KEY_RESULT @"result"
#define JSON_KEY_RESPONSE @"response"

#pragma mark DISPATCH QUEUES
#define DISPATCH_SUGGESTION "suggestion"
#define DISPATCH_RESETPASSWORD "reset_password"
#define DISPATCH_SIGNUP "sign_up"
#define DISPATCH_SCHOOL "school"
#define DISPATCH_ULIST_CATEGORY "ulist_category"
#define DISPATCH_ULIST_LISTING "ulist_listing"
#define DISPATCH_MY_LISTING "my_listing"
#define DISPATCH_LOGIN "log_in"
#define DISPATCH_UPDATE_PASSWORD "update_password"
#define DISPATCH_UPDATE_USER "update_user"
#define DISPATCH_UPDATE_SOCIAL "update_social"
#define DISPATCH_INSERT_SNAP_COMMENT "insert_snap_comment"
#define DISPATCH_INSERT_SNAP "insert_snap"
#define DISPATCH_DELETE_SNAP_COMMENT "delete_snap_comment"
#define DISPATCH_DELETE_SNAP "delete_snap"
#define DISPATCH_SNAPSHOT_CATEGORIES "snap_categories"
#define DISPATCH_SNAPS "snaps"
#define DISPATCH_TRENDS "trends"
#define DISPATCH_TWEETS "tweets"
#define DISPATCH_ULINK_GLOBAL "ulink_global"
#define DISPATCH_EVENTS "events"
#define DISPATCH_UPDATE_EVENT "update_event"
#define DISPATCH_DELETE_EVENT "delete_event"
#define DISPATCH_INSERT_EVENT "insert_event"
#define DISPATCH_USER "user"

#pragma mark FONT MACROS
#define FONT_GLOBAL @"HelveticaNeue-Light"
#define FONT_GLOBAL_BOLD @"HelveticaNeue-Bold"
#pragma mark LOCALES
#define LOCALE_EN_US [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]

#define TABLE COLLECTION VIEW CELL IDS
#define CELL_SELECT_SCHOOL_CELL @"selectSchoolCell"
#define CELL_VERSION_CELL @"versionCell"
#define CELL_SETTINGS @"settingsCell"
#define CELL_HELP_CELL  @"khelpCell"
#define CELL_SNAP_CELL @"snapcell"
#define CELL_MY_SNAP_CELL @"mySnapCell"
#define CELL_MY_EVENT_CELL @"myEventCell"
#define CELL_MY_LISTING_CELL @"myListingCell"
#define CELL_EVENT_CELL @"eventCell"
#define CELL_SNAP_COMMENT_CELL @"snapCommentCell"
#define CELL_SNAP_CATEGORY @"snapCategoryCell"
#define CELL_TWEET @"tweetCell"
#define CELL_SELECT_ULIST_MAP @"selectUListMapCell"
#define CELL_SELECT_ULIST_LISTING_CELL @"selectUListListingCell"


#pragma mark CONTROLLER IDS
#define CONTROLLER_SELECT_SCHOOL_VIEW_CONTROLLER_ID @"SelectSchoolViewController"
#define CONTROLLER_MAIN_NAVIGATION_CONTROLLER_ID @"MainNavigationViewController"
#define CONTROLLER_PROFILE_VIEW_CONTROLLER_ID @"ProfileViewController"
#define CONTROLLER_PROFILE_PICTURE_VIEW_CONTROLLER_ID @"ProfilePictureViewController"
#define CONTROLLER_USER_PROFILE_VIEW_CONTROLLER_ID @"UserProfileViewController"
#define CONTROLLER_LOGIN_VIEW_CONTROLLER_ID @"LoginViewController"
#define CONTROLLER_TERMS_VIEW_CONTROLLER_ID @"TermsViewController"

#pragma mark SEQUES
#define SEGUE_SHOW_SIGN_UP_VIEW_CONTROLLER @"ShowSignUpViewController"
#define SEGUE_SHOW_SUGGEST_SCHOOL_VIEW_CONTROLLER @"ShowSuggestSchoolViewController"
#define SEGUE_SHOW_MAIN_TAB_BAR_VIEW_CONTROLLER @"ShowMainTabBarViewController"
#define SEGUE_SHOW_PASSWORD_VIEW_CONTROLLER @"ShowPasswordViewController"
#define SEGUE_SHOW_ABOUT_VIEW_CONTROLLER @"ShowAboutViewController"
#define SEGUE_SHOW_HELP_VIEW_CONTROLLER @"ShowHelpViewController"
#define SEGUE_SHOW_TERMS_VIEW_CONTROLLER @"ShowTermsViewController"
#define SEGUE_SHOW_SIGNUP_LOGIN_HELP_VIEW_CONTROLLER @"ShowSignupLoginHelpViewController"
#define SEGUE_SHOW_MYPROFILE_ACCOUNT_HELP_VIEW_CONTROLLER @"ShowMyProfileAccountHelpViewController"
#define SEGUE_SHOW_UCAMPUS_HELP_VIEW_CONROLLER @"ShowUCampusHelpViewController"
#define SEGUE_SHOW_SNAP_DETAIL_VIEW_CONTROLLER @"ShowSnapDetailViewController"
#define SEGUE_SHOW_SETTINGS_VIEW_CONTROLLER @"ShowSettingsViewController"
#define SEGUE_SHOW_EDIT_PROFILE_VIEW_CONTROLLER @"ShowEditProfileViewController"
#define SEGUE_SHOW_SNAPSHOTS_CATEGORY_VIEW_CONTROLLER @"ShowSnapshotsCategoryViewController"
#define SEGUE_SHOW_EDIT_EVENT_VIEW_CONTROLLER @"ShowEditEventViewController"
#define SEGUE_SHOW_EVENT_DETAIL_VIEW_CONTROLLER @"ShowEventDetailViewController"
#define SEGUE_SHOW_CAMPUS_EVENTS_VIEW_CONTROLLER @"ShowCampusEventsViewController"
#define SEGUE_SHOW_SOCIAL_VIEW_CONTROLLER @"ShowSocialViewController"
#define SEGUE_SHOW_SNAPSHOTS_VIEW_CONTROLLER @"ShowSnapshotsViewController"
#define SEGUE_SHOW_ULIST_SCHOOL_HOME_VIEW_CONTROLLER @"ShowUListSchoolHomeViewController"
#define SEGUE_SHOW_ULIST_SCHOOL_LISTINGS_VIEW_CONTROLLER @"ShowUListSchoolListingsViewController"

#pragma mark NOTIFICATIONS
#define NOTIFICATION_PROFILE_VIEW_CONTROLLER @"NOTIFICATION_PROFILE_VIEW_CONTROLLER"
#define NOTIFICATION_UCAMPUS_VIEW_CONTROLLER @"NOTIFICATION_UCAMPUS_VIEW_CONTROLLER"

#pragma mark BUTTONS
#define BTN_SUGGEST_HERE @"Suggest Here"
#define BTN_OK @"Ok"
#define BTN_CANCEL @"Cancel"
#define BTN_DELETE @"Delete"
#define BTN_TAKE_PHOTO @"Take photo..."
#define BTN_CHOOSE_PHOTO @"Choose photo from library..."
#define BTN_REPORT_INAPPROPRIATE @"Report Inappropriate"

#pragma mark STRINGS
#define SCHOOL_STATUS_CURRENT_STUDENT @"Current Student"
#define SCHOOL_STATUS_ALUMNI @"Alumni"
#define LOGIN_SUCCESS @"yes"
#define LOGIN_AUTOPASS @"auto"
#define LOGIN_INACTIVE @"std"

#pragma mark MISC KEYS
#define KEY_CACHE_AGE @"KEY_CACHE_AGE"

#pragma mark ALERTS
#define ALERT_NO_INTERNET_CONN @"There is no internet connection.  You will need to have a connection in order to access recent data."

#pragma mark QUERY_PARAMS

#pragma mark TEXTFIELDS
typedef enum {
    kTextFieldUsername = 0,
    kTextFieldPassword,
    kTextFieldNewPassword,
    kTextFieldVerifyPassword,
    kTextFieldEmail,
    kTextFieldSchoolStatus,
    kTextFieldFirstname,
    kTextFieldLastname,
    kTextFieldBio,
    kTextFieldYear,
    kTextFieldTwitterUsername,
    kTextFieldSnapComment,
    kTextFieldEventTitle,
    kTextFieldEventLocation,
    kTextFieldEventTime,
    kTextFieldEventDate,
    kTextFieldSnapCategory
} TextFieldTypes;

#pragma mark TEXTVIEWS
typedef enum {
    kTextViewBio = 100,
    kTextViewEventInfo,
    kTextViewSnapCaption
} TextViewTypes;

#pragma mark BUTTON TAGS    
typedef enum {
    kButtonTakePhoto = 200,
    kButtonChoosePhoto
} ButtonTags;

#pragma mark EVENT HYDRATION TYPE
typedef enum {
    kEventHydrationRegular = 300,
    kEventHydrationFeatured,
    kEventHydrationAll
} EventHydrationType;
