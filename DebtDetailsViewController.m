//
//  UIViewController+DebtDetailsViewController.m
//  RePay
//
//  Created by Philip Olsson on 2014-12-08.
//  Copyright (c) 2014 Philip Olsson. All rights reserved.
//

#import "DebtDetailsViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Debt.h"




@interface DebtDetailsViewController ()


@end


@implementation DebtDetailsViewController

@synthesize debts = _debts;
NSIndexPath *deleteIndex;


- (void)viewDidLoad {
    
    //Set up buttons in the navigation bar
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [infoButton addTarget:self action:@selector(showInfoView) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Skulder" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    
   /* NSDictionary *data = @{
                           @"alert": @"James commented on your photo!",

                           };*/
    /*
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    
    
    // Send push notification to query
    [PFPush sendPushMessageToQueryInBackground:pushQuery
                                   withMessage:@"Hello World!"];*/
    selectedRow = -1;
    NSLog(@"Inne i Debt Details View Controller");
    if (_debts == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops"
                                                        message:@"Something went wrong"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Dismiss", nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        
        NSString* name;
        NSInteger index = 0;

        if([[_debts objectAtIndex:0] count] == 0){
            index = 1;
        }
        
        
        //self.view.backgroundColor = [UIColor grayColor];
        //_debtDetailsTableView.backgroundColor = [UIColor lightGrayColor];
        self.view.backgroundColor = _debtDetailsTableView.backgroundColor;
        //_debtDetailsTableView.backgroundColor = self.view.backgroundColor;
        //NSLog( NSStringFromClass( [[_debts objectAtIndex:0]class] ));
        //Find out the name to put as text in the cell
        //If the debt objects toFbId string is not equal to the current user fbId we know that the text in the cell should be toName
        NSLog(@"Värde på index: %ld",(long)index);

        if (![[[[_debts objectAtIndex:index] objectAtIndex:0] toFbId] isEqualToString:[[PFUser currentUser] objectForKey:@"fbId"]]) {
            name = [[[_debts objectAtIndex:index] objectAtIndex:0] toName];
        }else{ //Else we know that the text in the cell should be fromName
            name = [[[_debts objectAtIndex:index] objectAtIndex:0] fromName];
        }
        _nameLabel.text = name;
        
        //Calculate the differance in debts
        [self calculateAmount];
        
        [_debtDetailsTableView reloadData];
        
    }

    
}

#pragma mark table view methods



- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    NSLog(@"Kommer hit...2");
    return [[_debts objectAtIndex:0] count] + [[_debts objectAtIndex:1] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *cellID = @"UITableViewDetailsCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    // dequeue a table view cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
                                      forIndexPath:indexPath];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    UILabel *amount = (UILabel *)[cell viewWithTag:3];

    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd"];
    
    if(tableView == _debtDetailsTableView){
        if (indexPath.row < [[_debts objectAtIndex:0] count]) {
            NSLog(@"indexPath.row : %ld",(long)indexPath.row);
            NSDate *d = [[[_debts objectAtIndex:0] objectAtIndex:indexPath.row] createdAt];
            //date.text = [formatter stringFromDate:d];
            //message.text = [[[_debts objectAtIndex:0] objectAtIndex:indexPath.row] message];
            
            cell.textLabel.text = [formatter stringFromDate:d];
            cell.detailTextLabel.text = [[[_debts objectAtIndex:0] objectAtIndex:indexPath.row] message];
            if ([cell.detailTextLabel.text isEqual:@""]) {
                cell.detailTextLabel.text = @"     ";
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            amount.text = [[[[_debts objectAtIndex:0] objectAtIndex:indexPath.row] amount] stringValue];

           // amount.textColor = [UIColor colorWithRed:0.0f green:0.85f blue:0.0f alpha:1.0f];
            //if the dept not is confirmed, set the text color to gray
            if (![[[_debts objectAtIndex:0] objectAtIndex:indexPath.row] approved]) {
                //date.textColor = [UIColor grayColor];
                //message.textColor = [UIColor grayColor];
                cell.textLabel.textColor = [UIColor grayColor];
                cell.detailTextLabel.textColor = [UIColor grayColor];
                amount.textColor = [UIColor grayColor];
            }
            else{
                cell.textLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:175.0/255.0 blue:231.0/255.0 alpha:1];
                cell.detailTextLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:175.0/255.0 blue:231.0/255.0 alpha:1];
                amount.textColor = [UIColor blackColor];//[UIColor colorWithRed:77.0/255.0 green:175.0/255.0 blue:231.0/255.0 alpha:1];
            }
            
        }else{
            NSLog(@"indexPath.row : %ld",(long)indexPath.row);
            NSDate *d = [[[_debts objectAtIndex:1] objectAtIndex:(indexPath.row-[[_debts objectAtIndex:0] count])] createdAt];
           // date.text = [formatter stringFromDate:d];
            cell.textLabel.text = [formatter stringFromDate:d];
            cell.detailTextLabel.text =[[[_debts objectAtIndex:1] objectAtIndex:(indexPath.row - [[_debts objectAtIndex:0] count])] message];
            if ([cell.detailTextLabel.text isEqual:@""]) {
                cell.detailTextLabel.text = @"      ";
            }
            
            
            NSString *n = @"-";
            amount.text = [n stringByAppendingString:[[[[_debts objectAtIndex:1] objectAtIndex:(indexPath.row - [[_debts objectAtIndex:0] count])] amount] stringValue]];
            
            amount.textColor = [UIColor redColor];
            //if the dept not is confirmed, set the text color to gray
            if (![[[_debts objectAtIndex:1] objectAtIndex:(indexPath.row - [[_debts objectAtIndex:0] count])] approved]) {
                //date.textColor = [UIColor grayColor];
                //message.textColor = [UIColor grayColor];
                cell.textLabel.textColor = [UIColor grayColor];
                cell.detailTextLabel.textColor = [UIColor grayColor];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                //cell.backgroundColor =[UIColor cyanColor];
            }
            else{   //approved debts
                //cell.backgroundColor = [UIColor yellowColor];
                cell.textLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:175.0/255.0 blue:231.0/255.0 alpha:1];
                cell.detailTextLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:175.0/255.0 blue:231.0/255.0 alpha:1];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < [[_debts objectAtIndex:1] count]; i++) {
        NSLog(@"%@", [[[_debts objectAtIndex:1] objectAtIndex:i] amount]);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSLog(@"TRYCKER PÅ CELL: %d", indexPath.row);
    NSInteger index = indexPath.row - [[_debts objectAtIndex:0] count];
    if ((indexPath.row >= [[_debts objectAtIndex:0] count]) && ![[[_debts objectAtIndex:1] objectAtIndex:index] approved]) {
        UIAlertView *confirmDebtAlert = [[UIAlertView alloc] initWithTitle:@"Verifiera skuld"
                                                        message:@"Vill du godkänna skulden?"
                                                       delegate:self
                                              cancelButtonTitle:@"Avbryt"
                                              otherButtonTitles:@"Godkänn", nil];
        selectedRow = indexPath.row;
        /*NSLog(@"Index path . row %ld: ", (long)indexPath.row);
        NSLog(@"Index %ld: ", (long)index);
        NSLog(@"Antal element här: %ld", [[_debts objectAtIndex:1] count]);
        NSLog(@"CHECKSUMMA: %@", [[[_debts objectAtIndex:1] objectAtIndex:index] amount]);
         */
        [confirmDebtAlert show];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        deleteIndex = indexPath;
        
        UIAlertView *deleteDebt = [[UIAlertView alloc] initWithTitle:@"Ta bort skuld"
                                                                   message:@"Vill du verkligen ta bort skulden?"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Avbryt"
                                                         otherButtonTitles:@"Ta bort", nil];
        
        [deleteDebt show];
        /*if (indexPath.row < [[_debts objectAtIndex:0] count]) {
            NSLog(@"Detta object:%@",[[[_debts objectAtIndex:0] objectAtIndex:indexPath.row] toName]);
            
            //TODO: redo this deletion
            NSString *objId = [[[_debts objectAtIndex:0] objectAtIndex:indexPath.row] objectId];

            PFObject *object = [PFObject objectWithoutDataWithClassName:@"Debts"
                                                               objectId:objId];
            [object deleteEventually];
            [[_debts objectAtIndex:0] removeObjectAtIndex:indexPath.row];
            
            
        }else{
            NSString *objId = [[[_debts objectAtIndex:1] objectAtIndex:(indexPath.row - [[_debts objectAtIndex:0] count])] objectId];

            PFObject *object = [PFObject objectWithoutDataWithClassName:@"Debts"
                                                               objectId:objId];
            
            [object deleteEventually];
            [[_debts objectAtIndex:1] removeObjectAtIndex:(indexPath.row - [[_debts objectAtIndex:0] count])];
            
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
       // NSLog(@"Unhandled editing style! %ld", editingStyle);
    }*/
    }
    //[self calculateAmount];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Ta bort";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (indexPath.row < [[_debts objectAtIndex:0] count]) {
        return YES;
    }
    return NO;
}

- (void) deleteDebt {
    NSLog(@"ska a bort skuld...");
    if (deleteIndex.row < [[_debts objectAtIndex:0] count]) {
        NSLog(@"Detta object:%@",[[[_debts objectAtIndex:0] objectAtIndex:deleteIndex.row] toName]);
        
        //TODO: redo this deletion
        NSString *objId = [[[_debts objectAtIndex:0] objectAtIndex:deleteIndex.row] objectId];
        
        PFObject *object = [PFObject objectWithoutDataWithClassName:@"Debts"
                                                           objectId:objId];
        [object deleteEventually];
        [[_debts objectAtIndex:0] removeObjectAtIndex:deleteIndex.row];
        
        
    }else{
        NSString *objId = [[[_debts objectAtIndex:1] objectAtIndex:(deleteIndex.row - [[_debts objectAtIndex:0] count])] objectId];
        
        PFObject *object = [PFObject objectWithoutDataWithClassName:@"Debts"
                                                           objectId:objId];
        
        [object deleteEventually];
        [[_debts objectAtIndex:1] removeObjectAtIndex:(deleteIndex.row - [[_debts objectAtIndex:0] count])];
        
    }
    [_debtDetailsTableView deleteRowsAtIndexPaths:@[deleteIndex] withRowAnimation:UITableViewRowAnimationFade];
    [self calculateAmount];
}

- (void) calculateAmount{
    NSNumber* amount = @(0);
    
    
    for (int i = 0; i < [[_debts objectAtIndex:0] count]; i++) {
        NSLog(@"Amount %@", [[[_debts objectAtIndex:0] objectAtIndex:i] amount] );
        amount = [NSNumber numberWithFloat:([[[[_debts objectAtIndex:0] objectAtIndex:i] amount] floatValue]  + [amount floatValue])];
    }

    for (int i = 0; i < [[_debts objectAtIndex:1] count]; i++) {
        NSLog(@"Amount %@", [[[_debts objectAtIndex:1] objectAtIndex:i] amount] );
        amount = [NSNumber numberWithFloat:([amount floatValue]-[[[[_debts objectAtIndex:1] objectAtIndex:i] amount] floatValue]) ];
    }
    _differanceLabel.text = [amount stringValue];
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqual:@"Verifiera skuld"]) {
        if (buttonIndex == 0) { //Avbryt        (Cancel)
            selectedRow = -1;
        }
        else if(buttonIndex == 1){  //Godkänn   (approve)
            [self approveDebt];
        }
    }
    else if ([alertView.title isEqualToString:@"Ta bort skuld"]){
        if (buttonIndex == 0) { //Avbryt        (Cancel)
            
        }
        else if(buttonIndex == 1){  //Godkänn   (approve)
            [self deleteDebt];
        }
    }
}

-(void) approveDebt{
    if (selectedRow != -1) {
        NSInteger index = selectedRow - [[_debts objectAtIndex:0] count];
        NSLog(@"DEN OMRÄKNADE VALDA RADEN ÄR: %ld ", (long) index);
        //NSNumber *a = [[[_debts objectAtIndex:1] objectAtIndex:index] amount];
        //NSLog(@"beloppet som är bekräftat: %@", a);
        Debt *d = [[_debts objectAtIndex:1] objectAtIndex:index];
        d.approved = YES;
        
        PFQuery *query = [PFQuery queryWithClassName:@"Debts"];
        
        // Retrieve the object by id
        [query getObjectInBackgroundWithId:d.objectId block:^(PFObject *object, NSError *error) {
            
            // Now let's update it with some new data. In this case, only cheatMode and score
            // will get sent to the cloud. playerName hasn't changed.
            object[@"approved"] = @YES;
            [object saveEventually];
            
        }];

    }
    
    [_debtDetailsTableView reloadData];
    selectedRow = -1;
}

-(IBAction)showInfoView {
    [self performSegueWithIdentifier:@"toInfoDebtDetails" sender:self];    
}



@end
