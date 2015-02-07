//
//  LoginViewController.m
//  Events
//
//  Created by Justin Yu on 2/7/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FBLoginView *loginView = [[FBLoginView alloc] init];
    loginView.center = self.view.center;
    [self.view addSubview:loginView];
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