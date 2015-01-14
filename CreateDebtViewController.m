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
    NSLog(@"view did load...");
    
    self.searchResultTableView.hidden = YES;
    self.searchBar.hidden = YES;
    
    _searchBar.returnKeyType = UIReturnKeyDone;
    _searchBar.enablesReturnKeyAutomatically = NO;
    
    self.sendToPerson = nil;
    _toName = @"";
    _friendInfo = nil;
    
    _activityIndicator.hidden = YES;

    
    
    
    [self getAllFbFriendsOfUserUsingApp];
}

-(void) viewWillAppear: (BOOL)animated {
    [self registerForKeyboardNotifications];


}

- (BOOL) controlInfo {
    NSArray *cells = [_informationTableView visibleCells];
    NSLog(@"antalet celler: %lu ", (unsigned long)[cells count]);
    
    //Check name
    UILabel *name = (UILabel *)[[cells objectAtIndex:0] viewWithTag:5];
    NSLog(@"namnet: %@",name.text);
    if (([name.text isEqualToString:@""])) {
        UIAlertView *mustSelectPerson = [[UIAlertView alloc]
                                         initWithTitle:@"Välj en person!" message:@"Du måste välja en person att skicka skulden till" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [mustSelectPerson show];
        return NO;
    }
    
    
    //Check so that something is written in the amount field
    UITextField *amount = (UITextField *)[[cells objectAtIndex:1] viewWithTag:4];
    NSLog(@"amount: %@", amount.text);
    if ([amount.text isEqualToString:@""] || [amount.text isEqual:@"0"]) {
        UIAlertView *mustSetAmount = [[UIAlertView alloc]
                                      initWithTitle:@"Ange belopp" message:@"Du måste ange ett giltigt belopp" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [mustSetAmount show];
        return NO;
     
    }
    
    //If non-valid text is typed
    NSInteger amountInt = [amount.text intValue];
    if (amountInt == 0) {
        UIAlertView *mustSetAmount = [[UIAlertView alloc]
                                      initWithTitle:@"Ange belopp" message:@"Du måste ange ett giltigt belopp" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [mustSetAmount show];
        return NO;
    }
    
    return YES;
    //if ([[[cells objectAtIndex:0] contentView].tag == 1].text  ) {
        
    //}
    //LÄgg in
    /*
    if (self.sendToPerson == nil) { //Must specify a person
        UIAlertView *mustSelectPerson = [[UIAlertView alloc]
         initWithTitle:@"Välj en person!" message:@"Du måste välja en person att skicka skulden till" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [mustSelectPerson show];
    }else if([self.Amount.text isEqual:@""] || [self.Amount.text isEqual:@"0"]) { //Must specify a amount
        UIAlertView *mustSetAmount = [[UIAlertView alloc]
                                         initWithTitle:@"Ange belopp" message:@"Du måste ange ett giltigt belopp" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [mustSetAmount show];
    }else{
        NSInteger amount = [self.Amount.text intValue];
        if (amount == 0) { //If non-valid text is typed
            UIAlertView *mustSetAmount = [[UIAlertView alloc]
                                          initWithTitle:@"Ange belopp" message:@"Du måste ange ett giltigt belopp" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [mustSetAmount show];
        }else{
            //Send debt to database..
           // NSLog(@"User fb name: %@   User fbId: %@",[[PFUser currentUser] objectForKey:@"fbName"],[[PFUser currentUser] objectForKey:@"fbId"]);
            NSString * toPerson = @"Vill du skicka till personen: ";
            NSString * name = self.sendToPerson.name;
            NSString * mess = [toPerson stringByAppendingString:name];
            mess = [mess stringByAppendingString:@"?"];
            UIAlertView *confirm = [[UIAlertView alloc]
                                          initWithTitle:@"Bekräfta skulden" message:mess delegate:self cancelButtonTitle:@"Nej" otherButtonTitles:@"Ja",nil];
            [confirm show];
        }
    }

    */
}

- (IBAction)dissMissKeyboardOnTap:(id)sender {
    //[[self view] endEditing:YES];
    [self.view endEditing:YES];

}


/* Get all Friends of the users Facebook ID's
 */
- (void) getAllFbFriendsOfUserUsingApp {
    /*NSArray *arr = [[FBSession activeSession] declinedPermissions];
     
     for (NSString *permissions in arr) {
     NSLog(@"Declined permission: %@" , permissions);
     }*/


    //TODO: Fix so that if a person denied permission when logging in, make a call to re-approve permission
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
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

            NSLog(@"Antalet fb vänner: %lu", (unsigned long)[_friendInfo count]);
            for (size_t i = 0; i < [_friendInfo count]; i++) {
                Person *p = [_friendInfo objectAtIndex:i];
                NSLog(@"Namn: %@   fbId: %@", p.name, p.fbId);
            
            }
            _searchResults = _friendInfo;
            [_searchResultTableView reloadData];
        }
        else{ //handle error
           // NSLog(@"MEGA ERROR:%@", error.domain);
            [_activityIndicator stopAnimating];
            _activityIndicator.hidden = YES;
            [self.navigationController popViewControllerAnimated:YES];
            UIAlertView *error = [[UIAlertView alloc]
                                         initWithTitle:@"Fel inträffade" message:@"Ett fel inträffade, kontrollera din internet anslutning eller försök igen senare." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [error show];
        }
    }];
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
}

#pragma mark table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections for information tableview
    if (tableView == _informationTableView) {
        return 3;
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
        else if (section == 1){ //Påminnelse                    (Reminder)
            return 1;
        }
        else if (section == 2){ //Skicka knapp                  (Send button)
            return 1;
        }
    }
    //Else return 0.  TODO: Is this correct? Think so!
    return 0;
    /*
    else {   //TODO: Is this correct??
        return 0;
    }
     */
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Inne i cell for row at index path");
    NSString *cellID = @"cellID";
    
    if (tableView == _informationTableView && indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2)) {
        cellID = @"amountCell";
    }
    else if (tableView == _informationTableView && indexPath.section == 0 && indexPath.row == 0) {
        cellID = @"nameCell";
    }
    else if (tableView == _informationTableView && indexPath.section == 2 && indexPath.row == 0) {
        cellID = @"sendButtonCell";
    }
    NSLog(@"cellID: %@", cellID);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (tableView == _informationTableView && indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2)) {
        UITextField *field = (UITextField *)[cell viewWithTag:4];
        if (indexPath.row == 1) {
            field.keyboardType = UIKeyboardTypeNumberPad;
        }
        
        //field.backgroundColor = [UIColor greenColor];
        field.delegate = self;
        field.returnKeyType = UIReturnKeyDone;
        field.font = [UIFont systemFontOfSize:15];

    }
    else if (tableView == _informationTableView && indexPath.section == 0 && indexPath.row == 0) {
        //UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(120, 7, 240, 30)];
        //UILabel *name = (UILabel*)[cell viewWithTag:5];
        //name.backgroundColor = [UIColor redColor];
        //name.font = [UIFont systemFontOfSize:15];
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
                NSLog(@"toName är :%@", _toName);
                l.text = _toName;
            }
            else if (indexPath.row == 1){
                /*
                UILabel *amount = (UILabel *)[cell viewWithTag:1];
                amount.text = @"Belopp: ";
                UITextField *amountInput = (UITextField *)[cell viewWith :2];
                amountInput.placeholder = @"testing....";
                */
                
                cell.textLabel.text = @"Belopp: ";
            }
            else if (indexPath.row == 2){
                cell.textLabel.text = @"Meddelande: ";
            }
        }
        else if (indexPath.section == 1){
            cell.textLabel.text = @"Påminnelse";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.section == 2){
            //cell.textLabel.text = @"SKICKA";
            UIColor *bgC = _informationTableView.backgroundColor;
            UIButton *sendButton = (UIButton*)[cell viewWithTag:6];
            sendButton.layer.cornerRadius = 2;
            sendButton.layer.borderWidth = -1;
            sendButton.layer.borderColor = bgC.CGColor;
            
            //[cell setHidden:YES];
            //[_informationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [_informationTableView setSeparatorColor:bgC];
            cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(cell.frame)/2, 0, CGRectGetWidth(cell.frame)/2);
            cell.backgroundColor = bgC;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    //NSString *name = [self.searchResults objectAtIndex:indexPath.row];
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Row Selected" message:@"hihf" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display Alert Message
    [messageAlert show];
    */
    
    
    
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
                UITextField *mess = (UITextField *)[[cells objectAtIndex:2] viewWithTag:4];
                [mess becomeFirstResponder];
            }
        }
        else if (indexPath.section == 1) { //Påminnelse         (Remainder)
        
        }
        else if (indexPath.section == 2) { //Skicka knapp        (Send button)
            if ([self controlInfo]) {
                //Send debt to database..
                NSArray *cells = [_informationTableView visibleCells];
                UILabel *name = (UILabel *)[[cells objectAtIndex:0] viewWithTag:5];
                NSString * toPerson = @"Vill du skicka till personen: ";
                NSString * mess = [toPerson stringByAppendingString:name.text];
                UITextField *debtMess = (UITextField *)[[cells objectAtIndex:2] viewWithTag:4];

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
    
    NSLog(@"VALUE IS : %@", _searchBar.isFirstResponder ? @"YES" : @"NO");

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
        NSLog(@"Texten ändrades till: %@", searchText);


        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name beginswith[c] %@", searchText];
        
        
        self.searchResults = [self.friendInfo filteredArrayUsingPredicate:predicate];
        
        if ([self.searchResults count] > 0) {
            for (NSString *name in (self.searchResults)) {
                NSLog(@"Results från sökningen: %@",name);
            }
        }
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
    NSLog(@"Till namn: %@ fbID: %@", _sendToPerson.name, _sendToPerson.fbId);
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title isEqual: @"Bekräfta skulden"]) {
        if (buttonIndex == 0) {
            NSLog(@"Cancel...");
        }else if (buttonIndex == 1){
            NSLog(@"Skicka skuld...");
            [self sendDebtToDataBase];
        }
    }
}


#pragma mark send information to database

- (void) sendDebtToDataBase{
    //LÄgg in
    
    // Get the cells
    NSArray *cells = [_informationTableView visibleCells];
    
    //Get the name
    UILabel *name = (UILabel *)[[cells objectAtIndex:0] viewWithTag:5];
    NSLog(@"namnet: %@",name.text);
    
    
    //Get the amount
    UITextField *amount = (UITextField *)[[cells objectAtIndex:1] viewWithTag:4];

    //Get the message
    UITextField *mess = (UITextField *)[[cells objectAtIndex:2] viewWithTag:4];
    
    //Create a object with the information
    PFObject *debt = [PFObject objectWithClassName:@"Debts"];
    debt[@"fromName"] = [[PFUser currentUser] objectForKey:@"fbName"];
    debt[@"fromFbId"] = [[PFUser currentUser] objectForKey:@"fbId"];
    debt[@"amount"] = [NSNumber numberWithInt:[amount.text intValue]];
    debt[@"approved"] = @NO;
    debt[@"message"] = mess.text;
    debt[@"toName"] = self.sendToPerson.name;
    debt[@"toFbId"] = self.sendToPerson.fbId;
    
    //Save the object in the database
    [debt saveEventually];
    [self.navigationController popViewControllerAnimated:YES];
    
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
    NSLog(@"hejsan keyboard..");
    /*NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }*/
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSLog(@"hej då keyboard..");

    /*
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
     */
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _searchBar.hidden = YES;
    _searchResultTableView.hidden = YES;
    [searchBar resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"HELLOHELLOHELLOHELLO");
    //NSLog(@"börjar editera.....");
    _activeKeyboard = textField;
    /*if ([_activeKeyboard tag] == 2) {
        UIView *doneButtonView = [[UIView alloc] initWithFrame:CGRectMake(0,120,300,44)];
        doneButtonView.tag = 3;
        doneButtonView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:doneButtonView];
        //NSLog(@"Belopp keyboard.....");
    }*/
    textField.textAlignment = NSTextAlignmentLeft;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
   // NSLog(@"BYEBYEBEYEBYEBYEY");
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
        UITextField *debtMess = (UITextField *)[[cells objectAtIndex:2] viewWithTag:4];
        
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


@end










