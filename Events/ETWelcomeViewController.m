//
//  ETWelcomeViewController.m
//  Events
//
//  Created by Justin Yu on 2/7/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "ETWelcomeViewController.h"
#import "LoginViewController.h"
#import "ETEventsTableViewController.h"
#import "AppDelegate.h"

#import <Parse/Parse.h>


@interface ETWelcomeViewController () <LoginViewControllerDelegate>

@end

@implementation ETWelcomeViewController

- (void)presentLoginViewController {
    LoginViewController *lvc = (LoginViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    
    [self presentViewController:lvc animated:NO completion:^{
        NSLog(@"Presented Login VC");
    }];
}

- (void)presentEventsViewController {
    UINavigationController *nvc = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"EventsNVC"];
    [self presentViewController:nvc animated:NO completion:^{
        NSLog(@"presented Events VC");
    }];
}

#pragma mark - LoginViewControllerDelegate

- (void)logInViewControllerDidLogUserIn:(LoginViewController *)logInViewController {
    
}

#pragma mark - VC Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![PFUser currentUser]) {
        NSLog(@"inside");
        [self presentLoginViewController];
        return;
    }
    
    [self presentEventsViewController];
    
    //[[PFUser currentUser] fetchInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
