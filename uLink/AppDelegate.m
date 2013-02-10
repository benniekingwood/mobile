//
//  AppDelegate.m
//  uLink
//
//  Created by Bennie Kingwood on 11/7/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MFSideMenu.h"
#import "UCampusMenuViewController.h"
#import "RootViewController.h"
#import "DataCache.h"
#import "AppMacros.h"
#import "MainTabBarViewController.h"
#import "ActivityIndicatorView.h"
#import "AlertView.h"
#import "Reachability.h"
#import "UCampusViewController.h"
#import <SDWebImage/SDWebImageDownloader.h>

@implementation AppDelegate {
    UIStoryboard* storyboard;
    UCampusMenuViewController *sideMenuController;
    ActivityIndicatorView *activityIndicator;
    AlertView *appDelegateAlert;
}
@synthesize window = _window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    storyboard = [UIStoryboard storyboardWithName:@"uLink" bundle:nil];
    [self setupNavigationControllerApp];
    activityIndicator = [[ActivityIndicatorView alloc] init];
    appDelegateAlert = [[AlertView alloc] initWithTitle:@""
                             message: ALERT_NO_INTERNET_CONN
                            delegate:self
                   cancelButtonTitle:BTN_OK
                   otherButtonTitles:nil];
    SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
    imageDownloader.maxConcurrentDownloads = IMAGE_MAX_CONCURRENT_DOWNLOADS;
    return YES;
}

- (MFSideMenu *)createSideMenu {
    sideMenuController = [[UCampusMenuViewController alloc] init];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:CONTROLLER_MAIN_NAVIGATION_CONTROLLER_ID];
    MFSideMenuOptions options = MFSideMenuOptionMenuButtonEnabled
    |MFSideMenuOptionShadowEnabled;
    MFSideMenuPanMode panMode = MFSideMenuPanModeNavigationBar | MFSideMenuPanModeNavigationController;
    
    MFSideMenu *sideMenu = [MFSideMenu menuWithNavigationController:navigationController
                                                 sideMenuController:sideMenuController
                                                           location:MFSideMenuLocationLeft
                                                            options:options
                                                            panMode:panMode];
    [sideMenu setSideMenuEnabled:NO];
    sideMenuController.sideMenu = sideMenu;
    return sideMenu;
}

- (void) setupNavigationControllerApp {
    self.window.rootViewController = [self createSideMenu].navigationController;
    [self.window makeKeyAndVisible];
}

-(void)activateUCampusSideMenu {
    self.window.rootViewController.navigationController.navigationItem.title = @"uCampus";
    [sideMenuController.sideMenu setSideMenuEnabled:YES];
    [sideMenuController.sideMenu showOptionsButton];
    [((UCampusMenuViewController*)sideMenuController.sideMenu.sideMenuController) showMenu];
}
-(void)deactivateUCampusSideMenu  {
    [sideMenuController.sideMenu setSideMenuEnabled:NO];
    [sideMenuController.sideMenu hideOptionsButton];
    [((UCampusMenuViewController*)sideMenuController.sideMenu.sideMenuController) hideMenu];

}
-(UITabBarController*)getMainTabBarViewController {
    return [[sideMenuController.sideMenu.navigationController viewControllers] objectAtIndex:2];
}
-(void) showActivityIndicator {
    /*
     * NOTE: keeping commented out for now.  The main indicator
     * is not functioning correctly so we will not show it when
     * user's reopen our application.
     */
  /*  MainTabBarViewController *mainTabBarController = [[((MainNavigationViewController*)self.window.rootViewController) viewControllers] objectAtIndex:2];

    self.window.rootViewController.view.userInteractionEnabled = NO;
    [[self.window.rootViewController.view subviews] makeObjectsPerformSelector:@selector(setUserInteractionEnabled:) withObject:[NSNumber numberWithBool:FALSE]];
    [activityIndicator showActivityIndicator:mainTabBarController.selectedViewController.view];*/
}
-(void) hideActivityIndicator {
   /* MainTabBarViewController *mainTabBarController = [[((MainNavigationViewController*)self.window.rootViewController) viewControllers] objectAtIndex:2];
       [[self.window subviews]makeObjectsPerformSelector:@selector(setUserInteractionEnabled:) withObject:[NSNumber numberWithBool:TRUE]];
    [activityIndicator hideActivityIndicator:mainTabBarController.selectedViewController.view]; */
}

- (void) hydrateImages {
    [UDataCache rehydrateImageCache:YES];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //NSLog(@"applicationDidEnterBackground");
    // TODO: if there are rehyrdations going, we need to kill those process and decrement the active
    // processes to zero
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // NSLog(@"applicationWillEnterForeground");
    BOOL networkActive = FALSE;
    // check for network connectivity
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    networkActive = (networkStatus != NotReachable);
    
    // if there is network connectivity, we can continue
    if(UDataCache.sessionUser != nil && networkActive) {
        //NSLog(@"rehyrdating caches");
   
        // pop to main tab bar view controller
        MainTabBarViewController *mainTabBarController = [[((MainNavigationViewController*)self.window.rootViewController) viewControllers] objectAtIndex:2];
        
        // If it's not the main bar controller, clear caches and pop back to the root view controller
        if(![mainTabBarController isKindOfClass:[MainTabBarViewController class]]) {
            // clear all cache data
            [UDataCache clearCache];
            // remove the school image, NOTE: this can probably be removed once we add a schoolImage cache
            [UDataCache removeImage:KEY_SESSION_USER_SCHOOL cacheModel:IMAGE_CACHE];
        } else {
            // always default the the ucampus home
            [mainTabBarController setSelectedIndex:0];
            [((MainNavigationViewController*)self.window.rootViewController) popToViewController:mainTabBarController animated:NO];
            [UDataCache rehydrateCaches:YES];
        }
    } else if (networkActive) {
        // we know that we have a network connection, but no user so just rehydrate the schools cache
        [UDataCache rehydrateSchoolCache:YES];
        [self performSelectorInBackground:@selector(hydrateImages) withObject:self];
        [UDataCache hydrateSnapshotCategoriesCache:NO];
    }

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   // NSLog(@"applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    BOOL networkActive = FALSE;
    // check for network connectivity
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    networkActive = (networkStatus != NotReachable);
    if(!networkActive) {
        [appDelegateAlert show];
    }
    
   if (UDataCache.sessionUser == nil && networkActive) {
        // we know that we have a network connection, but no user so just rehydrate the schools cache
        [UDataCache rehydrateSchoolCache:NO];
        [self performSelectorInBackground:@selector(hydrateImages) withObject:self];
        [UDataCache hydrateSnapshotCategoriesCache:NO];
       
       // pop back to the login screen
       [((MainNavigationViewController*)self.window.rootViewController) popToRootViewControllerAnimated:NO];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
