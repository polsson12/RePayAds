//
//  UIViewController+DebtDetailsViewController.h
//  RePay
//
//  Created by Philip Olsson on 2014-12-08.
//  Copyright (c) 2014 Philip Olsson. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface DebtDetailsViewController : UIViewController<UITableViewDataSource, UITabBarDelegate, UIAlertViewDelegate>{
    NSInteger selectedRow;
}

@property (weak, nonatomic) IBOutlet UITableView *debtDetailsTableView;
@property (strong, atomic) NSMutableArray* debts;
@property (weak, nonatomic) IBOutlet UILabel *differanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;



- (void) calculateAmount;

@end
