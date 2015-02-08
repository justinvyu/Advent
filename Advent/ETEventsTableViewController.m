//
//  ETEventsTableViewController.m
//  Events
//
//  Created by Justin Yu on 2/7/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "ETEventsTableViewController.h"
#import "ETPhotosTableViewController.h"

#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>

#import <Parse/Parse.h>

@interface ETEventsTableViewController () <UITableViewDataSource>

@property (strong, nonatomic) NSArray *events;

@end

@implementation ETEventsTableViewController

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
    
    self.title = @"Events";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self loadData];
}

- (void)loadData {
    
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *userInfo = (NSDictionary *)result;
            
            NSString *name = userInfo[@"name"];
            NSString *location = userInfo[@"location"][@"name"];
            NSString *birthday = userInfo[@"birthday"];
            NSString *facebookID = userInfo[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            // Do something with this data later
            
        }
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.events = objects;
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
    return [self.events count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Event" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self.events[indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [self.events[indexPath.row] objectForKey:@"desc"];
    //NSLog(@"%@", [self.events[indexPath.row] objectForKey:@"name"]);
    
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
    
    if ([segue.identifier isEqualToString:@"Show Photos"]) {
        if ([segue.destinationViewController isKindOfClass:[ETPhotosTableViewController class]]) {
            ETPhotosTableViewController *etvc = (ETPhotosTableViewController *)segue.destinationViewController;
            NSIndexPath *path = [self.tableView indexPathForSelectedRow];
            etvc.eventID = ((PFObject *)(self.events[path.row])).objectId;
            etvc.name = [self.tableView cellForRowAtIndexPath:path].textLabel.text;
            //NSLog(@"ObjectID: %@", ((PFObject *)(self.events[path.row])).objectId);
            NSLog(@"%@", ((PFObject *)(self.events[path.row])).objectId);
        }
    }
}


@end
