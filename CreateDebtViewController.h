//
//  UIViewController+CreateDebtViewController.h
//  RePay
//
//  Created by Philip Olsson on 2014-12-02.
//  Copyright (c) 2014 Philip Olsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface Person : NSObject
    @property NSString *fbId;
    @property NSString *name;

@end

@implementation Person

- (instancetype)init
{
    self = [super init];
    if (self) {
        //TODO: what here? if anything at al?
    }
    return self;
}

@end


@interface CreateDebtViewController :UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

#pragma mark CreateDebt ViewController
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;
@property (weak, nonatomic) IBOutlet UITableView *informationTableView;

@property (strong, nonatomic) NSMutableArray *friendInfo;

@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) Person *sendToPerson;

@property (strong, nonatomic) NSString *toName;

@property (strong, nonatomic) UITextField *activeKeyboard;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


- (IBAction)dissMissKeyboardOnTap:(id)sender;
- (void) getAllFbFriendsOfUserUsingApp;
- (void) deptToPerson:(NSInteger) index;

@end