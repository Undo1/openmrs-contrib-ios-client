//
//  PatientVisitListView.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/2/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "PatientVisitListView.h"
#import "MRSVisit.h"
#import "MRSVisitCell.h"

@implementation PatientVisitListView
- (void)setVisits:(NSArray *)visits
{
    _visits = visits;
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateFontSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [MRSVisitCell updateTableViewForDynamicTypeSize:self.tableView];

    self.title = NSLocalizedString(@"Visits", @"Label visits");
}

- (void)updateFontSize {
    [MRSVisitCell updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MRSVisitCell updateTableViewForDynamicTypeSize:self.tableView];
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
    MRSVisitCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[MRSVisitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    MRSVisit *visit = self.visits[indexPath.row];
    [cell setVisit:visit];
    [cell setIndex:[NSNumber numberWithInteger:indexPath.row+1]];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    cell.userInteractionEnabled = NO;
    return cell;
}
@end
