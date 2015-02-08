//
//  ThumbnailViewController.m
//  Advent
//
//  Created by Justin Yu on 2/8/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "ThumbnailViewController.h"

@interface ThumbnailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageDisplayView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation ThumbnailViewController

- (IBAction)touchCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchUploadButton:(id)sender {
    
}

- (IBAction)captureImage:(id)sender {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
