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

@synthesize activityIndicator = _activityIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Logga in";
    _loginButton.layer.cornerRadius = 6;
    _loginButton.layer.shadowOpacity = 0.3;
    _activityIndicator.hidden = YES;

    // Do any additional setup after loading the view, typically from a nib.
    //PFUser *user = [PFUser currentUser];
   // user = nil;
    //[PFUser logOut];
    if ([PFUser currentUser] && // Check if user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { // Check if user is linked to Facebook
        //[self pushFirstViewController];
        if ([[PFUser currentUser] objectForKey:@"fbId"] || [[PFUser currentUser] objectForKey:@"fbName"]) {
            [self performSegueWithIdentifier:@"toFirstView" sender:self];
        }else{
            [PFUser logOut];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    //self.navigationController.navigationBar.topItem.title = @"RePay";
   // self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    //self.navigationItem.backBarButtonItem = nil;
    //self.navigationItem.leftBarButtonItem = nil;
    //UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@" " style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    //self.navigationItem.backBarButtonItem = button;

    
}


#pragma mark Login
- (IBAction)LoginButtonHandler:(id)sender {
    
   // NSLog(@"Trying to log in...");
    
    //TODO: Fix the correct permissions...
    //NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    NSArray *permissionsArray = @[@"public_profile", @"user_friends"];
    
    // Login PFUser using Facebook
    
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
    _loginButton.enabled = NO;
    _loginButton.alpha = 0.3;
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            [_activityIndicator stopAnimating]; // Hide loading indicator
            _activityIndicator.hidden = YES;
            _loginButton.enabled = YES;
            _loginButton.alpha = 1.0;
            
            NSString *errorMessage = nil;
            if (!error) {
                //NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Avbruten inloggning.";
            } else {
                //NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = @"Ett fel uppstod vid inloggningen. Kontrollera din internet uppkoppling.";
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fel vid inloggningen"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Ok", nil];
            [alert show];
        } else {
            if (user.isNew) {
                //NSLog(@"New user with facebook signed up and logged in!");

                [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    
                    if (!error) {
                        PFUser *user = [PFUser currentUser];
                        user[@"fbId"] = [result objectForKey:@"id"];
                        user[@"fbName"] = [result objectForKey:@"name"];
                        
                        
                        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                        currentInstallation[@"fbId"] = [result objectForKey:@"id"];
                        
                        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [_activityIndicator stopAnimating]; // Hide loading indicator
                            _activityIndicator.hidden = YES;
                            _loginButton.enabled = YES;
                            _loginButton.alpha = 1.0;
                            if(succeeded){
                               // NSLog(@"Lyckades spara facebookId i current install new user");
                            }else{
                                //NSLog(@"Lyckades INTE spara facebookId i current install new user");
                            }
                        }];
                        
                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [_activityIndicator stopAnimating]; // Hide loading indicator
                            _activityIndicator.hidden = YES;
                            _loginButton.enabled = YES;
                            _loginButton.alpha = 1.0;
                            if (succeeded) {
                                [self performSegueWithIdentifier:@"toFirstView" sender:self];
                            }
                            else {
                                //TODO: Error handling for when trying to save the data..
                                [[[UIAlertView alloc] initWithTitle:@"Fel vid inloggningen"
                                                            message:@"Misslyckades med inloggningen. Kontrollera din internet anslutning eller försök igen senare."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok!"
                                                  otherButtonTitles:nil] show];
                                [PFUser logOut];
                            }
                        }];
                        
                    }
                    else{
                        [_activityIndicator stopAnimating]; // Hide loading indicator
                        _activityIndicator.hidden = YES;
                        _loginButton.enabled = YES;
                        _loginButton.alpha = 1.0;
                        [[[UIAlertView alloc] initWithTitle:@"Fel vid inloggningen"
                                                    message:@"Misslyckades med inloggningen. Kontrollera din internet anslutning eller försök igen senare."
                                                   delegate:self
                                          cancelButtonTitle:@"Ok!"
                                          otherButtonTitles:nil] show];
                        //TODO: Error handler here???
                       // NSLog(@"Error when trying to get fbId with new user..");
                    }
                }];
                
            } else {
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                currentInstallation[@"fbId"] = [[PFUser currentUser] objectForKey:@"fbId"];
                
                [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [_activityIndicator stopAnimating]; // Hide loading indicator
                    _activityIndicator.hidden = YES;
                    _loginButton.enabled = YES;
                    _loginButton.alpha = 1.0;
                    if(succeeded){
                        NSLog(@"Lyckades spara facebookId i current install new user");
                        NSLog(@"User with facebook logged in!");
                        //NSLog(@"2current user facebook ID: %@", [[PFUser currentUser] objectForKey:@"fbId"]);
                        [self performSegueWithIdentifier:@"toFirstView" sender:self];
                    }else{
                        NSLog(@"Lyckades INTE spara facebookId i current install new user");
                        [[[UIAlertView alloc] initWithTitle:@"Fel vid inloggningen"
                                                    message:@"Misslyckades med inloggningen. Kontrollera din internet anslutning eller försök igen senare."
                                                   delegate:self
                                          cancelButtonTitle:@"Ok!"
                                          otherButtonTitles:nil] show];
                        [PFUser logOut];
                    }
                }];
            }
        }
    }];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toFirstView"]) {
        FirstViewController *firstView = [segue destinationViewController];
        [firstView.navigationItem setHidesBackButton:YES];
        
    }
}



@end
