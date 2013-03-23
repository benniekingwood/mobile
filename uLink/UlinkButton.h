//
//  UlinkButton.h
//  uLink
//
//  Created by Bennie Kingwood on 11/14/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppMacros.h"

@interface UlinkButton : UIButton
- (void) createOrangeButton:(UlinkButton*)btn;
- (void) createBlueButton:(UlinkButton*)btn;
- (void) createRedButton:(UlinkButton*)btn;
- (void) createDefaultButton:(UlinkButton*)btn;
- (void) createDefaultSmallButton:(UlinkButton*)btn;
- (void) createOrangeSmallButton:(UlinkButton*)btn;
- (void) createFlatBlackButton:(UlinkButton*)btn;
@end
