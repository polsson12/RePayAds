//
//  ViewController.h
//  RePay
//
//  Created by Philip Olsson on 2014-11-24.
//  Copyright (c) 2014 Philip Olsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "FirstViewController.h"


@interface LoginViewController : UIViewController

//- (void)pushFirstViewController;
//- (void)addUserToDatabase;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

