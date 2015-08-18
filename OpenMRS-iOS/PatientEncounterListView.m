//
//  PatientEncounterListView.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/2/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "PatientEncounterListView.h"
#import "MRSEncounter.h"
#import "EncounterViewController.h"
#import "MRSHelperFunctions.h"
#import "AppDelegate.h"

@implementation PatientEncounterListView

-(id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.tabBarItem.title = NSLocalizedString(@"Encounters", "Label encounters");
        self.tabBarItem.image = [UIImage imageNamed:@"vitals_icon"];
    }
    return self;
}

- (void)setEncounters:(NSArray *)encounters
{
    _encounters = encounters;
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateFontSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
    
    self.title = NSLocalizedString(@"Encounters", "Label encounters");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)updateFontSize {
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.encounters.count == 0) {
        UILabel *backgroundLabel = [[UILabel alloc] init];
        backgroundLabel.textAlignment = NSTextAlignmentCenter;
        backgroundLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"No Encounters", @"Label -no- -encounters-")];
        self.tableView.backgroundView = backgroundLabel;
    } else {
        self.tableView.backgroundView = nil;
    }
    return self.encounters.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    MRSEncounter *encounter = self.encounters[indexPath.row];
    cell.textLabel.text = encounter.displayName;
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRSEncounter *encounter = self.encounters[indexPath.row];
    EncounterViewController *vc = [[EncounterViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.encounter = encounter;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.encounters forKey:@"encounters"];
    [super encodeRestorableStateWithCoder:coder];
}

#pragma mark - UIViewRestoartion

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    PatientEncounterListView *encounterVC = [[PatientEncounterListView alloc] initWithStyle:UITableViewStyleGrouped];
    encounterVC.restorationIdentifier = [identifierComponents lastObject];
    encounterVC.encounters = [coder decodeObjectForKey:@"encounters"];
    return encounterVC;
}
@end
