//
//  PatientViewController.m
//
//
//  Created by Parker Erway on 12/1/14.
//
//

#import "PatientViewController.h"
#import "EditPatient.h"
#import "OpenMRSAPIManager.h"
#import "PatientEncounterListView.h"
#import "PatientVisitListView.h"
#import "OpenMRS_iOS-Swift.h"
#import <SVProgressHUD.h>
#import "AddVisitNoteTableViewController.h"
#import "CaptureVitalsTableViewController.h"

@implementation PatientViewController
- (void)setPatient:(MRSPatient *)patient
{
    _patient = patient;
    self.information = @[@ {@"Name":patient.name}];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    [super viewDidLoad];
    [self updateWithDetailedInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateWithDetailedInfo];
}
- (void)updateWithDetailedInfo
{
    [OpenMRSAPIManager getDetailedDataOnPatient:self.patient completion:^(NSError *error, MRSPatient *detailedPatient) {
        if (error == nil) {
            self.patient = detailedPatient;
            self.information = @[@ {NSLocalizedString(@"Name", @"Label name"):[self notNil:self.patient.name]},
                                 @ {NSLocalizedString(@"Age", @"Label age") : [self notNil:self.patient.age]},
                                 @ {NSLocalizedString(@"Gender", @"Gender of person") : [self notNil:self.patient.gender]},
                                 @ {NSLocalizedString(@"Address", "Address") : [self formatPatientAdress:self.patient]}];
            [self.patient isInCoreData];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
                self.title = self.patient.name;
            });
        }
    }];
    [OpenMRSAPIManager getEncountersForPatient:self.patient completion:^(NSError *error, NSArray *encounters) {
        if (error == nil) {
            self.encounters = encounters;
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
            });
        }
    }];
    [OpenMRSAPIManager getVisitsForPatient:self.patient completion:^(NSError *error, NSArray *visits) {
        if (error == nil) {
            self.visits = visits;
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
            });
            self.hasActiveVisit = NO;
            for (MRSVisit *visit in visits) {
                if (visit.active) {
                    self.hasActiveVisit = YES;
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self.tableView reloadData];
                    });
                    break;
                }
            }
        }
    }];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44;
    }
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *detail = cell.detailTextLabel.text;
    CGRect bounding = [detail boundingRectWithSize:CGSizeMake(self.view.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@ {NSFontAttributeName:cell.detailTextLabel.font} context:nil];
    return MAX(44,bounding.size.height+10);
}
- (id)notNil:(id)thing
{
    if (thing == nil || thing == [NSNull null]) {
        return @"";
    }
    return thing;
}
- (NSString *)formatPatientAdress:(MRSPatient *)patient
{
    NSString *string = [self notNil:patient.address1];
    if (![[self notNil:patient.address2] isEqual:@""]) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.address2]];
    }
    if (![[self notNil:patient.address3] isEqual:@""]) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.address3]];
    }
    if (![[self notNil:patient.address4] isEqual:@""]) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.address4]];
    }
    if (![[self notNil:patient.address5] isEqual:@""]) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.address5]];
    }
    if (![[self notNil:patient.address6] isEqual:@""]) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.address6]];
    }
    if (![[self notNil:patient.cityVillage] isEqual:@""]) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.cityVillage]];
    }
    if (![[self notNil:patient.stateProvince] isEqual:@""]) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.stateProvince]];
    }
    if (![[self notNil:patient.country] isEqual:@""]) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.country]];
    }
    if (![[self notNil:patient.postalCode] isEqual:@""]) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.postalCode]];
    }
    return string;
}
- (NSString *)formatDate:(NSString *)date
{
    if (date == nil) {
        return @"";
    }
    NSDateFormatter *stringToDateFormatter = [[NSDateFormatter alloc] init];
    [stringToDateFormatter setDateFormat:@"Y-MM-dd'T'HH:mm:ss.SSS-Z"];
    NSDate *newDate = [stringToDateFormatter dateFromString:date];
//    struct tm  sometime;
//    const char *formatString = "%Y-%m-%d'T'%H:%M:%S%Z";
//    (void) strptime_l(date, formatString, &sometime, NULL);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    NSString *string = [formatter stringFromDate:newDate];
    if (string == nil) {
        return @"";
    } else {
        return string;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return (self.isShowingActions) ? 5 : 1;
    } else if (section == 1) {
        return self.information.count;
    } else if (section == 2) {
        return 2;
    } else {
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (!self.isShowingActions) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showActions"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"showActions"];
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = [NSString stringWithFormat: @"%@...", NSLocalizedString(@"Actions", @"Label Actions")];
            cell.textLabel.textColor = self.view.tintColor;
            return cell;
        }
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addVisitNoteCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addVisitNoteCell"];
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = self.view.tintColor;
            cell.textLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Add Visit Note", @"Label add visit note")];
            return cell;
        }
        if (indexPath.row == 1) {
            UITableViewCell *actionCell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
            if (!actionCell) {
                actionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"actionCell"];
            }
            actionCell.textLabel.text = @"Capture Vitals...";
            actionCell.textLabel.textAlignment = NSTextAlignmentCenter;
            actionCell.textLabel.textColor = self.view.tintColor;
            return actionCell;
        }
        if (indexPath.row == 2) {
            UITableViewCell *saveToCoreDataCell = [tableView dequeueReusableCellWithIdentifier:@"coredata"];
            if (!saveToCoreDataCell) {
                saveToCoreDataCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"coredata"];
            }
            if (self.patient.isInCoreData) {
                saveToCoreDataCell.textLabel.text = NSLocalizedString(@"Update Offline Record", @"Label update offline record");
            } else {
                saveToCoreDataCell.textLabel.text = NSLocalizedString(@"Save for Offline Use", "Label save for offline use");
            }
            saveToCoreDataCell.textLabel.textAlignment = NSTextAlignmentCenter;
            saveToCoreDataCell.textLabel.textColor = self.view.tintColor;
            return saveToCoreDataCell;
        }
        if (indexPath.row == 3) {
            UITableViewCell *cell = nil;
            if (self.hasActiveVisit) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"stopVisitCell"];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"stopVisitCell"];
                }
                cell.textLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Stop Visit", @"Label stop visit")];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"startVisitCell"];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"startVisitCell"];
                }
                cell.textLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Start Visit", "Label start visit")];
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = self.view.tintColor;
            return cell;
        }
        if (indexPath.row == 4) {
            UITableViewCell *editCell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
            if (!editCell) {
                editCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"actionCell"];
            }
            editCell.textLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Edit Patient", @"Label Edit Patient")];
            editCell.textLabel.textAlignment = NSTextAlignmentCenter;
            editCell.textLabel.textColor = self.view.tintColor;
            return editCell;
        }
    }
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"countCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"countCell"];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Visits", @"Label visits");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.visits.count];
            return cell;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Encounters", "Label encounters");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.encounters.count];
            return cell;
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSString *key = ((NSDictionary *)self.information[indexPath.row]).allKeys[0];
    NSString *value = [self.information[indexPath.row] valueForKey:key];
    cell.textLabel.text = key;
    cell.detailTextLabel.text = value;
    cell.detailTextLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (!self.isShowingActions) {
            self.isShowingActions = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            return;
        }
        if (indexPath.row == 2) {
            [self.patient saveToCoreData];
            return;
        }
        if (indexPath.row == 3) {
            if (self.hasActiveVisit) {
                MRSVisit *activeVisit;
                for (MRSVisit *visit in self.visits) {
                    if (visit.active) {
                        activeVisit = visit;
                        break;
                    }
                }
                [UIAlertView showWithTitle:NSLocalizedString(@"Stopping Visit", @"Label stopping visit")
                                   message:NSLocalizedString(@"Stop Visit", @"Label stop visit")
                         cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button label")
                         otherButtonTitles:@[NSLocalizedString(@"Stop Visit", @"Label stop visit")]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex != alertView.cancelButtonIndex) {
                        [OpenMRSAPIManager stopVisit:activeVisit completion:^(NSError *error) {
                            if (error == nil) {
                                [self updateWithDetailedInfo];
                            } else {
                                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Couldn't stop visit", @"Response label -could- -not- saved - visit- ")];
                            }
                        }];
                    }
                }];
                
            } else {
                StartVisitViewController *startVisitVC = [[StartVisitViewController alloc] initWithStyle:UITableViewStyleGrouped];
                startVisitVC.delegate = self;
                startVisitVC.patient = self.patient;
                UINavigationController *startVisitNavContrller = [[UINavigationController alloc] initWithRootViewController:startVisitVC];
                startVisitNavContrller.restorationIdentifier = NSStringFromClass([startVisitNavContrller class]);
                startVisitNavContrller.restorationClass = [startVisitNavContrller  class];
                [self presentViewController:startVisitNavContrller animated:YES completion:nil];
            }
            return;
        }
        if (indexPath.row == 0) {
            AddVisitNoteTableViewController *addVisitNote = [[AddVisitNoteTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            addVisitNote.delegate = self;
            addVisitNote.patient = self.patient;
            addVisitNote.delegate = self;
            UINavigationController *addVisitNoteNavContrller = [[UINavigationController alloc] initWithRootViewController:addVisitNote];
            addVisitNoteNavContrller.restorationIdentifier = NSStringFromClass([addVisitNote class]);
            addVisitNoteNavContrller.restorationClass = [addVisitNote  class];
            [self presentViewController:addVisitNoteNavContrller animated:YES completion:nil];
        } else if (indexPath.row == 1) {
            CaptureVitalsTableViewController *vitals = [[CaptureVitalsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            vitals.patient = self.patient;
            vitals.delegate = self;
            UINavigationController *captureVitalsNavContrller = [[UINavigationController alloc] initWithRootViewController:vitals];
            captureVitalsNavContrller.restorationIdentifier = NSStringFromClass([captureVitalsNavContrller class]);
            captureVitalsNavContrller.restorationClass = [captureVitalsNavContrller  class];
            [self presentViewController:captureVitalsNavContrller animated:YES completion:nil];
        }
        if (indexPath.row == 4) {
            EditPatient *editPatient = [[EditPatient alloc] init];
            editPatient.patient = self.patient;
            [self.navigationController pushViewController:editPatient animated:YES];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 1) { //encounters row selected
            PatientEncounterListView *encounterList = [[PatientEncounterListView alloc] initWithStyle:UITableViewStyleGrouped];
            encounterList.encounters = self.encounters;
            [self.navigationController pushViewController:encounterList animated:YES];
        } else if (indexPath.row == 0) { //visits row selected
            PatientVisitListView *visitsList = [[PatientVisitListView alloc] initWithStyle:UITableViewStyleGrouped];
            visitsList.visits = self.visits;
            [self.navigationController pushViewController:visitsList animated:YES];
        }
    }
}
- (void)didAddVisitNoteToPatient:(MRSPatient *)patient
{
    if ([patient.UUID isEqualToString:self.patient.UUID]) {
        [self updateWithDetailedInfo];
    }
}
- (void)didCaptureVitalsForPatient:(MRSPatient *)patient
{
    if ([patient.UUID isEqualToString:self.patient.UUID]) {
        [self updateWithDetailedInfo];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didCreateVisitForPatient:(MRSPatient *)patient
{
    if ([patient.UUID isEqualToString:self.patient.UUID]) {
        [self updateWithDetailedInfo];
    }
}
@end
