//
//  UploadPhotoViewController.h
//  Advent
//
//  Created by Justin Yu on 2/8/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface UploadPhotoViewController : UIViewController

@property (strong, nonatomic) UIImage *stillImage;
@property (strong, nonatomic) NSString *eventID;
@property (strong, nonatomic) UIImage *croppedImage;
@property (strong, nonatomic) UIImage *resizedImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *croppedImageDisplay;


@end

@protocol UploadPhotoViewControllerDelegate <NSObject>

- (void)didFinishUploadingPhotoWithVC:(UploadPhotoViewController *)upvc;

@end