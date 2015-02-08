//
//  LoginViewController.h
//  Events
//
//  Created by Justin Yu on 2/7/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>

@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController <FBLoginViewDelegate>

@property (nonatomic, assign) id<LoginViewControllerDelegate> delegate;

@end

@protocol LoginViewControllerDelegate <NSObject>

- (void)logInViewControllerDidLogUserIn:(LoginViewController *)logInViewController;

@end