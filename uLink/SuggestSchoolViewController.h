//
//  SuggestSchoolViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/10/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UlinkButton.h"
#import "AlertView.h"

@interface SuggestSchoolViewController : UIViewController <UIAlertViewDelegate,UITextFieldDelegate>{
    IBOutlet UlinkButton *submit;
}
@property (weak, nonatomic) IBOutlet UIView *suggestSuccessView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
-(IBAction)submitSuggestion;
@property (strong, nonatomic) IBOutlet UITextField *schoolNameTextField;
@end
