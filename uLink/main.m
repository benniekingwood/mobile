    //
//  main.m
//  uLink
//
//  Created by Bennie Kingwood on 11/7/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pixate.h"
#import "AppDelegate.h"
#import "AppMacros.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [Pixate licenseKey:PIXATE_LICENSE forUser:PIXATE_USER];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
