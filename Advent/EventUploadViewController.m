//
//  EventUploadViewController.m
//  Advent
//
//  Created by Justin Yu on 2/8/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "EventUploadViewController.h"
#import <Parse/Parse.h>

@interface EventUploadViewController () <UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *croppedImageDisplay;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;

@property (nonatomic) BOOL locked;



@property (nonatomic) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@end

@implementation EventUploadViewController

- (IBAction)touchCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapToTakePicture:(id)sender {
    [self performSegueWithIdentifier:@"Take Picture" sender:self.croppedImageDisplay];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    
    self.descriptionTextField.layer.cornerRadius = 5.0f;
    
    self.descriptionTextField.layer.borderWidth = 1.0f;
    self.descriptionTextField.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.titleTextField.delegate = self;
    self.descriptionTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.titleTextField resignFirstResponder];
    return YES;
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

- (IBAction)touchUploadButton:(id)sender {
    if ([self.titleTextField.text isEqualToString:@""] || !self.titleTextField.text) {
        [[[UIAlertView alloc] initWithTitle:@"Cannot upload image" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    } else if ([self.descriptionTextField.text isEqualToString:@""] || !self.descriptionTextField) {
        [[[UIAlertView alloc] initWithTitle:@"Cannot upload image" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    PFObject *event = [PFObject objectWithClassName:@"Event"];
    
    /*NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"thumbnail"], 0.7f);
    PFFile *thumbnail = [PFFile fileWithData:imageData];
    
    [thumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"saved fake thumbnail");
        }
    }];*/
    
    [event setObject:self.titleTextField.text forKey:@"name"];
    [event setObject:self.descriptionTextField.text forKey:@"desc"];
    //[event setObject:thumbnail forKey:@"thumbnail"];
    
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Event uploaded to Parse");
        } else {
            NSLog(@"Error in uploading to Parse");
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    /*
    if ([segue.identifier isEqualToString:@"Take Picture"]) {
        if (segue.destinationViewController isKindOfClass:[]) {
            <#statements#>
        }
    }
     */
}


@end
