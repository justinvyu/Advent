//
//  ImageCaptureViewController.h
//  Events
//
//  Created by Justin Yu on 2/7/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AVCamPreviewView.h"

@interface ImageCaptureViewController : UIViewController

@property (strong, nonatomic) NSString *eventID;

- (void)changeMode;
@property (strong, nonatomic) dispatch_queue_t sessionQueue;
// Input/Output
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;
// Image Things
@property (strong, nonatomic) UIImage *stillImage;
@property (strong, nonatomic) UIImage *croppedImage;
@property (strong, nonatomic) UIImage *resizedImage;

@property (weak, nonatomic) IBOutlet AVCamPreviewView *previewView;

@end

