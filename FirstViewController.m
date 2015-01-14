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


/*- (void) viewDidAppear:(BOOL)animated {
    if (showAd) {
        if ([self.interstitial isReady]){
            [self.interstitial presentFromRootViewController:self];
        }else {
            NSLog(@"Ska inte komma hit..");
        }
    }
}*/


- (void)viewDidLoad {
    NSLog(@"VIIIIIIEWWWWWWWW DID LOAD....................................................");
    [self createAndLoadInterstitial];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createAndLoadInterstitial)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    

    if ([PFUser currentUser] == nil){
        [self.navigationController popViewControllerAnimated:YES];
        showAd = NO;
    }
    _CreateDebt.layer.cornerRadius = 6;
    _CreateDebt.layer.shadowOpacity = 0.3;

    //_CreateDebt.layer.borderWidth = 1;
    _ShowDebt.layer.cornerRadius = 6;
    _ShowDebt.layer.shadowOpacity = 0.3;
    //_ShowDebt.layer.borderWidth = 1;
    //_CreateDebt.layer.borderColor = [UIColor blueColor].CGColor;
    //[[UIBarButtonItem alloc] initWithTitle:@"Logga ut" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //Set the label to display the number of unconfirmed depts
    _numOfNewDetps.layer.masksToBounds = YES;
    _numOfNewDetps.layer.cornerRadius = 11;
    _numOfNewDetps.text = @"";
    _numOfNewDetps.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewDidLoad];
    
    
    
    
    
    /*if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        NSLog(@"Är länkad med facebook");
    }
    else {
        NSLog(@"ÄR inte länkad med facebook");
    }*/
    
    
    
    //TODO: IMPORTANT!!!!!!! What if PFUser is NULL?
    NSLog(@"ska sätta back item title...");
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


- (IBAction)CreateDebtButton:(id)sender {
    
    NSLog(@"Skapa skuld...");
    
    
}

- (IBAction)ShowDebtButton:(id)sender {
    NSLog(@"Visa skulder...");
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        if ([PFUser currentUser] != nil) {
        NSLog(@"Loggar ut...");
        [PFUser logOut];
        _user = [PFUser currentUser];
        }
    }
    // parent is nil if this view controller was removed
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

#pragma mark adds functions

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

/*- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    //self.interstitial = [self createAndLoadInterstitial];
    [self createAndLoadInterstitial];
}*/

//BAKBAKADJSHDJSAHDJASHDH
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"Får tillbaka en add..");
    if ([ad isReady]){
        [ad presentFromRootViewController:self.navigationController.topViewController];

    }
}



@end