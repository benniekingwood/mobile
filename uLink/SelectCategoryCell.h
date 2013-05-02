//
//  SelectCategoryCell.h
//  ulink
//
//  Created by Christopher Cerwinski on 4/29/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCategoryCell : UITableViewCell {
    NSString *categoryId;
    NSString *categoryName;
}
@property (nonatomic, strong) NSString *categoryId;
@property (nonatomic, strong) NSString *categoryName;
@end
