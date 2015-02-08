//
//  ImageCaptureViewController.m
//  Events
//
//  Created by Justin Yu on 2/7/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "ImageCaptureViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>
#import "AVCamPreviewView.h"
#import "UIImage+ResizeAdditions.h"

@interface ImageCaptureViewController ()

// Storyboard Outlets
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet AVCamPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *imageDisplayView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

// Image Things
@property (strong, nonatomic) UIImage *stillImage;
@property (strong, nonatomic) UIImage *croppedImage;
@property (strong, nonatomic) UIImage *resizedImage;

// For upload
@property (strong, nonatomic) PFFile *imageFile;


@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) dispatch_queue_t sessionQueue;

// Input/Output
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;

// Background Task ID
@property (nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

// Utils
@property (nonatomic) BOOL captureModeOn;

@end

@implementation ImageCaptureViewController

#pragma mark - Properties

- (void)setStillImage:(UIImage *)stillImage {
    _stillImage = stillImage;
    
    self.imageDisplayView.image = stillImage;
}

#pragma mark - Actions

- (IBAction)touchCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchNextButton:(id)sender {
    
}

#pragma mark - VC Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    
    self.previewView.session = session;
    
    // Properties
    self.captureModeOn = YES;
    
    // Tap Gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.previewView addGestureRecognizer:tap];
    
    // Not good to do all session initialization on the main queue, blocks UI b/c of [session startRunning]
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL); // "line" queue
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid; // initialize as invalid, "nil"
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [ImageCaptureViewController deviceWithMediaType:AVMediaTypeVideo
                                                                    preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error) {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput]) {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
        }
        
        // Get the Still Image Output
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput]) {
            // Set the compress / decompress coder / decoder to use JPEG format
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //self.tabBarController.tabBar.hidden = YES;
    
    dispatch_async([self sessionQueue], ^{
        [[self session] startRunning];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    //self.tabBarController.tabBar.hidden = NO;
    
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
    });
}

#pragma mark - Change Mode

- (void)changeMode {
    if (self.captureModeOn) {
        self.previewView.hidden = YES;
        
        self.captureModeOn = NO;
        self.imageDisplayView.hidden = NO;
        
        [self shouldUploadImage];
    } else {
        self.previewView.hidden = NO;

        self.stillImage = nil;
        self.croppedImage = nil;
        self.resizedImage = nil;
        
        self.imageDisplayView.hidden = YES;
        self.imageDisplayView.image = nil;
        
        self.captureModeOn = YES;
    }
}

#pragma mark - Image Upload

- (BOOL)shouldUploadImage {
    UIImage *resizedStillImage = [self.stillImage resizedImage:CGSizeMake(self.view.bounds.size.width,
                                                                          self.view.bounds.size.height)
                                          interpolationQuality:kCGInterpolationHigh];
    
    CGFloat padding = (self.view.bounds.size.height - self.view.bounds.size.width) / 2;
    
    self.croppedImage = [resizedStillImage croppedImage:CGRectMake(0,
                                                                   padding,
                                                                   self.view.bounds.size.width,
                                                                   self.view.bounds.size.width)];
    
    self.resizedImage = [self.croppedImage resizedImage:CGSizeMake(600, 600) // 600x600 px
                                   interpolationQuality:kCGInterpolationHigh];
    
    NSData *imageData = UIImageJPEGRepresentation(self.resizedImage, 1.0f);
    
    if (!imageData) {
        return NO;
    }
    
    self.imageFile = [PFFile fileWithData:imageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %lu for photo upload", (unsigned long)self.fileUploadBackgroundTaskId);
    [self.imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        } else {
            NSLog(@"Failed");
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}


#pragma mark - UITapGestureRecognizer

- (void)handleTap:(UIGestureRecognizer *)gesture {
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo]
         setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
        
        /*
        // Flash set to Auto for Still Capture
        [ImageCaptureViewController setFlashMode:self.flashOn ? AVCaptureFlashModeOn : AVCaptureFlashModeOff
                                       forDevice:[[self videoDeviceInput] device]];
        */
        
        // Capture a still image.
        // To do: animate the capture
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo]
                                                             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                                 
             if (imageDataSampleBuffer)
             {
                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                 // send over image and present edit vc
                 UIImage *captureImage = [UIImage imageWithData:imageData];
                 
                 if (!captureImage)
                     return;
                 
                 self.stillImage = captureImage;
                 
                 if (self.stillImage) {
                     NSLog(@"not nil");
                 }
                 /*
                 [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                     if (error) {
                         NSLog(@"Unable to get Location");
                     } else {
                         self.coordinate = geoPoint;
                         NSLog(@"Location is Set");
                     }
                 }];
                 */
                 [self changeMode];
             }
         }];
    });

}

#pragma mark - Get the video device for a specified media type

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    // Get the preferred camera
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

@end
