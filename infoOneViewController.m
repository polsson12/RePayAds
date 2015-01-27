//
//  UIViewController+infoOneViewController.m
//  RePay
//
//  Created by Philip Olsson on 2015-01-11.
//  Copyright (c) 2015 Philip Olsson. All rights reserved.
//

#import "infoOneViewController.h"



@implementation infoOneViewController

@synthesize user = _user;
@synthesize activityIndicator = _activityIndicator;


-(void) viewDidLoad {
    self.navigationItem.title = @"Information";
    _deleteUserButton.layer.cornerRadius = 6;
    _activityIndicator.hidden = YES;
    
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqual:@"Ta bort konto"]) {
        if (buttonIndex == 0) { //Avbryt        (Cancel)
            //NSLog(@"Avbryt...");

        }
        else if(buttonIndex == 1){  //Godkänn   (approve)
           // NSLog(@"Tar bort kontot...");
            [self deleteAcc];
        }
    }
}


//Delete user button
- (IBAction)deleteUserButton:(id)sender {
    //TODO: Makes this right and delte objects associated with the user..
    [[[UIAlertView alloc] initWithTitle:@"Ta bort konto"
                                message:@"Är du säker på att du vill ta bort kontot?"
                               delegate:self
                      cancelButtonTitle:@"Avbryt"
                      otherButtonTitles:@"Ta bort konto", nil] show];
}

- (void) deleteAcc{
    
    // Allocate a reachability object
    Reachability* reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];

    if(remoteHostStatus == NotReachable) {
       // NSLog(@"Not reachable");
        [[[UIAlertView alloc] initWithTitle:@"Fel uppstod"
                                    message:@"Kunde inte slutföra bortaggningen av ditt konto. Kontrollera din internet anslutning eller försök igen senare."
                                   delegate:self
                          cancelButtonTitle:@"Ok!"
                          otherButtonTitles:nil] show];
        
    } else {
        //NSLog(@"Reachable..");
        _activityIndicator.hidden = NO;
        [_activityIndicator startAnimating];
        _deleteUserButton.enabled = NO;
        _deleteUserButton.alpha = 0.3;
        
        [FBRequestConnection startWithGraphPath:@"/me/permissions"
                                     parameters:nil
                                     HTTPMethod:@"delete"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if (!error) {//&& result == YES) {
                                      [self deleteData];
                                  } else {
                                      // There was an error, handle it
                                      _activityIndicator.hidden = YES;
                                      [_activityIndicator stopAnimating];
                                      _deleteUserButton.enabled = YES;
                                      _deleteUserButton.alpha = 1.0;
                                      // See https://developers.facebook.com/docs/ios/errors/
                                      [[[UIAlertView alloc] initWithTitle:@"Fel uppstod"
                                                                  message:@"Kunde inte slutföra bortaggningen av ditt konto. Kontrollera din internet anslutning eller försök igen senare."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Ok!"
                                                        otherButtonTitles:nil] show];
                                    
                                  }
                              }];
    
    }
    
    
}

- (void) deleteData {
    
    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //NSLog(@"The user is no longer associated with their Facebook account.");
            [[PFUser currentUser] deleteEventually];
            
            PFQuery *toMe = [PFQuery queryWithClassName:@"Debts"];
            [toMe whereKey:@"toFbId" equalTo:[[PFUser currentUser] objectForKey:@"fbId"]];
            
            PFQuery *fromMe = [PFQuery queryWithClassName:@"Debts"];
            [fromMe whereKey:@"fromFbId" equalTo:[[PFUser currentUser] objectForKey:@"fbId"]];
            
            
            PFQuery *query = [PFQuery orQueryWithSubqueries:@[toMe,fromMe]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    [PFObject deleteAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
                        _activityIndicator.hidden = YES;
                        [_activityIndicator stopAnimating];
                        _deleteUserButton.enabled = YES;
                        _deleteUserButton.alpha = 1.0;
                        
                        if (succeeded) {
                            //successfully deleted all objects
                            [[[UIAlertView alloc] initWithTitle:@"Borttagning lyckades"
                                                        message:@"Borttagningen av kontot lyckades."
                                                       delegate:self
                                              cancelButtonTitle:@"Ok!"
                                              otherButtonTitles:nil] show];
                            
                            [PFUser logOut];
                            _user = [PFUser currentUser];
                        
                        
                            
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        } else {
                            [[[UIAlertView alloc] initWithTitle:@"Fel uppstod"
                                                        message:@"Kunde inte slutföra bortaggningen av ditt konto. Kontrollera din internet anslutning eller försök igen senare."
                                                       delegate:self
                                              cancelButtonTitle:@"Ok!"
                                              otherButtonTitles:nil] show];
                            
                            
                        }
                    }];
                } else {
                    _activityIndicator.hidden = YES;
                    [_activityIndicator stopAnimating];
                    _deleteUserButton.enabled = YES;
                    _deleteUserButton.alpha = 1.0;
                    
                    [[[UIAlertView alloc] initWithTitle:@"Fel uppstod"
                                                message:@"Kunde inte slutföra bortaggningen av ditt konto. Kontrollera din internet anslutning eller försök igen senare."
                                               delegate:self
                                      cancelButtonTitle:@"Ok!"
                                      otherButtonTitles:nil] show];
                }
            }];
        }
        else {
            //TODO: Error handling...
            _activityIndicator.hidden = YES;
            [_activityIndicator stopAnimating];
            _deleteUserButton.enabled = YES;
            _deleteUserButton.alpha = 1.0;
            
            [[[UIAlertView alloc] initWithTitle:@"Fel uppstod"
                                        message:@"Kunde inte slutföra bortaggningen av ditt konto. Kontrollera din internet anslutning eller försök igen senare."
                                       delegate:self
                              cancelButtonTitle:@"Ok!"
                              otherButtonTitles:nil] show];
            //NSLog(@"Error when unlinking user with facebook");
        }
    }];
}

@end
