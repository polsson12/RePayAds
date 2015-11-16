//
//  UIViewController+CreateDebtViewController.m
//  RePay
//
//  Created by Philip Olsson on 2014-12-02.
//  Copyright (c) 2014 Philip Olsson. All rights reserved.
//

#import "CreateDebtViewController.h"


@interface CreateDebtViewController ()

@end

@implementation CreateDebtViewController

@synthesize friendInfo = _friendInfo;
@synthesize activityIndicator = _activityIndicator;
- (void)viewDidLoad {

    [self controlCurrentUserInstall];
    [self controlCurrentUser];

    self.navigationItem.title = @"Skapa skuld";

    self.searchResultTableView.hidden = YES;
    self.searchBar.hidden = YES;
    
    _searchBar.returnKeyType = UIReturnKeyDone;
    _searchBar.enablesReturnKeyAutomatically = NO;
    
    self.sendToPerson = nil;
    _toName = @"";
    _friendInfo = nil;
    _activityIndicator.hidden = YES;

    [self checkPermissions];
}

-(void) viewWillAppear: (BOOL)animated {
    [self registerForKeyboardNotifications];

}

- (BOOL) controlInfo {
    NSArray *cells = [_informationTableView visibleCells];
    //NSLog(@"antalet celler: %lu ", (unsigned long)[cells count]);
    
    //Check name
    UILabel *name = (UILabel *)[[cells objectAtIndex:0] viewWithTag:5];
    //NSLog(@"namnet: %@",name.text);
    if (([name.text isEqualToString:@""])) {
        UIAlertView *mustSelectPerson = [[UIAlertView alloc]
                                         initWithTitle:@"Välj en person!" message:@"Du måste välja en person att skicka skulden till" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [mustSelectPerson show];
        return NO;
    }
    
    
    //Check so that something is written in the amount field
    UITextField *amount = (UITextField *)[[cells objectAtIndex:1] viewWithTag:4];
    //NSLog(@"amount: %@", amount.text);
    if ([amount.text isEqualToString:@""] || [amount.text isEqual:@"0"]) {
        UIAlertView *mustSetAmount = [[UIAlertView alloc]
                                      initWithTitle:@"Ange belopp" message:@"Du måste ange ett giltigt belopp" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [mustSetAmount show];
        return NO;
     
    }
    
    if([amount.text length] > 0){
        NSString *firstChar = [NSString stringWithFormat:@"%c", [amount.text characterAtIndex:0]];
        if ([firstChar isEqualToString:@"0"]) {
            UIAlertView *mustSetAmount = [[UIAlertView alloc]
                                          initWithTitle:@"Ange belopp" message:@"Du måste ange ett giltigt belopp" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [mustSetAmount show];
            return NO;
        }
    }
    
    //If non-valid text is typed
    NSInteger amountInt = [amount.text intValue];
    if (amountInt <= 0) {
        UIAlertView *mustSetAmount = [[UIAlertView alloc]
                                      initWithTitle:@"Ange belopp" message:@"Du måste ange ett giltigt belopp" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [mustSetAmount show];
        return NO;
    }
    
    return YES;
}

- (IBAction)dissMissKeyboardOnTap:(id)sender {
    //[[self view] endEditing:YES];
    [self.view endEditing:YES];

}

- (void) checkPermissions {
    NSArray *arr = [[FBSession activeSession] declinedPermissions];
    
    /*for (NSString *permissions in arr) {
        NSLog(@"Declined permission: %@" , permissions);
    }*/
    
    if ([arr count] > 0) {
        [[FBSession activeSession] requestNewReadPermissions:arr completionHandler:^(FBSession *session, NSError *error) {
            if (!error) {
                [self getAllFbFriendsOfUserUsingApp];
            }
            else{
                //fail
                UIAlertView *confirm = [[UIAlertView alloc]
                                        initWithTitle:@"Fel uppstod" message:@"Ett fel uppstod, kontrollera din internet anslutning eller försök igen senare." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [confirm show];
            }
        }];
        
    }
    else {
        [self getAllFbFriendsOfUserUsingApp];
    }

}


/* Get all Friends of the users Facebook ID's
 */
- (void) getAllFbFriendsOfUserUsingApp {
    
   

    [FBRequestConnection startWithGraphPath:@"me/friends?limit=5000" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            [_activityIndicator stopAnimating];
            _activityIndicator.hidden = YES;
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            _friendInfo = [NSMutableArray arrayWithCapacity:friendObjects.count];

            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                
                Person *person = [[Person alloc] init];
                person.name = [friendObject objectForKey:@"name"];
                person.fbId = [friendObject objectForKey:@"id"];
                [_friendInfo addObject:person];
            }

            /*NSLog(@"Antalet fb vänner: %lu", (unsigned long)[_friendInfo count]);
            for (size_t i = 0; i < [_friendInfo count]; i++) {
                Person *p = [_friendInfo objectAtIndex:i];
                NSLog(@"Namn: %@   fbId: %@", p.name, p.fbId);
            
            }*/
             
            _searchResults = _friendInfo;
            [_searchResultTableView reloadData];
        }
        else{ //handle error
            [_activityIndicator stopAnimating];
            _activityIndicator.hidden = YES;
            NSLog(@"Error...user events: %@", result);

            UIAlertView *errorView = [[UIAlertView alloc]
                                         initWithTitle:@"Fel inträffade" message:@"Ett fel inträffade, kontrollera din internet anslutning eller försök igen senare." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //NSLog(@"error code: %ld \n error msg: %@", (long)[error code], [error localizedDescription]);
            
            [errorView show];
            [self logoutUser];
        }
    }];
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
}

#pragma mark table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections for information tableview
    if (tableView == _informationTableView) {
        return 2;
        //return 3;
    }else
        return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == _searchResultTableView) {
        return [self.searchResults count];
    }
    else if (tableView == _informationTableView){
        if (section == 0) { //  Namn, Belopp, Meddelande        (Name, Amount, Message)
            return 3;
        }
        else if (section == 1){ //Skicka                    (Send button)
            return 1;
        }
    }
    //Else return 0.  TODO: Is this correct? Think so!
    return 0;
   
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Inne i cell for row at index path");
    NSString *cellID = @"cellID";
    
    if (tableView == _informationTableView && indexPath.section == 0 && indexPath.row == 1) {
        cellID = @"amountCell";
    }
    else if (tableView == _informationTableView && indexPath.section == 0 && indexPath.row == 2){
        cellID = @"messageCell";
    }
    else if (tableView == _informationTableView && indexPath.section == 0 && indexPath.row == 0) {
        cellID = @"nameCell";
    }
    else if (tableView == _informationTableView && indexPath.section == 1 && indexPath.row == 0) {
        cellID = @"sendButtonCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    //amount cell
    if (tableView == _informationTableView && indexPath.section == 0 && indexPath.row == 1) {
        UITextField *amountfield = (UITextField *)[cell viewWithTag:4];
        //amountfield.keyboardType = UIKeyboardTypeNumberPad;
        amountfield.delegate = self;
        //amountfield.returnKeyType = UIReturnKeyDone;
        amountfield.font = [UIFont systemFontOfSize:15];

    }//message cell
    else if (tableView == _informationTableView && indexPath.section == 0 && indexPath.row == 2){
        UITextField *messField = (UITextField *)[cell viewWithTag:3];
        messField.delegate = self;
        messField.returnKeyType = UIReturnKeyDone;
        messField.font = [UIFont systemFontOfSize:15];
    }
    
    
    if (tableView == _searchResultTableView) {
        //cell.textLabel.text = [[self.searchResults objectAtIndex:indexPath.row]];
        cell.textLabel.text = [[self.searchResults objectAtIndex:indexPath.row] name];
    }
    else if (tableView == _informationTableView){
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                //cell.textLabel.text = _toText;
                cell.textLabel.text = @"Till: ";
                UILabel *l = (UILabel*)[cell viewWithTag:5];
                //NSLog(@"toName är :%@", _toName);
                l.text = _toName;
            }
            else if (indexPath.row == 1){
                
                cell.textLabel.text = @"Belopp: ";
            }
            else if (indexPath.row == 2){
                cell.textLabel.text = @"Meddelande: ";
            }
        }
        else if (indexPath.section == 1 && indexPath.row == 0){
            UIColor *bgC = _informationTableView.backgroundColor;
            UIButton *sendButton = (UIButton*)[cell viewWithTag:6];
            sendButton.layer.cornerRadius = 2;
            sendButton.layer.borderWidth = -1;
            sendButton.layer.borderColor = bgC.CGColor;
            
            [_informationTableView setSeparatorColor:bgC];
            cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(cell.frame)/2, 0, CGRectGetWidth(cell.frame)/2);
            cell.backgroundColor = bgC;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _informationTableView) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {       // Till person            (To person)
                _searchBar.hidden = NO;
                _searchResultTableView.hidden = NO;
                [self.searchBar becomeFirstResponder];
                //NSLog(@"VALUE IS : %@", _searchBar.isFirstResponder ? @"YES" : @"NO");
                
                [_searchResultTableView reloadData];
            }
            else if (indexPath.row == 1) { //Belopp             (Amount)
                // Get the cells
                NSArray *cells = [_informationTableView visibleCells];
                //Get the amount text field
                UITextField *amount = (UITextField *)[[cells objectAtIndex:1] viewWithTag:4];
                [amount becomeFirstResponder];
            }
            else if (indexPath.row == 2) { // Meddelande        (Message)
                // Get the cells
                NSArray *cells = [_informationTableView visibleCells];
                //Get the message text field
                UITextField *mess = (UITextField *)[[cells objectAtIndex:2] viewWithTag:3];
                [mess becomeFirstResponder];
            }
        }
       /* else if (indexPath.section == 1) { //Påminnelse         (Remainder)
        
        }*/
        else if (indexPath.section == 1 && indexPath.row == 0) { //Skicka knapp        (Send button)
            if ([self controlInfo]) {
                //Send debt to database..
                NSArray *cells = [_informationTableView visibleCells];
                UILabel *name = (UILabel *)[[cells objectAtIndex:0] viewWithTag:5];
                NSString * toPerson = @"Vill du skicka till personen: ";
                NSString * mess = [toPerson stringByAppendingString:name.text];
                UITextField *debtMess = (UITextField *)[[cells objectAtIndex:2] viewWithTag:3];

                if ([debtMess.text isEqualToString:@""]) {
                    mess = [mess stringByAppendingString:@", utan något meddelande?"];
                }
                else{
                    mess = [mess stringByAppendingString:@"?"];
                }
                UIAlertView *confirm = [[UIAlertView alloc]
                                        initWithTitle:@"Bekräfta skulden" message:mess delegate:self cancelButtonTitle:@"Nej" otherButtonTitles:@"Ja",nil];
                [confirm show];
            }
        
        }
    }
    else if(tableView == _searchResultTableView){
        _searchResultTableView.hidden = YES;
        _searchBar.hidden = YES;
        _searchBar.text = @"";
        [[self view] endEditing:YES];
        [self deptToPerson:indexPath.row];
        if (_friendInfo != nil) {
            _searchResults = _friendInfo;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark Search methods

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    ///NSLog(@"search text length is: %lu", (unsigned long)[searchText length]);
    if ([searchText length] == 0) {
       // NSLog(@"search text length är 0");
        [[self view] endEditing:YES];
        if (_friendInfo != nil) {
            _searchResults = _friendInfo;
        }
        self.searchResultTableView.hidden = YES;
        self.searchBar.hidden = YES;
    }else{
        self.searchResultTableView.hidden = NO;


        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name beginswith[c] %@", searchText];
        
        
        self.searchResults = [self.friendInfo filteredArrayUsingPredicate:predicate];
        
        /*if ([self.searchResults count] > 0) {
            for (NSString *name in (self.searchResults)) {
                NSLog(@"Results från sökningen: %@",name);
            }
        }*/
    }
    [self.searchResultTableView reloadData];
}


- (void) deptToPerson:(NSInteger) index {
    //LÄgg in
    
    self.sendToPerson = [[Person alloc] init];
    self.sendToPerson.name = [[self.searchResults objectAtIndex:index] name];
    self.sendToPerson.fbId = [[self.searchResults objectAtIndex:index] fbId];
    
    
    _toName = _sendToPerson.name;
    [_informationTableView reloadData];
    //NSLog(@"Till namn: %@ fbID: %@", _sendToPerson.name, _sendToPerson.fbId);
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title isEqual: @"Bekräfta skulden"]) {
        if (buttonIndex == 0) {
        }else if (buttonIndex == 1){
           // NSLog(@"Klickar på ja knappen");
            [self sendDebtToDataBase];
        }
    }
}


#pragma mark send information to database

- (void) sendDebtToDataBase{
    //LÄgg in
    
    // Get the cells
    NSArray *cells = [_informationTableView visibleCells];
    
    
    
    //Get the amount
    UITextField *amount = (UITextField *)[[cells objectAtIndex:1] viewWithTag:4];

    //Get the message
    UITextField *mess = (UITextField *)[[cells objectAtIndex:2] viewWithTag:3];
    
    //Create a object with the information
    PFObject *debt = [PFObject objectWithClassName:@"Debts"];
    debt[@"fromName"] = [[PFUser currentUser] objectForKey:@"fbName"];
    debt[@"fromFbId"] = [[PFUser currentUser] objectForKey:@"fbId"];
    debt[@"amount"] = [NSNumber numberWithInt:[amount.text intValue]];
    debt[@"approved"] = @NO;
    debt[@"message"] = mess.text;
    debt[@"toName"] = self.sendToPerson.name;
    debt[@"toFbId"] = self.sendToPerson.fbId;
    
    //send a push to the user
    
    
    
    /*
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"fbId" equalTo:self.sendToPerson.fbId];
    PFUser *currentUser = [PFUser currentUser];
    NSString *message = [NSString stringWithFormat:@"Du har en ny skuld från %@ på %@ kr", currentUser[@"fbName"], amount.text];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          message, @"alert",
                          @"Increment", @"badge",
                          @"default", @"sound",
                          nil];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    //[push setMessage:message];
    [push setData:data];
    [push sendPushInBackground];
    */
    
    //Save the object in the database
    UIButton *sendButton = (UIButton *)[[cells objectAtIndex:3] viewWithTag:6];
    UITableViewCell *sendButtonCell = [cells objectAtIndex:3];
    sendButtonCell.userInteractionEnabled = NO;
    [sendButton setAlpha:0.5];
    
    //Show loading indicator and activate it
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    [_delegate sendDataToFirstView:@"yes"];
    [debt saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {    //Send dept to database with succes
            //Send push
            PFUser *currentUser = [PFUser currentUser];
            NSString *message = [NSString stringWithFormat:@"Du har en ny skuld från %@ på %@ kr", currentUser[@"fbName"], amount.text];
            
            [PFCloud callFunctionInBackground:@"sendPushToUser"
                               withParameters:@{@"recipientId": self.sendToPerson.fbId, @"message": message}
                                        block:^(NSString *success, NSError *error) {
                                            if (!error) {
                                                // Push sent successfully
                                                //NSLog(@"Lyckades skicka push från client till server: %@ ",success);
                                            }else{
                                                //NSLog(@"Lyckades INTE skicka push från client till server: %@", [error localizedDescription]);
                                            }
                                        }];
            
            //Go back to first view VC and stop loading indicator
            [_activityIndicator stopAnimating];
            _activityIndicator.hidden = YES;
            self.sendToPerson = nil;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else { //An error occuredd when saving the object to data base
            
            //Display error alert view
            //NSLog(@"ERROR WHEN SAVING OBJECT..");
            _activityIndicator.hidden = YES;
            [_activityIndicator stopAnimating];
            
            //Show error message
            UIAlertView *confirm = [[UIAlertView alloc]
                                    initWithTitle:@"Fel uppstod" message:@"Ett fel uppstod, kontrollera din internet anslutning eller försök igen senare." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [confirm show];

        
        }
        sendButtonCell.userInteractionEnabled = YES;
        [sendButton setAlpha:1.0];

    }];
    
}

#pragma mark keyboard functions
- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _searchBar.hidden = YES;
    _searchResultTableView.hidden = YES;
    [searchBar resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //NSLog(@"börjar editera.....");
    _activeKeyboard = textField;
    textField.textAlignment = NSTextAlignmentLeft;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _activeKeyboard = nil;
    [textField resignFirstResponder];
    textField.textAlignment = NSTextAlignmentRight;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    _activeKeyboard = nil;
    return YES;
}

- (IBAction)sendDebtButton:(id)sender {
    if ([self controlInfo]) {
        //Send debt to database..
        NSArray *cells = [_informationTableView visibleCells];
        UILabel *name = (UILabel *)[[cells objectAtIndex:0] viewWithTag:5];
        NSString * toPerson = @"Vill du skicka till personen: ";
        NSString * mess = [toPerson stringByAppendingString:name.text];
        UITextField *debtMess = (UITextField *)[[cells objectAtIndex:2] viewWithTag:3];
        
        if ([debtMess.text isEqualToString:@""]) {
            mess = [mess stringByAppendingString:@", utan något meddelande?"];
        }
        else{
            mess = [mess stringByAppendingString:@"?"];
        }
        UIAlertView *confirm = [[UIAlertView alloc]
                                initWithTitle:@"Bekräfta skulden" message:mess delegate:self cancelButtonTitle:@"Nej" otherButtonTitles:@"Ja",nil];
        [confirm show];
    }
}

#pragma mark control functions

-(void) controlCurrentUser {
    if (!([[PFUser currentUser] objectForKey:@"fbId"] || [[PFUser currentUser] objectForKey:@"fbName"])) {
        [self logoutUser];
        //NSLog(@"Någonting hände...Loggar ut användaren..");
    }
}

-(void) controlCurrentUserInstall {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation[@"fbId"] != [[PFUser currentUser] objectForKey:@"fbId"]) {
        [self logoutUser];
        //NSLog(@"Någonting hände...Loggar ut användaren..");
    }
}

- (void) logoutUser {
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark textfield delegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (textField.tag == 4) { //belopp textField (amount textField)
        return (newLength > 7) ? NO : YES;
    }else if (textField.tag == 3) { //meddelande textField (message textField)
        return (newLength > 20) ? NO : YES;
    }
    return (newLength > 20) ? NO : YES;
}


@end










