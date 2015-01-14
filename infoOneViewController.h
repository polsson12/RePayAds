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


@interface infoOneViewController : UIViewController


@property (strong, nonatomic) PFUser *user;

@property (weak, nonatomic) IBOutlet UIButton *deleteUserButton;


@end
