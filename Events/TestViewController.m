//
//  TestViewController.m
//  Events
//
//  Created by Justin Yu on 2/7/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "TestViewController.h"
#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>

@interface TestViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imv;

@end

@implementation TestViewController

- (void)loadData {
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *userInfo = (NSDictionary *)result;
            
            NSString *name = userInfo[@"name"];
            NSString *location = userInfo[@"location"][@"name"];
            NSString *birthday = userInfo[@"birthday"];
            NSString *facebookID = userInfo[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSLog(@"%@, %@, %@", name, location, birthday);
            
            self.imv.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:pictureURL]];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view.
    
    [self loadData];
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
