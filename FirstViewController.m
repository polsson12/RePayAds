//
//  UIViewController+FirstViewController.m
//  RePay
//
//  Created by Philip Olsson on 2014-11-25.
//  Copyright (c) 2014 Philip Olsson. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"


@interface FirstViewController (){

    BOOL showAd;
    

}

@property(nonatomic, strong) GADInterstitial *interstitial;


@end

@implementation FirstViewController


@synthesize user = _user;



- (void)viewDidLoad {
    NSLog(@"VIIIIIIEWWWWWWWW DID LOAD....................................................");
    [self createAndLoadInterstitial];
    
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    //[self.navigationItem setBackBarButtonItem:nil];

    [self.navigationItem setHidesBackButton:YES];


    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    infoButton.frame = CGRectMake(0, 0, 80, 35);
    [infoButton setTitle:@"Logga ut" forState:UIControlStateNormal];
    [infoButton setTitleColor:[UIColor colorWithRed:77.0/255.0 green:175.0/255.0 blue:231.0/255.0 alpha:1] forState:UIControlStateNormal];
    [infoButton setTitleColor:[UIColor colorWithRed:77.0/255.0 green:175.0/255.0 blue:231.0/255.0 alpha:0.3] forState:UIControlStateHighlighted];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [infoButton addTarget:self action:@selector(logoutPressed) forControlEvents:UIControlEventTouchUpInside];
    
  
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createAndLoadInterstitial)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    

    if ([PFUser currentUser] == nil){
        [self.navigationController popViewControllerAnimated:YES];
        showAd = NO;
    }
    
    //Button graphics
    _CreateDebt.layer.cornerRadius = 6;
    _CreateDebt.layer.shadowOpacity = 0.3;

    _ShowDebt.layer.cornerRadius = 6;
    _ShowDebt.layer.shadowOpacity = 0.3;
    
    //Set the label to display the number of unconfirmed depts
    _numOfNewDetps.layer.masksToBounds = YES;
    _numOfNewDetps.layer.cornerRadius = 11;
    _numOfNewDetps.text = @"";
    _numOfNewDetps.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewDidLoad];
    
    
    
    [self controlCurrentUser];
    [self controlCurrentUserInstall];
    
    
    NSLog(@"3current user facebook ID: %@", [[PFUser currentUser] objectForKey:@"fbId"]);
    
    PFQuery *unconfirmedDepts = [PFQuery queryWithClassName:@"Debts"];
    [unconfirmedDepts whereKey:@"toFbId" equalTo:[[PFUser currentUser] objectForKey:@"fbId"]];

    [unconfirmedDepts whereKey:@"approved" equalTo:@NO];
    
    
    [unconfirmedDepts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {//No error
            if ([objects count] == 0) {
                _numOfNewDetps.text = @"";
                _numOfNewDetps.hidden = YES;
            }
            else if ([objects count] <= 10) {
                NSLog(@"Kommer hit....");
                _numOfNewDetps.text = [NSString stringWithFormat:@"%lu",(unsigned long)[objects count]];
                _numOfNewDetps.hidden = NO;
            }else{
            _numOfNewDetps.text = @"10+";
            _numOfNewDetps.hidden = NO;

            }
        }
        else{ //some error
            UIAlertView *error = [[UIAlertView alloc]
                                  initWithTitle:@"Fel inträffade" message:@"Ett fel inträffade, kontrollera din internet anslutning eller försök igen senare." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [error show];
        }
        
        NSLog(@"Antalet unfirmed depts: %lu",(unsigned long) [objects count]);
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        if ([PFUser currentUser] != nil) {
        NSLog(@"Loggar ut...");
        [PFUser logOut];
        _user = [PFUser currentUser];
        }
    }
    // parent is nil if this view controller was removed
}*/

#pragma mark buttons functions
- (IBAction)CreateDebtButton:(id)sender {
    
}

- (IBAction)ShowDebtButton:(id)sender {
}

- (IBAction)infoButton:(id)sender {
    [self performSegueWithIdentifier:@"toInfoView1" sender:self];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toInfoView1"]) {
        infoOneViewController *info1View = [segue destinationViewController];
        info1View.user = [PFUser currentUser];
    }
}

#pragma mark ads functions

- (void) createAndLoadInterstitial {
//- (GADInterstitial *)createAndLoadInterstitial {
    NSLog(@"LADAR EN AD");
    self.interstitial = [[GADInterstitial alloc] init];
    GADRequest *request = [GADRequest request];
    NSLog(@"HÄÄR");
    //request.testDevices = @[ GAD_SIMULATOR_ID, @"7ebd577f503ea3da2610888aeb1bb0ac" ];
    self.interstitial.adUnitID = @"ca-app-pub-8771089887645531/2510910809";
    self.interstitial.delegate = self;
    [self.interstitial loadRequest:request];
    NSLog(@"Kommer hit också..");
    //return interstitial;
}



- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"Får tillbaka en add..");
    if ([ad isReady]){
        [ad presentFromRootViewController:self.navigationController.topViewController];
    }
}

#pragma mark control functions

-(void) controlCurrentUser {
    if (!([[PFUser currentUser] objectForKey:@"fbId"] || [[PFUser currentUser] objectForKey:@"fbName"])) {
        [PFUser logOut];
        _user = [PFUser currentUser];
        [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"Någonting hände...Loggar ut användaren..");
    }
}

-(void) controlCurrentUserInstall {
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (currentInstallation[@"fbId"] != [[PFUser currentUser] objectForKey:@"fbId"]) {
        currentInstallation[@"fbId"] = [[PFUser currentUser] objectForKey:@"fbId"];
        [currentInstallation saveEventually];
    }
}

- (void) logoutPressed{
    [[[UIAlertView alloc] initWithTitle:@"Logga ut"
                                message:@"Vill du verkligen logga ut från RePay?"
                               delegate:self
                      cancelButtonTitle:@"Avbryt"
                      otherButtonTitles:@"Logga ut",nil] show];
}

- (void) logoutUser {
    NSLog(@"Loggar ut...");
    if ([PFUser currentUser] != nil) {
        NSLog(@"Loggar ut...");
        [PFUser logOut];
        _user = [PFUser currentUser];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];

    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqual:@"Logga ut"]) {
        if (buttonIndex == 0) { //Avbryt        (Cancel)
            NSLog(@"Avbryt...");
            
        }
        else if(buttonIndex == 1){  //Godkänn   (approve)
            [self logoutUser];
        }
    }
}




@end