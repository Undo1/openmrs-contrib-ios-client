//
//  SelectPatientIdentifierTypeTableViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/11/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "SelectPatientIdentifierTypeTableViewController.h"
#import "MRSPatientIdentifierType.h"
#import "OpenMRSAPIManager.h"
@interface SelectPatientIdentifierTypeTableViewController ()

@end

@implementation SelectPatientIdentifierTypeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    self.title = NSLocalizedString(@"Identifier Type", @"Label -identifier- -type-");
    [self reloadData];
    
    //TODO: self-sizing cells
    self.tableView.rowHeight = 77;
}
- (void)reloadData
{
    [OpenMRSAPIManager getPatientIdentifierTypesWithCompletion:^(NSError *error, NSArray *types) {
        if (!error) {
            self.identifierTypes = types;
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
            });
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.identifierTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    MRSPatientIdentifierType *type = self.identifierTypes[indexPath.row];
    cell.textLabel.text = type.display;
    cell.detailTextLabel.text = type.typeDescription;
    cell.detailTextLabel.numberOfLines = 3;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRSPatientIdentifierType *type = self.identifierTypes[indexPath.row];
    [self.delegate didSelectPatientIdentifierType:type];
}
@end
