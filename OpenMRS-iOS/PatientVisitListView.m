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
#import "AppDelegate.h"

@implementation PatientVisitListView

-(id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.tabBarItem.title = NSLocalizedString(@"Visits", @"Label visits");
        self.tabBarItem.image = [UIImage imageNamed:@"active_visits_tab_bar_icon"];
    }
    return self;
}

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
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.visits forKey:@"visits"];
    [super encodeRestorableStateWithCoder:coder];
}

#pragma mark - UIViewControllerRestoration

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    PatientVisitListView *visitList = [[PatientVisitListView alloc] initWithStyle:UITableViewStyleGrouped];
    visitList.restorationIdentifier = [identifierComponents lastObject];
    visitList.visits = [coder decodeObjectForKey:@"visits"];
    return visitList;
}
@end
