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

@interface PatientSearchViewController ()

    @property (atomic, assign) BOOL searchButtonPressed;

@end

@implementation PatientSearchViewController
- (void)viewDidLoad
{
    self.title = @"Patients";
    [super viewDidLoad];
    [self reloadDataForSearch:@""];
    UISearchBar *bar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bar.delegate = self;
    [bar sizeToFit];
    self.tableView.tableHeaderView = bar;
    [bar becomeFirstResponder];
    self.searchButtonPressed = NO;
}
- (void)reloadDataForSearch:(NSString *)search
{
    if (self.searchButtonPressed) {
        [SVProgressHUD show];
    }
    [OpenMRSAPIManager getPatientListWithSearch:search completion:^(NSError *error, NSArray *patients) {
        self.currentSearchResults = patients;
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (self.currentSearchResults.count == 0 && self.searchButtonPressed && [SVProgressHUD isVisible])
            {
                [SVProgressHUD showErrorWithStatus:@"Couldn't find patients"];
                self.searchButtonPressed = NO;
            } else if (self.searchButtonPressed && [SVProgressHUD isVisible])
            {
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%lu patients found", self.currentSearchResults.count]];
                self.searchButtonPressed = NO;
            }

            [self.tableView reloadData];
        });
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

    PatientVisitListView *visitsList = [[PatientVisitListView alloc] initWithStyle:UITableViewStyleGrouped];
    visitsList.tabBarItem.title = @"Visits";
    visitsList.tabBarItem.image = [UIImage imageNamed:@"active_visits_icon"];


    PatientEncounterListView *encounterList = [[PatientEncounterListView alloc] initWithStyle:UITableViewStyleGrouped];
    encounterList.tabBarItem.title = @"Encounters";
    encounterList.tabBarItem.image = [UIImage imageNamed:@"vitals_icon"];
    
    UITabBarController *patientView = [[UITabBarController alloc] init];
    patientView.viewControllers = @[vc, visitsList, encounterList];
    
    [patientView setSelectedIndex:0];
    [self.navigationController pushViewController:patientView animated:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self reloadDataForSearch:searchText];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searchButtonPressed = YES;
    [self reloadDataForSearch:searchBar.text];
    [searchBar resignFirstResponder];
}
@end
