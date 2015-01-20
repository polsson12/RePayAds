//
//  UIViewController+FirstViewController.h
//  RePay
//
//  Created by Philip Olsson on 2014-11-25.
//  Copyright (c) 2014 Philip Olsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <QuartzCore/QuartzCore.h>

#import "infoOneViewController.h"
#import "GADInterstitial.h"
#import "CreateDebtViewController.h"



//@class CreateDebtViewController;

@interface FirstViewController : UIViewController <GADInterstitialDelegate, UIAlertViewDelegate>


@property (strong, nonatomic) PFUser *user;
@property (weak, nonatomic) IBOutlet UIButton *CreateDebt;
@property (weak, nonatomic) IBOutlet UIButton *ShowDebt;
@property (weak, nonatomic) IBOutlet UILabel *numOfNewDetps;



@end
