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
#import "UploadPhotoViewController.h"

@interface ImageCaptureViewController () <UploadPhotoViewControllerDelegate>

// Storyboard Outlets
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageDisplayView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;

// For upload
@property (strong, nonatomic) PFFile *imageFile;

@property (strong, nonatomic) AVCaptureSession *session;


// Utils
@property (nonatomic) BOOL captureModeOn;

@end

@implementation ImageCaptureViewController

- (void)didFinishUploadingPhotoWithVC:(UploadPhotoViewController *)upvc {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self changeMode];
}

#pragma mark - Properties

- (void)setStillImage:(UIImage *)stillImage {
    _stillImage = stillImage;
    
    self.imageDisplayView.image = stillImage;
}

#pragma mark - Actions

- (IBAction)touchCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takeStillImage:(id)sender {
        dispatch_async([self sessionQueue], ^{
            // Update the orientation on the still image output video connection before capturing.
            [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo]
             setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
            
            /*
             // Flash set to Auto for Still Capture
             [ImageCaptureViewController setFlashMode:self.flashOn ? AVCaptureFlashModeOn : AVCaptureFlashModeOff
             forDevice:[[self videoDeviceInput] device]];
             */

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

#pragma mark - VC Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    
    self.previewView.session = session;
    
    // Properties
    self.captureModeOn = YES;
    
    self.nextButton.hidden = YES;
    
    // Not good to do all session initialization on the main queue, blocks UI b/c of [session startRunning]
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL); // "line" queue
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        
        
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Upload Photo"]) {
        if ([segue.destinationViewController isKindOfClass:[UploadPhotoViewController class]]) {
            UploadPhotoViewController *upvc = (UploadPhotoViewController *)segue.destinationViewController;
            
            upvc.stillImage = self.stillImage ? self.stillImage : nil;
            upvc.eventID = self.eventID;
        }
    }
}

#pragma mark - Change Mode

- (void)changeMode {
    if (self.captureModeOn) {
        self.previewView.hidden = YES;
        
        self.captureModeOn = NO;
        self.imageDisplayView.hidden = NO;
        self.captureButton.hidden = YES;
        self.nextButton.hidden = NO;
        
    } else {
        self.previewView.hidden = NO;
        
        self.nextButton.hidden = YES;
        self.captureButton.hidden = NO;
        self.stillImage = nil;
        self.croppedImage = nil;
        self.resizedImage = nil;
        
        self.imageDisplayView.hidden = YES;
        self.imageDisplayView.image = nil;
        
        self.captureModeOn = YES;
    }
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
