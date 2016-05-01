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
#import "MRSHelperFunctions.h"
#import "XFormsList.h"
#import "MBProgressExtension.h"
#import "MRSAlertHandler.h"
#import "OpenMRS-iOS-Bridging-Header.h"
#import "OpenMRS_iOS-Swift.h"

@interface PatientSearchViewController () <UIViewControllerPreviewingDelegate>

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
    self.bar.layer.borderWidth = 1;
    self.bar.layer.borderColor = [[UIColor colorWithRed:40/255.0 green:140/255.0 blue:122/255.0 alpha:1] CGColor];
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

    [self.bar becomeFirstResponder];

    if ([self.traitCollection
         respondsToSelector:@selector(forceTouchCapability)] &&
        (self.traitCollection.forceTouchCapability ==
         UIForceTouchCapabilityAvailable))
    {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }

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
        [MBProgressExtension showBlockWithTitle:NSLocalizedString(@"Loading", @"Label loading") inView:self.view];
    }
    [OpenMRSAPIManager getPatientListWithSearch:search online:self.isOnline completion:^(NSError *error, NSArray *patients) {
        if (self.searchButtonPressed) {
            [MBProgressExtension hideActivityIndicatorInView:self.view];
        }
        if (!error) {
            self.currentSearchResults = patients;
            dispatch_async(dispatch_get_main_queue(), ^ {
                if (self.searchButtonPressed)
                {
                    [MBProgressExtension showSucessWithTitle:[NSString stringWithFormat:@"%lu %@", self.currentSearchResults.count, NSLocalizedString(@"patients found", @"Message -patients- -found-")] inView:self.view];
                    self.searchButtonPressed = NO;
                }

                [self.tableView reloadData];
            });
        } else {
            if (self.searchButtonPressed)
            {
                self.searchButtonPressed = NO;
                [[MRSAlertHandler alertViewForError:self error:error] show];
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

    UITabBarController *patientView = [self patientViewForPatient:patient];

    [self.bar resignFirstResponder];

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

- (UITabBarController *)patientViewForPatient:(MRSPatient *)patient {
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

    XFormsList *formsList = [[XFormsList alloc] initBlankForms];
    UINavigationController *formListNavigationController = [[UINavigationController alloc] initWithRootViewController:formsList];
    formListNavigationController.restorationIdentifier = @"navController4";

    UITabBarController *patientView = [[UITabBarController alloc] init];
    NSArray *controllers = [NSArray arrayWithObjects:navController1, navController2, navController3, formListNavigationController, nil];
    patientView.viewControllers = controllers;
    patientView.tabBar.translucent = NO;
    patientView.restorationIdentifier = NSStringFromClass([patientView class]);
    [patientView setSelectedIndex:0];

    return patientView;
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
    if (!self.isOnline) {
        [OpenMRSAPIManager cancelPreviousSearchOperations];
    } else {
        self.currentSearchResults = [NSArray array];
        [self.tableView reloadData];
    }
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

#pragma mark - UIViewcontrollerRestoration

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    PatientSearchViewController *searchVC = [[PatientSearchViewController alloc] initWithStyle:UITableViewStylePlain];
    searchVC.barText = [coder decodeObjectForKey:@"searchtext"];
    searchVC.segmentIndex = [coder decodeObjectForKey:@"segmentIndex"];
    return searchVC;
}

#pragma mark 3DTouch

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.tableView
                              indexPathForRowAtPoint:location];

    MRSPatient *patient = self.currentSearchResults[indexPath.row];

    if (patient)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

        if (cell) {
            previewingContext.sourceRect = cell.frame;

            PatientViewController *vc = [[PatientViewController alloc] initWithStyle:UITableViewStyleGrouped];
            vc.patient = patient;
            PatientPeekNavigationController *navController = [[PatientPeekNavigationController alloc] initWithRootViewController:vc];
            navController.patient = patient;
            navController.searchController = self;
            navController.restorationIdentifier = @"navController1";

            return navController;
        }
    }

    return nil;
}
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    UINavigationController *navCon = (UINavigationController *)viewControllerToCommit;
    MRSPatient *patient = ((PatientViewController *)navCon.viewControllers[0]).patient;

    [self showDetailViewController:[self patientViewForPatient:patient] sender:self];
}
@end
