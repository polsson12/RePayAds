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


-(void) viewDidLoad {
    
    _deleteUserButton.layer.cornerRadius = 6;
    
}


//Delete user button
- (IBAction)deleteUserButton:(id)sender {
    //TODO: Makes this right and delte objects associated with the user..
    
    
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                                 parameters:nil
                                 HTTPMethod:@"delete"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              __block NSString *alertText;
                              __block NSString *alertTitle;
                              if (!error) {//&& result == YES) {
                                  // Revoking the permission worked
                                  alertTitle = @"Permission successfully revoked";
                                  alertText = @"This app will no longer post to Facebook on your behalf.";
                                  
                              } else {
                                  // There was an error, handle it
                                  // See https://developers.facebook.com/docs/ios/errors/
                              }
                              
                              [[[UIAlertView alloc] initWithTitle:alertTitle
                                                          message:alertText
                                                         delegate:self
                                                cancelButtonTitle:@"OK!"
                                                otherButtonTitles:nil] show];
                          }];
    
    
    
    
    
    
    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"The user is no longer associated with their Facebook account.");
            [[PFUser currentUser] deleteEventually];
            
            [PFUser logOut];
            _user = [PFUser currentUser];
            NSLog(@"användar info: %@", [PFUser currentUser]);
            NSLog(@"Tar bort konto och loggar ut...");
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            //TODO: Error handling...
            NSLog(@"Error when unlinking user with facebook");
        }
    }];
    
    
    
    
}

@end
