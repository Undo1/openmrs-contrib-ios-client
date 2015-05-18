//
//  EncounterViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/4/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "EncounterViewController.h"
#import "OpenMRSAPIManager.h"
#import "MRSEncounterOb.h"
@implementation EncounterViewController
- (void)setEncounter:(MRSEncounter *)encounter
{
    _encounter = encounter;
    self.title = self.encounter.displayName;
    if (encounter.obs == nil) {
        [self refreshData];
    }
}
- (void)refreshData
{
    [OpenMRSAPIManager getDetailedDataOnEncounter:self.encounter completion:^(NSError *error, MRSEncounter *detailedEncounter) {
        if (error != nil) {
        }
        else {
            self.encounter = detailedEncounter;
            NSLog(@"obs: %@", self.encounter.obs);
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
            });
        }
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.encounter.obs.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    MRSEncounterOb *ob = self.encounter.obs[indexPath.row];
    cell.textLabel.text = ob.display;
    cell.textLabel.numberOfLines = 0;
    return cell;
}
@end
