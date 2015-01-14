//
//  ViewController.m
//  RePay
//
//  Created by Philip Olsson on 2014-11-24.
//  Copyright (c) 2014 Philip Olsson. All rights reserved.
//


#import "LoginViewController.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loginButton.layer.cornerRadius = 6;
    _loginButton.layer.shadowOpacity = 0.3;

    // Do any additional setup after loading the view, typically from a nib.
    //PFUser *user = [PFUser currentUser];
   // user = nil;
    //[PFUser logOut];
    if ([PFUser currentUser] && // Check if user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { // Check if user is linked to Facebook
        //[self pushFirstViewController];
        if ([[PFUser currentUser] objectForKey:@"fbId"] && [[PFUser currentUser] objectForKey:@"fbName"]) {
            [self performSegueWithIdentifier:@"toFirstView" sender:self];
        }else{
            [PFUser logOut];
            NSLog(@"Någonting hände...Loggar ut användaren..");
        }
       
        
        NSLog(@"KOMMER HIT xD xD xD ");
        NSLog(@"cached current user facebook ID: %@", [[PFUser currentUser] objectForKey:@"fbName"]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    //TODO: Better fix for this??
    self.navigationController.navigationBar.topItem.title = @"RePay";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logga ut" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}


#pragma mark Login
- (IBAction)LoginButtonHandler:(id)sender {
    
    NSLog(@"Trying to log in...");
    
    //TODO: Fix the correct permissions...
    //NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    NSArray *permissionsArray = @[@"public_profile", @"user_friends"];
    
    // Login PFUser using Facebook
    
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        //TODO: Use some kind of loading indicator..
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"New user with facebook signed up and logged in!");

                [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        // Store the current user's Facebook ID on the user
                        //[[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"fbId"];
                        //[[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"fbName"];
                        PFUser *user = [PFUser currentUser];
                        user[@"fbId"] = [result objectForKey:@"id"];
                        user[@"fbName"] = [result objectForKey:@"name"];
                       NSLog(@"1current user facebook ID: %@", [[PFUser currentUser] objectForKey:@"fbId"]);
                       // NSLog(@"1current user facebook ID: %@", [[PFUser currentUser] objectForKey:@"fbId"]);
                        //[[PFUser currentUser] saveInBackground];
                        [[PFUser currentUser] saveEventually:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                [self performSegueWithIdentifier:@"toFirstView" sender:self];
                            }
                            else {
                                //TODO: Error handling for when trying to save the data..
                            }
                        }];
                        
                    }
                    else{
                        //TODO: Error handler here???
                        NSLog(@"Error when trying to get fbId with new user..");
                    }
                }];
                
            } else {
                [self performSegueWithIdentifier:@"toFirstView" sender:self];
                NSLog(@"User with facebook logged in!");
                NSLog(@"2current user facebook ID: %@", [[PFUser currentUser] objectForKey:@"fbId"]);

            }
            //[self pushFirstViewController];
        }
    }];
    
    //[_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

/*- (void)pushFirstViewController {
    //TODO: Make transistion smoother??
    FirstViewController *firstController = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstViewController"];
    
    [self.navigationController pushViewController:firstController animated:YES];
    
}*/

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toFirstView"]) {
        FirstViewController *firstView = [segue destinationViewController];        
    }
}

/*- (void)addUserToDatabase{
    
    
}*/


@end
