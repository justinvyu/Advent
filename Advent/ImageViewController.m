//
//  ImageViewController.m
//  Advent
//
//  Created by Justin Yu on 2/8/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "ImageViewController.h"
#import <Parse/Parse.h>

@interface ImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation ImageViewController

- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    
    NSLog(@"%@", titleString);
    
}

- (void)setDescriptionString:(NSString *)descriptionString {
    _descriptionString = descriptionString;
    
    NSLog(@"%@", descriptionString);
    
    self.descriptionLabel.text = descriptionString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.titleString;
    
}

- (void)setObjectId:(NSString *)objectId {
    _objectId = objectId;
    [self loadData];
}

- (void)loadData {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    
    NSLog(@"%@", self.objectId);
    /*PFObject *picture = [query getObjectWithId:self.objectId];
    
    if (picture) {
        NSLog(@"not nil");
    }*/
    //self.imv.image = [picture objectForKey:@"image"];
    
    
    [query getObjectInBackgroundWithId:self.objectId block:^(PFObject *object, NSError *error) {
        if (!error) {
            self.titleLabel.text = [object objectForKey:@"title"];
            self.descriptionLabel.text = [object objectForKey:@"desc"];
            PFFile *imageFile = [object objectForKey:@"image"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    self.imv.image = [UIImage imageWithData:data];
                    
                }
            }];
        }
    }];
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
