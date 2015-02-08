//
//  UploadPhotoViewController.m
//  Advent
//
//  Created by Justin Yu on 2/8/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "UploadPhotoViewController.h"

#import "UIImage+ResizeAdditions.h"
#import "ImageCaptureViewController.h"

@interface UploadPhotoViewController () <UITextViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) PFFile *imageFile;
@property (strong, nonatomic) PFFile *thumbnailFile;


@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (nonatomic) BOOL locked;



// Background Task ID
@property (nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@property (strong, nonatomic) PFGeoPoint *location;
@property (strong, nonatomic) PFObject *event;

@end

@implementation UploadPhotoViewController

- (IBAction)touchCancelButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setCroppedImage:(UIImage *)croppedImage {
    _croppedImage = croppedImage;
    
    self.croppedImageDisplay.image = croppedImage;
}

- (void)keyboardWillShow:(NSNotification *)note {
    if (!self.locked) {
        CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGSize scrollViewContentSize = self.scrollView.bounds.size;
        scrollViewContentSize.height += keyboardFrameEnd.size.height;
        [self.scrollView setContentSize:scrollViewContentSize];
        
        CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
        // Align the bottom edge of the photo with the keyboard
        scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height*3.2f - [UIScreen mainScreen].bounds.size.height;
        
        [self.scrollView setContentOffset:scrollViewContentOffset animated:NO];
        
        self.locked = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
    self.locked = NO;
}

#pragma mark - UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextFieldDelegate

- (IBAction)touchUploadButton:(id)sender {
    
    if (!self.titleTextField.text || [self.titleTextField.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Couldn't upload photo"
                                    message:@"Make sure you have a title"
                                   delegate:self
                           cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    } else if (!self.imageFile) {
        [[[UIAlertView alloc] initWithTitle:@"Couldn't upload photo"
                                    message:@"Don't have an image"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    PFObject *photo = [PFObject objectWithClassName:@"Photo"];
    [photo setObject:self.imageFile forKey:@"image"];
    /*
    if (self.location) {
        [photo setObject:self.location forKey:@"location"];
    }
     */
    [photo setObject:self.thumbnailFile forKey:@"thumbnail"];
    [photo setObject:[PFUser currentUser] forKey:@"user"];
    [photo setObject:self.titleTextField.text forKey:@"title"];
    [photo setObject:self.descriptionTextView.text forKey:@"desc"];
    [photo setObject:self.event forKey:@"event"];
    
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading
    // the photo even if the app is sent to the background
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        [self dismissViewControllerAnimated:YES completion:nil];
        [((ImageCaptureViewController *)self.presentingViewController) changeMode];
    }];
}

#pragma mark - Image Upload

- (BOOL)shouldUploadImage {
    if (!self.stillImage) {
        return NO;
    }
    
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
    
    UIImage *thumbnailImage = [self.croppedImage thumbnailImage:150 transparentBorder:1 cornerRadius:3 interpolationQuality:kCGInterpolationHigh];
    
    NSData *imageData = UIImageJPEGRepresentation(self.resizedImage, 0.9f);
    NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 0.9f);
    
    if (!imageData || !thumbnailData) {
        return NO;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:@"objectId" equalTo:self.eventID];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.event = (PFObject *)[objects firstObject];
        }
    }];
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"Location is set");
            self.location = geoPoint;
        } else {
            NSLog(@"Couldn't get location");
        }
    }];
    
    self.imageFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %lu for photo upload", (unsigned long)self.fileUploadBackgroundTaskId);
    [self.imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Thumbnail uploaded successfully");
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            NSLog(@"Failed");
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}

#pragma mark - VC Lifecycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [self.titleTextField resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
    
    if (self.scrollView.bounds.size.height != self.view.bounds.size.height) {
        CGSize scrollViewContentSize = self.view.bounds.size;
        [UIView animateWithDuration:0.200f animations:^{
            [self.scrollView setContentSize:scrollViewContentSize];
        }];
        
        self.locked = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.descriptionTextView.layer.cornerRadius = 5.0f;
    
    self.descriptionTextView.layer.borderWidth = 1.0f;
    self.descriptionTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.titleTextField.delegate = self;
    self.descriptionTextView.delegate = self;
    
    self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid; // initialize as invalid, "nil"
    self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    
    [self shouldUploadImage];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.scrollView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Hide Status Bar

// Remember to set:
//      View controller-based status bar appearance to NO in Info.plist
//      Status bar is initially hidden to NO in Info.plist

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
