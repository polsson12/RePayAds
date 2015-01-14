//
//  UIViewController+ShowDebtViewController.h
//  RePay
//
//  Created by Philip Olsson on 2014-12-08.
//  Copyright (c) 2014 Philip Olsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Debt.h"


@interface ShowDebtViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>

//Table view
@property (weak, nonatomic) IBOutlet UITableView *showDeptsTableView;


@property (strong, nonatomic) NSMutableArray *debts;
@property (strong, nonatomic) NSMutableArray *debtsToPerson;
@property (strong, nonatomic) NSMutableArray *uniqueFbIds;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;



- (void) fetchDeptsForUser;
- (void) sortDepts;

@end