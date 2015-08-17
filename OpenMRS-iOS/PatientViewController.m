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
#import "AddVisitNoteTableViewController.h"
#import "CaptureVitalsTableViewController.h"
#import "MRSPatient.h"
#import "MRSDateUtilities.h"
#import "AppDelegate.h"
#import "SyncingEngine.h"
#import "EditPatientForm.h"
#import "XFormsList.h"
#import "Constants.h"
#import "MBProgressExtension.h"
#import "MRSAlertHandler.h"
#import "MBProgressHUD.h"

@interface PatientViewController ()

@property (nonatomic, strong) NSTimer *refreshingTimer;
@property (nonatomic) BOOL showedErrorAlready;

@end

@implementation PatientViewController

-(id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];

        self.tabBarItem.image = [UIImage imageNamed:@"user_icon"];
        double interval = [[NSUserDefaults standardUserDefaults] doubleForKey:UDrefreshInterval];
        self.refreshingTimer = [NSTimer scheduledTimerWithTimeInterval:interval * 60 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)setPatient:(MRSPatient *)patient
{
    NSLog(@"tabbar: views: %@", [(UINavigationController *)(self.tabBarController.viewControllers[3]) viewControllers]);
    if (![MRSHelperFunctions isNull:_patient]) {
        self.patientEdited = YES;
        self.visitsEdited = YES;
        self.encoutersEdited = YES;
    }
    XFormsList *formsList = [(UINavigationController *)(self.tabBarController.viewControllers[3]) viewControllers][0];
    [formsList setPatient:patient];
    _patient = patient;
    self.information = @[@ {NSLocalizedString(@"Name", @"Label name"):[self notNil:self.patient.name]},
                           @ {NSLocalizedString(@"Age", @"Label age") : [self notNil:self.patient.age]},
                           @ {NSLocalizedString(@"Gender", @"Gender of person") : [self notNil:self.patient.gender]},
                           @ {NSLocalizedString(@"Address", "Address") : [self formatPatientAdress:self.patient]}];
    NSLog(@"Information: %@", self.information);
    self.navigationItem.title = self.patient.name;
    self.tabBarItem.title = [self.patient.name componentsSeparatedByString:@" "].firstObject;
    [self.tableView reloadData];
    /* This is a just checking a random detailed value that will 
     * tell us if this is a detailed patient or not, because the old
     * loading from coredata will return .hasdetailedinfo as nill
     * and the app will be caught in an infintie loop.
     */
    if (!_patient.gender) {
        [self updateWithDetailedInfo];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateFontSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Label close") style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    }
    self.patientEdited = YES;
    self.visitsEdited = YES;
    self.encoutersEdited = YES;
    
    self.showedErrorAlready = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)refresh {
    self.patientEdited = YES;
    self.encoutersEdited = YES;
    self.visitsEdited = YES;
    [self updateWithDetailedInfo];
}

- (void)close {
    [self.refreshingTimer invalidate];
    [self.tabBarController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"will appear");
    [super viewWillAppear:animated];
    [self updateWithDetailedInfo];
}

- (void)updateFontSize {
    [self.tableView reloadData];
}

- (id)notNil:(id)thing
{
    if (thing == nil || thing == [NSNull null]) {
        return @"";
    }
    return thing;
}

- (void)updateWithDetailedInfo
{
    if (self.patientEdited) {
        NSLog(@"update: Editing patient");
        if ([self.patient isInCoreData]) {
            NSLog(@"update: In core date");
            MRSPatient *savedPatient = [[MRSPatient alloc] init];
            savedPatient.UUID = self.patient.UUID;
            [savedPatient updateFromCoreData];
            if (!savedPatient.upToDate) {
                NSLog(@"will be edited!");
                self.patient = savedPatient;
                [self.tableView reloadData];
                [self syncPatient:savedPatient];
            } else {
                [self fetchPatient];
            }
        } else {
            [self fetchPatient];
        }
    }
    if (self.encoutersEdited) {
        UINavigationController *parentNav = self.tabBarController.viewControllers[2];
        PatientEncounterListView *encounterList = parentNav.viewControllers[0];
        if (encounterList) {
            [MBProgressExtension showBlockWithTitle:NSLocalizedString(@"Loading", @"Label loading") inView:encounterList.view];
        }
        [OpenMRSAPIManager getEncountersForPatient:self.patient completion:^(NSError *error, NSArray *encounters) {
            if (encounterList) {
                [MBProgressExtension hideActivityIndicatorInView:encounterList.view];
            }
            if (error == nil) {
                if (encounterList) {
                    [MBProgressExtension showSucessWithTitle:NSLocalizedString(@"Encounters loaded", @"Label loaded encounters") inView:encounterList.view];
                }
                self.encounters = encounters;
                self.encoutersEdited = NO;
                self.showedErrorAlready = NO;
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self.tableView reloadData];
                });
                encounterList.encounters = self.encounters;
                [encounterList.tableView reloadData];
            } else {
                if (encounterList.isViewLoaded && encounterList.view.window && !self.showedErrorAlready) {
                    [[MRSAlertHandler alertViewForError:encounterList error:error] show];
                    self.showedErrorAlready = YES;
                }
            }
        }];
    }
    if (self.visitsEdited) {
        UINavigationController *parentNav = self.tabBarController.viewControllers[1];
        PatientVisitListView *visitsView = parentNav.viewControllers[0];
        if (visitsView != nil) {
            [MBProgressExtension showBlockWithTitle:NSLocalizedString(@"Loading", @"Label loading") inView:visitsView.view];
        }
        [OpenMRSAPIManager getVisitsForPatient:self.patient completion:^(NSError *error, NSArray *visits) {
            if (visitsView) {
                [MBProgressExtension hideActivityIndicatorInView:visitsView.view];
            }
            if (error == nil) {
                if (visitsView) {
                    [MBProgressExtension showSucessWithTitle:NSLocalizedString(@"Visits loaded", @"Label loaded visits") inView:visitsView.view];
                }
                self.visits = visits;
                self.visitsEdited = NO;
                self.showedErrorAlready = NO;
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
                visitsView.visits = self.visits;
            } else {
                if (visitsView.isViewLoaded && visitsView.view.window && !self.showedErrorAlready) {
                    [[MRSAlertHandler alertViewForError:visitsView error:error] show];
                    self.showedErrorAlready = YES;
                }
            }
        }];
    }
}
- (void)syncPatient:(MRSPatient *)savedPatient {
    [MBProgressExtension showBlockWithTitle:NSLocalizedString(@"Syncing", @"Label syncing") inView:self.view];
    [[SyncingEngine sharedEngine] SyncPatient:savedPatient completion:^(NSError *error) {
        [MBProgressExtension hideActivityIndicatorInView:self.view];
        if (!error) {
            [MBProgressExtension showSucessWithTitle:NSLocalizedString(@"Synced", @"Label synced") inView:self.view];
            self.showedErrorAlready = NO;
            self.patient = savedPatient;
            self.patientEdited = NO;
        } else {
            if (!self.showedErrorAlready) {
                [[MRSAlertHandler alertViewForError:self error:error] show];
                self.showedErrorAlready = YES;
            }
        }
    }];
}
-(void)fetchPatient {
    [MBProgressExtension showBlockWithTitle:NSLocalizedString(@"Loading", @"Label loading") inView:self.view];
    [OpenMRSAPIManager getDetailedDataOnPatient:self.patient completion:^(NSError *error, MRSPatient *detailedPatient) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if (error == nil) {
            [MBProgressExtension showSucessWithTitle:NSLocalizedString(@"Patient details loaded", @"Label patient loaded") inView:self.view];
            self.patient = detailedPatient;
            self.information = @[@ {NSLocalizedString(@"Name", @"Label name"):[self notNil:self.patient.name]},
                                   @ {NSLocalizedString(@"Age", @"Label age") : [self notNil:self.patient.age]},
                                   @ {NSLocalizedString(@"Gender", @"Gender of person") : [self notNil:self.patient.gender]},
                                   @ {NSLocalizedString(@"Address", "Address") : [self formatPatientAdress:self.patient]}];
            if ([self.patient isInCoreData]) {
                MRSPatient *savedPatient = [[MRSPatient alloc] init];
                savedPatient.UUID = self.patient.UUID;
                [savedPatient updateFromCoreData];
                if (savedPatient.upToDate) {
                    savedPatient = self.patient;
                    savedPatient.hasDetailedInfo = YES;
                    [savedPatient saveToCoreData];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
                self.tabBarController.title = self.patient.name;
                self.tabBarItem.title = [self.patient.name componentsSeparatedByString:@" "].firstObject;
            });
            self.patientEdited = NO;
            self.showedErrorAlready = NO;
        } else {
            if ([self.patient isInCoreData]) {
                [self.patient updateFromCoreData];
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self.tableView reloadData];
                    self.tabBarController.title = self.patient.name;
                    self.tabBarItem.title = [self.patient.name componentsSeparatedByString:@" "].firstObject;
                    if (self.patient.hasDetailedInfo) {
                        self.information = @[@ {NSLocalizedString(@"Name", @"Label name"):[self notNil:self.patient.name]},
                                               @ {NSLocalizedString(@"Age", @"Label age") : [self notNil:self.patient.age]},
                                               @ {NSLocalizedString(@"Gender", @"Gender of person") : [self notNil:self.patient.gender]},
                                               @ {NSLocalizedString(@"Address", "Address") : [self formatPatientAdress:self.patient]}];
                    }
                });
            }
            if (!self.showedErrorAlready) {
                [[MRSAlertHandler alertViewForError:self error:error] show];
                self.showedErrorAlready = YES;
            }
        }
    }];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSDictionary *cellHeightDictionary;
    if (!cellHeightDictionary) {
        cellHeightDictionary = @{ UIContentSizeCategoryExtraSmall : @33,
                                  UIContentSizeCategorySmall : @33,
                                  UIContentSizeCategoryMedium : @44,
                                  UIContentSizeCategoryLarge : @44,
                                  UIContentSizeCategoryExtraLarge : @55,
                                  UIContentSizeCategoryExtraExtraLarge : @66,
                                  UIContentSizeCategoryExtraExtraExtraLarge : @70
                                  };
    }

    NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];

    NSNumber *cellHeight = cellHeightDictionary[userSize];
    if (indexPath.section == 0) {
        return cellHeight.floatValue;
    }
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *detail = cell.detailTextLabel.text;
    CGRect bounding = [detail boundingRectWithSize:CGSizeMake(self.view.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@ {NSFontAttributeName:cell.detailTextLabel.font} context:nil];
    return MAX(cellHeight.floatValue,bounding.size.height+10);
}
- (NSString *)formatPatientAdress:(MRSPatient *)patient
{
    NSString *string = [self notNil:patient.address1];
    NSArray *addressAttributes = @[@"address1", @"address2", @"address3", @"address4", @"address5", @"address6",
                                   @"cityVillage", @"stateProvince", @"country", @"postalCode"];
    for (NSString *attribute in addressAttributes) {
        if (![MRSHelperFunctions isNull:[self.patient valueForKey:attribute]]) {
            string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", [patient valueForKey:attribute]]];
        }
    }
    return string;
}
- (NSString *)formatDate:(NSString *)date
{
    NSDate *newDate = [MRSDateUtilities dateFromOpenMRSFormattedString:date];
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
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([MRSHelperFunctions isNull:self.patient]) {
        return 0;
    }
    if (section == 0) {
        if (self.isShowingActions)
            if (![MRSHelperFunctions isNull:self.patient] && [self.patient isInCoreData])
                return 6;
            else
                return 5;
        else
            return 1;
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
            cell.textLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Add Visit Note", @"Label -add- -visit- -note-")];
            return cell;
        }
        if (indexPath.row == 1) {
            UITableViewCell *actionCell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
            if (!actionCell) {
                actionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"actionCell"];
            }
            actionCell.textLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Capture Vitals", @"Label -capture- -vitals-")];
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
        //Conditional cell if patient is already saved in CoreDate
        if (indexPath.row == 3 && ![MRSHelperFunctions isNull:self.patient] && [self.patient isInCoreData]) {
            UITableViewCell *deleteFromCoreData = [tableView dequeueReusableCellWithIdentifier:@"coredata"];
            if (!deleteFromCoreData) {
                deleteFromCoreData = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"coredata"];
            }
            deleteFromCoreData.textLabel.text = NSLocalizedString(@"Remove Offline Record", @"Label remove offline record");
            deleteFromCoreData.textLabel.textAlignment = NSTextAlignmentCenter;
            deleteFromCoreData.textLabel.textColor = self.view.tintColor;
            return deleteFromCoreData;
        }
        
        /* Cascading the conditional cell */
        if ((indexPath.row == 3 && !(![MRSHelperFunctions isNull:self.patient] && [self.patient isInCoreData])) ||
            ((indexPath.row == 4) && (![MRSHelperFunctions isNull:self.patient] && [self.patient isInCoreData])) ) {
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
                cell.textLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Start Visit", "Label -start- -visit-")];
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = self.view.tintColor;
            return cell;
        }
        /* Cascading the conditional cell */
        if ((indexPath.row == 4 && !(![MRSHelperFunctions isNull:self.patient] && [self.patient isInCoreData])) ||
            ((indexPath.row == 5) && (![MRSHelperFunctions isNull:self.patient] && [self.patient isInCoreData])) ) {
            UITableViewCell *editCell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
            if (!editCell) {
                editCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"actionCell"];
            }
            editCell.textLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Edit Patient", @"Title -Edit- -patient-")];
            editCell.textLabel.textAlignment = NSTextAlignmentCenter;
            editCell.textLabel.textColor = self.view.tintColor;
            return editCell;
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
        if (indexPath.row == 0) {
            AddVisitNoteTableViewController *addVisitNote = [[AddVisitNoteTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            addVisitNote.delegate = self;
            addVisitNote.patient = self.patient;
            addVisitNote.delegate = self;
            UINavigationController *addVisitNoteNavContrller = [[UINavigationController alloc] initWithRootViewController:addVisitNote];
            addVisitNoteNavContrller.restorationIdentifier = NSStringFromClass([addVisitNoteNavContrller class]);
            addVisitNoteNavContrller.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:addVisitNoteNavContrller animated:YES completion:nil];
        } else if (indexPath.row == 1) {
            CaptureVitalsTableViewController *vitals = [[CaptureVitalsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            vitals.patient = self.patient;
            vitals.delegate = self;
            UINavigationController *captureVitalsNavContrller = [[UINavigationController alloc] initWithRootViewController:vitals];
            captureVitalsNavContrller.restorationIdentifier = NSStringFromClass([captureVitalsNavContrller class]);
            captureVitalsNavContrller.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self presentViewController:captureVitalsNavContrller animated:YES completion:nil];
        }
        if (indexPath.row == 2) {
            if ([self.patient isInCoreData]) {
                MRSPatient *savedPatient = [[MRSPatient alloc] init];
                savedPatient.UUID = self.patient.UUID;
                [savedPatient updateFromCoreData];
                if (!self.patient.upToDate) {
                    [self syncPatient:savedPatient];
                    return;
                }
            }
            [self.patient saveToCoreData];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self performSelector:@selector(reload) withObject:nil afterDelay:1.0];
            return;
        }
        if (indexPath.row == 3 && ![MRSHelperFunctions isNull:self.patient] && [self.patient isInCoreData]) {
            [self.patient cascadingDelete];
            [self performSelector:@selector(reload) withObject:nil afterDelay:1.0];
            return;
        }
        if ((indexPath.row == 3 && !(![MRSHelperFunctions isNull:self.patient] && [self.patient isInCoreData])) ||
            ((indexPath.row == 4) && (![MRSHelperFunctions isNull:self.patient] && [self.patient isInCoreData])) ) {
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
                        [MBProgressExtension showBlockWithTitle:@"" inView:self.view];
                        [OpenMRSAPIManager stopVisit:activeVisit completion:^(NSError *error) {
                            [MBProgressExtension hideActivityIndicatorInView:self.view];
                            if (error == nil) {
                                [MBProgressExtension showSucessWithTitle:NSLocalizedString(@"Done", @"Label done") inView:self.view];
                                self.visitsEdited = YES;
                                [self updateWithDetailedInfo];
                            } else {
                                [[MRSAlertHandler alertViewForError:self error:error] show];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        }];
                    }
                }];

            } else {
                StartVisitViewController *startVisitVC = [[StartVisitViewController alloc] initWithStyle:UITableViewStyleGrouped];
                startVisitVC.delegate = self;
                startVisitVC.patient = self.patient;
                UINavigationController *startVisitNavContrller = [[UINavigationController alloc] initWithRootViewController:startVisitVC];
                startVisitNavContrller.restorationIdentifier = NSStringFromClass([startVisitNavContrller class]);
                startVisitNavContrller.modalPresentationStyle = UIModalPresentationFormSheet;
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                [self presentViewController:startVisitNavContrller animated:YES completion:nil];
            }
            return;
        }
        if ((indexPath.row == 4&& !(![MRSHelperFunctions isNull:self.patient] && [self.patient isInCoreData])) ||
            ((indexPath.row == 5) && (![MRSHelperFunctions isNull:self.patient] && [self.patient isInCoreData])) ) {
            EditPatientForm *pf = [[EditPatientForm alloc] initWithPatient:self.patient];
            UINavigationController *editPatientNavController = [[UINavigationController alloc] initWithRootViewController:pf];
            editPatientNavController.restorationIdentifier = NSStringFromClass([editPatientNavController class]);
            editPatientNavController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            self.patientEdited = YES;
            [self presentViewController:editPatientNavController animated:YES completion:nil];
        }
    }
}

-(void)reload {
    [self.tableView reloadData];
}

#pragma mark - Delegates

- (void)didAddVisitNoteToPatient:(MRSPatient *)patient
{
    if ([patient.UUID isEqualToString:self.patient.UUID]) {
        self.encoutersEdited = YES;
        [self updateWithDetailedInfo];
    }
}
- (void)didCaptureVitalsForPatient:(MRSPatient *)patient
{
    if ([patient.UUID isEqualToString:self.patient.UUID]) {
        self.encoutersEdited = YES;
        [self updateWithDetailedInfo];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didCreateVisitForPatient:(MRSPatient *)patient
{
    if ([patient.UUID isEqualToString:self.patient.UUID]) {
        self.visitsEdited = YES;
        [self updateWithDetailedInfo];
    }
}

#pragma mark - UIViewControllerRestortion

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.patient forKey:@"patient"];
    [coder encodeObject:[NSNumber numberWithBool:self.isShowingActions] forKey:@"showingActions"];
    [coder encodeObject:[NSNumber numberWithBool:self.hasActiveVisit] forKey:@"hasActiveVisits"];
    [super encodeRestorableStateWithCoder:coder];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    PatientViewController *patientVC = [[PatientViewController alloc] initWithStyle:UITableViewStyleGrouped];
    patientVC.restorationIdentifier = [identifierComponents lastObject];
    MRSPatient *patient = [coder decodeObjectForKey:@"patient"];
    patientVC.patient = patient;
    patientVC.isShowingActions = [[coder decodeObjectForKey:@"showingActions"] boolValue];
    patientVC.hasActiveVisit = [[coder decodeObjectForKey:@"hasActiveVisits"] boolValue];
    patientVC.information = @[@ {NSLocalizedString(@"Name", @"Label name"):[patientVC notNil:patientVC.patient.name]},
                                @ {NSLocalizedString(@"Age", @"Label age") : [patientVC notNil:patientVC.patient.age]},
                                @ {NSLocalizedString(@"Gender", @"Gender of person") : [patientVC notNil:patientVC.patient.gender]},
                                @ {NSLocalizedString(@"Address", "Address") : [patientVC formatPatientAdress:patientVC.patient]}];
    return patientVC;
}

@end
