//
//  ETTabBarController.h
//  Events
//
//  Created by Justin Yu on 2/7/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETTabBarController : UITabBarController

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage *)buttonImage highlightImage:(UIImage *)highlightImage;

@end
