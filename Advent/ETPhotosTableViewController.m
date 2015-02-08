//
//  ETPhotosTableViewController.m
//  Events
//
//  Created by Justin Yu on 2/7/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "ETPhotosTableViewController.h"
#import <Parse/Parse.h>
#import "ImageCaptureViewController.h"
#import "ImageViewController.h"

@interface ETPhotosTableViewController () <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *photos;

@end

@implementation ETPhotosTableViewController

- (void)setName:(NSString *)name {
    self.title = name;
    _name = name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(loadData)
                  forControlEvents:UIControlEventValueChanged];
    
    [self loadData];
}

- (void)loadData {
    NSMutableArray *mutablePhotoArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    
    [query includeKey:@"event"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            PFObject *event = object[@"event"];
            //NSLog(@"%@", event.objectId);
            if ([event.objectId isEqualToString:self.eventID]) {
                [mutablePhotoArray addObject:object];
            }
        }
        self.photos = mutablePhotoArray;
        [self.tableView reloadData];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self.photos[indexPath.row] objectForKey:@"title"];
    cell.detailTextLabel.text = [self.photos[indexPath.row] objectForKey:@"desc"];
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"Take Picture"]) {
        if ([segue.destinationViewController isKindOfClass:[ImageCaptureViewController class]]) {
            ImageCaptureViewController *icvc = (ImageCaptureViewController *)segue.destinationViewController;
            icvc.eventID = self.eventID;
        }
    } else if ([segue.identifier isEqualToString:@"Show Picture"]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
            ImageViewController *ivc = (ImageViewController *)segue.destinationViewController;
            ivc.objectId = ((PFObject *)self.photos[path.row]).objectId;
            ivc.titleString = [self.photos[path.row] objectForKey:@"title"];
            ivc.descriptionString = [self.photos[path.row] objectForKey:@"desc"];
        }
    }
}


@end
