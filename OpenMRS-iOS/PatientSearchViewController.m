//
//  PatientSearchViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//
//

#import "PatientSearchViewController.h"
#import "OpenMRSAPIManager.h"
#import "PatientEncounterListView.h"
#import "PatientVisitListView.h"
#import "MRSPatient.h"
#import "PatientViewController.h"
#import "SVProgressHUD.h"
#import "MRSHelperFunctions.h"

@interface PatientSearchViewController ()

@property (atomic, assign) BOOL searchButtonPressed;
@property (nonatomic) BOOL isOnline;
@property (nonatomic, strong) UISegmentedControl *onlineOrOffile;
@property (nonatomic, strong) UISearchBar *bar;
@property (nonatomic, strong) NSString *barText;
@property (nonatomic, strong) NSNumber *segmentIndex;

@end

@implementation PatientSearchViewController

- (void)viewDidLoad
{
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
    [defaultCenter addObserver:self selector:@selector(updateFontSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Label close") style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    }
    
    if ([MRSHelperFunctions isNull:self.segmentIndex] || [self.segmentIndex  isEqual: @0]) {
        self.isOnline = YES;
        self.segmentIndex = @0;
    } else {
        self.isOnline = NO;
    }
    self.title = NSLocalizedString(@"Patients", @"Title label patients");
    [super viewDidLoad];
    [self reloadDataForSearch:@""];

    self.bar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    self.bar .autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.bar .delegate = self;
    [self.bar  sizeToFit];
    if (![MRSHelperFunctions isNull:self.barText]) {
        self.bar.text = self.barText;
        [self reloadDataForSearch:self.barText];
    }

    self.onlineOrOffile = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Online", @"Label online"), NSLocalizedString(@"Offline", @"Label offline")]];
    self.onlineOrOffile.selectedSegmentIndex = [self.segmentIndex integerValue];
    [self.onlineOrOffile addTarget:self action:@selector(switchOnline) forControlEvents:UIControlEventValueChanged];
    
    UIView *headerView = [[UIView alloc] init];

    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat segmentHeight = 33;
    CGFloat segmentWidth = 250;
    CGFloat height = 44;
    [headerView setFrame:CGRectMake(0, 0, width, 88)];
    [self.onlineOrOffile setFrame:CGRectMake((width-segmentWidth)/2.0, 44+((height-segmentHeight)/2), segmentWidth, segmentHeight)];
    self.onlineOrOffile.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [headerView addSubview:self.onlineOrOffile];
    [headerView addSubview:self.bar ];
    self.tableView.tableHeaderView = headerView;

    [self.bar  becomeFirstResponder];

    self.searchButtonPressed = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)updateFontSize {
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)reloadDataForSearch:(NSString *)search
{
    if (self.searchButtonPressed) {
        [SVProgressHUD show];
    }
    [OpenMRSAPIManager getPatientListWithSearch:search online:self.isOnline completion:^(NSError *error, NSArray *patients) {
        if (!error) {
            self.currentSearchResults = patients;
            dispatch_async(dispatch_get_main_queue(), ^ {
                if (patients.count == 0 && self.searchButtonPressed && [SVProgressHUD isVisible])
                {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Couldn't find patients", @"Message -could- -not- -find- -patients")];
                    self.searchButtonPressed = NO;
                }
                else if (self.searchButtonPressed && [SVProgressHUD isVisible])
                {
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%lu %@", self.currentSearchResults.count, NSLocalizedString(@"patients found", @"Message -patients- -found-")]];
                    self.searchButtonPressed = NO;
                }

                [self.tableView reloadData];
            });
        } else {
            if (self.searchButtonPressed && [SVProgressHUD isVisible])
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Can't load patients", @"Message -can- -not- -load- -patients-")];
                self.searchButtonPressed = NO;
            }
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentSearchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    MRSPatient *patient = self.currentSearchResults[indexPath.row];
    cell.textLabel.text = patient.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MRSPatient *patient = self.currentSearchResults[indexPath.row];
    PatientViewController *vc = [[PatientViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.patient = patient;
    vc.tabBarItem.title = patient.display;
    vc.tabBarItem.image = [UIImage imageNamed:@"user_icon"];
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:vc];
    navController1.restorationIdentifier = @"navController1";
    
    PatientVisitListView *visitsList = [[PatientVisitListView alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:visitsList];
    navController2.restorationIdentifier = @"navController2";
    
    
    PatientEncounterListView *encounterList = [[PatientEncounterListView alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:encounterList];
    navController3.restorationIdentifier = @"navContrller3";
    
    UITabBarController *patientView = [[UITabBarController alloc] init];
    NSArray *controllers = [NSArray arrayWithObjects:navController1, navController2, navController3, nil];
    patientView.viewControllers = controllers;
    patientView.tabBar.translucent = NO;
    patientView.restorationIdentifier = NSStringFromClass([patientView class]);
    [patientView setSelectedIndex:0];

    if (!self.splitViewController) {
        [self presentViewController:patientView animated:YES completion:nil];
    } else {
        /* Getting the patient view controller already existed */
        NSArray *vcs = @[self.splitViewController.viewControllers[0], patientView];
        self.splitViewController.viewControllers = vcs;
        PatientViewController *vc = [(UINavigationController *)(patientView.viewControllers[0]) viewControllers][0];
        
        vc.patient =  self.currentSearchResults[indexPath.row];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.barText = searchBar.text;
    [self reloadDataForSearch:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searchButtonPressed = YES;
    [self reloadDataForSearch:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)switchOnline{
    long index = self.onlineOrOffile.selectedSegmentIndex;
    self.onlineOrOffile.selectedSegmentIndex = index == 0 ? 0 : 1;
    self.segmentIndex = index == 0? @0: @1;
    self.isOnline = index == 0 ? YES : NO;
    [self reloadDataForSearch:self.bar.text];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.barText forKey:@"searchtext"];
    [coder encodeObject:self.segmentIndex forKey:@"segmentIndex"];
    [super encodeRestorableStateWithCoder:coder];
}
- (void)close {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewcontrollerRestortion

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    PatientSearchViewController *searchVC = [[PatientSearchViewController alloc] initWithStyle:UITableViewStylePlain];
    searchVC.barText = [coder decodeObjectForKey:@"searchtext"];
    searchVC.segmentIndex = [coder decodeObjectForKey:@"segmentIndex"];
    return searchVC;
}
@end
