//
//  DataLoader.h
//  ulink
//
//  Created by Christopher Cerwinski on 5/14/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// Import view controllers using data loader
#import "UListSchoolCategoryViewController.h"

@interface DataLoader : NSObject

// create a new delegate and method for each view controller
// utilizing data loader
@property (strong, nonatomic) UListSchoolCategoryViewController *uListDelegate;
- (void)loadUListListingData;

@end
