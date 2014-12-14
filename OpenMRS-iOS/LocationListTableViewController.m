//
//  LocationListTableViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/12/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "LocationListTableViewController.h"
#import "MRSLocation.h"
#import "OpenMRSAPIManager.h"

@interface LocationListTableViewController ()

@end

@implementation LocationListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Choose Location";
    
    [self refreshData];
}
- (void)refreshData
{
    [OpenMRSAPIManager getLocationsWithCompletion:^(NSError *error, NSArray *locations) {
        if (!error)
        {
            self.locations = locations;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    MRSLocation *location = self.locations[indexPath.row];
    cell.textLabel.text = location.display;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRSLocation *location = self.locations[indexPath.row];
    [self.delegate didChooseLocation:location];
}
@end
