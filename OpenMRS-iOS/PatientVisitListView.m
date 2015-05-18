//
//  PatientVisitListView.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/2/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "PatientVisitListView.h"
#import "MRSVisit.h"

@implementation PatientVisitListView
- (void)setVisits:(NSArray *)visits
{
    _visits = visits;
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    self.title = @"Visits";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.visits.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    MRSVisit *visit = self.visits[indexPath.row];
    cell.textLabel.text = visit.displayName;
    cell.textLabel.numberOfLines = 0;
    return cell;
}
@end
