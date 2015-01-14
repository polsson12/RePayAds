//
//  UIViewController+ShowDebtViewController.m
//  RePay
//
//  Created by Philip Olsson on 2014-12-08.
//  Copyright (c) 2014 Philip Olsson. All rights reserved.
//

#import "ShowDebtViewController.h"
#import "DebtDetailsViewController.h"


@interface ShowDebtViewController ()

@end

@implementation ShowDebtViewController

@synthesize debts = _debts;
@synthesize debtsToPerson = _debtsToPerson;
@synthesize uniqueFbIds = _uniqueFbIds;
@synthesize activityIndicator = _activityIndicator;



- (void)viewDidLoad {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Skulder" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    //Fetch depts..
    //TODO: Might be buggy if a user is fast enough to click here if one have deleted all the debts in DebtsDetailsViewController
    //and comes back here...
    self.showDeptsTableView.hidden = YES;
    _activityIndicator.hidden = YES;
    _debts = nil;
    [self fetchDeptsForUser];
}






#pragma mark table view methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

        return [_debtsToPerson count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //NSLog(@"Inne i cell for row at index path");
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (tableView == _showDeptsTableView) {
        NSString* name;
        NSInteger index = 0;
        
        UILabel *amountLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *numOfunApproved = (UILabel *)[cell viewWithTag:2];
        numOfunApproved.hidden = YES;
        numOfunApproved.layer.masksToBounds = YES;
        numOfunApproved.layer.cornerRadius = 9;
        
        
        if([[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:0] count] == 0){
            NSLog(@"Kommer hit.........");
            index = 1;
        }
        //Find out the name to put as text in the cell
        //If the debt objects toFbId string is not equal to the current user fbId we know that the text in the cell should be toName
        if (![[[[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:index] objectAtIndex:0] toFbId] isEqualToString:[[PFUser currentUser] objectForKey:@"fbId"]]) {
            name = [[[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:index] objectAtIndex:0] toName];
        }else{ //Else we know that the text in the cell should be fromName
            name = [[[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:index] objectAtIndex:0] fromName];
        }
        //Find out which color to put on the text
        
        BOOL app = YES;
        
        NSNumber* amount = @(0);
        NSInteger numNonApp = 0;
        

        
        
        for (int i = 0; i < [[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:0] count]; i++) {
            NSLog(@"Amount %@", [[[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:0] objectAtIndex:i] amount]);
            amount = [NSNumber numberWithFloat:([[[[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:0] objectAtIndex:i] amount] floatValue]  + [amount floatValue])];
        }
        
        for (int i = 0; i < [[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:1] count]; i++) {
            NSLog(@"Amount %@", [[[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:1] objectAtIndex:i] amount] );
            amount = [NSNumber numberWithFloat:([amount floatValue]-[[[[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:1] objectAtIndex:i] amount] floatValue]) ];
            if (![[[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:1] objectAtIndex:i] approved]) {
                numNonApp ++;
            }
        }
        
        if (numNonApp > 0) {
            numOfunApproved.hidden = NO;
            if (numNonApp > 10) {
                numOfunApproved.text = @"10+";
            }
            else{
                numOfunApproved.text =  [NSString stringWithFormat: @"%ld", (long)numNonApp];
            }
            }
        
        
        
        
        //NSNumber* amount = @(0);
        
        /*for (int i = 0; i < [[_debtsToPerson objectAtIndex:indexPath.row] count]; i++) {
            for (int j = 0; j < [[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:i] count]; j++) {
                //NSLog([[[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:i] objectAtIndex:j] approved] ? @"Yes" : @"No");
                amount = [NSNumber numberWithFloat:([[[[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:i] objectAtIndex:j] amount] floatValue]  + [amount floatValue])];
                NSLog(@"AMOUNT: %@", amount);
                if(![[[[_debtsToPerson objectAtIndex:indexPath.row] objectAtIndex:i] objectAtIndex:j] approved]){
                    //app = NO;
                    //break;
                }
            }
            if (!app) {
                NSLog(@"breakar.........");
                break;
            }
        }*/
        if (app) {
            cell.textLabel.textColor  = [UIColor colorWithRed:11.0/255.0 green:96.0/255.0 blue:254.0/255.0 alpha:1];
            amountLabel.textColor = [UIColor colorWithRed:11.0/255.0 green:96.0/255.0 blue:254.0/255.0 alpha:1];
        }else{
            cell.textLabel.textColor  = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
            amountLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];

        }
        cell.textLabel.text = name;
        amountLabel.text = [amount stringValue];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"toDebtDeatilsViewController" sender:[_debtsToPerson objectAtIndex:indexPath.row ]];
}

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //[_objects removeObjectAtIndex:indexPath.row];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        NSLog(@"Unhandled editing style! %ld", editingStyle);
    }
}*/


/*
 * Fetch the depts for the current user
 */

- (void) fetchDeptsForUser{
    PFQuery *toMe = [PFQuery queryWithClassName:@"Debts"];
    //TODO: IMPORTANT!!!!!!! What if PFUser is NULL? 
    [toMe whereKey:@"toFbId" equalTo:[[PFUser currentUser] objectForKey:@"fbId"]];

    PFQuery *fromMe = [PFQuery queryWithClassName:@"Debts"];
    [fromMe whereKey:@"fromFbId" equalTo:[[PFUser currentUser] objectForKey:@"fbId"]];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[toMe,fromMe]];
    [query orderByDescending:@"createdAt"];
    
    NSLog(@"User fbId: %@",[[PFUser currentUser] objectForKey:@"fbId"]);
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            [_activityIndicator stopAnimating];
            _activityIndicator.hidden = YES;
            NSLog(@"Successfully retrieved %lu objects.", (unsigned long)objects.count);

            _debts = [NSMutableArray arrayWithCapacity:objects.count];
            
            _uniqueFbIds = [[NSMutableArray alloc] init];
            //TODO: save as PFObject instead? This might be unnessesary....
            for (PFObject *object in objects) {
                Debt* d = [[Debt alloc] init];
                d.fromName = object [@"fromName"];
                d.fromFbId = object [@"fromFbId"];
                d.message = object [@"message"];
                d.toName = object [@"toName"];
                d.toFbId = object [@"toFbId"];
                d.amount = object [@"amount"];
                d.approved = [object [@"approved"] boolValue];
                d.createdAt = [object createdAt];
                d.objectId = [object objectId];
                [_debts addObject:d];
                //NSLog(d.approved ? @"Yes" : @"No");

                //NSLog(@"object id: %@", [object objectId]);
                if(![_uniqueFbIds containsObject:d.fromFbId] && !([d.fromFbId isEqualToString:[[PFUser currentUser] objectForKey:@"fbId"]])) {
                    [_uniqueFbIds addObject:d.fromFbId];
                }
                if (![_uniqueFbIds containsObject:d.toFbId] && !([d.toFbId isEqualToString:[[PFUser currentUser] objectForKey:@"fbId"]])) {
                    [_uniqueFbIds addObject:d.toFbId];
                }
              
            }
            //NSLog(@"_uniqueFbIds har nu storleken: %lu ", (unsigned long)[_uniqueFbIds count]);
            //NSLog(@"_depts har nu storleken: %lu ", (unsigned long)[_debts count]);
            if ([_uniqueFbIds count] > 0) { // We have depts.. Do the processing for them and show tableview..
                self.showDeptsTableView.hidden = NO;
                [self sortDepts];
                [self.showDeptsTableView reloadData];
            }else{
                //TODO: View that says no debts..
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Inga skulder"
                                                                message:@"Du har inga nuvarande skulder"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }

        } else {
            //TODO: No internet connection?
            // Log details of the failure
            NSLog(@"KOMER HITKOMER HITKOMER HITKOMER HITKOMER HITKOMER HITKOMER HITKOMER HITKOMER HIT");
            NSLog(@"Error123: %@ %@", error, [error userInfo]);
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

- (void) sortDepts{
    //NSMutableArray* arr = [[NSMutableArray alloc] init];
   _debtsToPerson = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_uniqueFbIds count];i++) {
        NSMutableArray* arr = [[NSMutableArray alloc] init];
        
        NSString *attributeName1  = @"toFbId";
        NSString *attributeValue = [_uniqueFbIds objectAtIndex:i];
        
        //Debts from me to someone else with fbId: attributeValue
        //Need to make the array returned from the predicate filter to __NSM for purposes in DebtDetailsViewController.
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K like %@",attributeName1 , attributeValue];
        [arr addObject:[NSMutableArray arrayWithArray:[_debts filteredArrayUsingPredicate:predicate1]]];
        
        //Debts to me from someone else with fbId: attributeValue
        NSString *attributeName2  = @"fromFbId";
        //Need to make the array returned from the predicate filter to __NSM for purposes in DebtDetailsViewController.
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"%K like %@",attributeName2, attributeValue];
        [arr addObject:[NSMutableArray arrayWithArray:[_debts filteredArrayUsingPredicate:predicate2]]];
        //NSLog(@"Storlekten på arr: %lu", (unsigned long)[arr count]);
        if ([[arr objectAtIndex:0] count] == 0) {
            NSLog(@"Index 0 har storleken 0");
        }
        
        [_debtsToPerson addObject:arr];

        /*
        
        NSLog(@"Storlekten på _debtsToPerson: %lu", (unsigned long)[_debtsToPerson count]);
    
        //NSLog(@"Storlek: %@",[[[[_debtsToPerson objectAtIndex:0] objectAtIndex:0] objectAtIndex:0] amount]);

        
        for (int i = 0; i < [_debtsToPerson count]; i++) {
            for (int j = 0; j < [[_debtsToPerson objectAtIndex:i] count]; j++) {
                for (int k = 0; k < [[[_debtsToPerson objectAtIndex:i] objectAtIndex:j] count]; k++) {
                    NSLog(@"Skuld: %@",[[[[_debtsToPerson objectAtIndex:i] objectAtIndex:j] objectAtIndex:k] toName]);

                }
                NSLog(@"------------");
            }
        }
         */
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqual: @"Inga skulder"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toDebtDeatilsViewController"]) {
        DebtDetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.debts = sender;
        
    }
}


@end








