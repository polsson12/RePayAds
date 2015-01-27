//
//  UIViewController+infoOneViewController.h
//  RePay
//
//  Created by Philip Olsson on 2015-01-11.
//  Copyright (c) 2015 Philip Olsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Reachability.h"


@interface infoOneViewController : UIViewController <UIAlertViewDelegate>


@property (strong, nonatomic) PFUser *user;

@property (weak, nonatomic) IBOutlet UIButton *deleteUserButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end
