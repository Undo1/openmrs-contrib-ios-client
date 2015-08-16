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
#import "MRSHelperFunctions.h"
#import "IdentifierTypeCell.h"
#import "MBProgressExtension.h"
#import "MRSAlertHandler.h"

@interface SelectPatientIdentifierTypeTableViewController ()

@property (nonatomic) BOOL failed;

@end

@implementation SelectPatientIdentifierTypeTableViewController

@synthesize rowDescriptor = _rowDescriptor;

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateFontSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [IdentifierTypeCell updateTableViewForDynamicTypeSize:self.tableView];

    self.title = NSLocalizedString(@"Identifier Type", @"Label -identifier- -type-");
    [self reloadData];
    
    //Getting the AddPatientForm
    self.delegate = self.navigationController.viewControllers[0];
    //TODO: self-sizing cells
    [self.tableView registerClass:[IdentifierTypeCell class] forCellReuseIdentifier:@"cell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [IdentifierTypeCell updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)updateFontSize {
    [IdentifierTypeCell updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)reloadData
{
    [MBProgressExtension showBlockWithTitle:NSLocalizedString(@"Loading", @"Label loading") inView:self.view];
    [OpenMRSAPIManager getPatientIdentifierTypesWithCompletion:^(NSError *error, NSArray *types) {
        [MBProgressExtension hideActivityIndicatorInView:self.view];
        if (!error) {
            [MBProgressExtension showSucessWithTitle:NSLocalizedString(@"Completed", @"Label completed") inView:self.view];
            self.identifierTypes = types;
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
            });
        } else {
            [[MRSAlertHandler alertViewForError:self error:error] show];
            self.failed = YES;
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
    if (self.identifierTypes.count == 0 && self.failed) {
        UILabel *backgroundLabel = [[UILabel alloc] init];
        backgroundLabel.textAlignment = NSTextAlignmentCenter;
        backgroundLabel.text = [NSString stringWithFormat:@"\"%@\"", NSLocalizedString(@"No identifier types available", @"Label no identifier types available")];
        self.tableView.backgroundView = backgroundLabel;
    } else {
        self.tableView.backgroundView = nil;
    }
    return self.identifierTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IdentifierTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[IdentifierTypeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    MRSPatientIdentifierType *type = self.identifierTypes[indexPath.row];
    cell.IdentifierType = type;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    [cell setIndex:[NSNumber numberWithInteger:indexPath.row + 1]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRSPatientIdentifierType *type = self.identifierTypes[indexPath.row];
    self.rowDescriptor.value = type.display;
    [self.delegate didSelectPatientIdentifierType:type];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.delegate forKey:@"delegate"];
    [coder encodeObject:self.identifierTypes forKey:@"array"];
    [super encodeRestorableStateWithCoder:coder];
}

#pragma mark - UIViewRestoration

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    SelectPatientIdentifierTypeTableViewController *idVC = [[SelectPatientIdentifierTypeTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    idVC.delegate = [coder decodeObjectForKey:@"delegate"];
    idVC.identifierTypes = [coder decodeObjectForKey:@"array"];
    return idVC;
}

@end
