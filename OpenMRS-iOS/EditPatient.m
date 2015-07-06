//
//  EditPatient.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 6/15/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "EditPatient.h"
#import "MRSDateUtilities.h"
#import "MRSHelperFunctions.h"
#import "OpenMRSAPIManager.h"
#import "SVProgressHUD.h"

@interface EditPatient ()

@property (nonatomic, strong) NSArray *patientData;
@property (nonatomic, strong) NSArray *personKeys;
@property (nonatomic, strong) NSArray *nameKeys;
@property (nonatomic, strong) NSArray *addressKeys;
@property (nonatomic, strong) NSArray *allKeys;
@property (nonatomic, strong) NSArray *personViewKeys;
@property (nonatomic, strong) NSArray *nameViewKeys;
@property (nonatomic, strong) NSArray *addressViewKeys;
@property (nonatomic, strong) NSArray *allViewsKeys;
@property (nonatomic, strong) NSMutableDictionary *translatedToOriginal;
@property (nonatomic, strong) UITextField *currentTextField;

@end

@implementation EditPatient

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateFontSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save button label")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                            action:@selector(updatePatient)];
    self.navigationItem.title = NSLocalizedString(@"Edit patient", @"Title -Edit- -patient-");
    self.patientData = @[
                         [[NSMutableDictionary alloc] initWithDictionary:@{
                             @"Gender": ObjectOrEmpty(self.patient.gender),
                             @"BirthDate": ObjectOrEmpty(self.patient.birthdate),
                             @"BirthDate Estimated": ObjectOrEmpty(self.patient.birthdateEstimated),
                             @"Dead": ObjectOrEmpty(self.patient.dead?NSLocalizedString(@"true", @"True value"):NSLocalizedString(@"false", @"False value")),
                             @"Cause Of Death": ObjectOrEmpty(self.patient.causeOfDeath)
                             }],
                         [[NSMutableDictionary alloc] initWithDictionary:@{
                            @"Given Name": ObjectOrEmpty(self.patient.givenName),
                            @"Middle Name": ObjectOrEmpty(self.patient.middleName),
                            @"Family Name": ObjectOrEmpty(self.patient.familyName),
                            @"Family Name2": ObjectOrEmpty(self.patient.familyName2)
                            }],
                         [[NSMutableDictionary alloc] initWithDictionary:@{
                            @"Address 1": ObjectOrEmpty(self.patient.address1),
                            @"Address 2": ObjectOrEmpty(self.patient.address2),
                            @"Address 3": ObjectOrEmpty(self.patient.address3),
                            @"Address 4": ObjectOrEmpty(self.patient.address4),
                            @"Address 5": ObjectOrEmpty(self.patient.address5),
                            @"Address 6": ObjectOrEmpty(self.patient.address6),
                            @"City Village": ObjectOrEmpty(self.patient.cityVillage),
                            @"State Province": ObjectOrEmpty(self.patient.stateProvince),
                            @"Country": ObjectOrEmpty(self.patient.country),
                            @"Postal Code": ObjectOrEmpty(self.patient.postalCode),
                            @"Longitude": ObjectOrEmpty(self.patient.longitude),
                            @"Latitude": ObjectOrEmpty(self.patient.latitude),
                            @"County District": ObjectOrEmpty(self.patient.countyDistrict)
                            }]
                         ];
    self.personKeys = @[@"Gender", @"BirthDate", @"BirthDate Estimated", @"Dead", @"Cause Of Death"];
    self.nameKeys = @[@"Given Name", @"Middle Name", @"Family Name", @"Family Name2"];
    self.addressKeys = @[@"Address 1", @"Address 2", @"Address 3", @"Address 4", @"Address 5", @"Address 6",
                         @"City Village", @"State Province", @"Country" ,@"Postal Code", @"Longitude", @"Latitude", @"County District"];
    self.allKeys = @[self.personKeys, self.nameKeys, self.addressKeys];
    
    self.personViewKeys = @[NSLocalizedString(@"Gender", @"Gender of person"),
                            NSLocalizedString(@"BirthDate", @"Birth date of person"),
                            NSLocalizedString(@"BirthDate Estimated", @"Is birth date estimated?"),
                            NSLocalizedString(@"Dead", @"Is dead?"),
                            NSLocalizedString(@"Cause Of Death", @"Cause of death")];
    self.nameViewKeys = @[NSLocalizedString(@"Given Name", @"Given -first name"),
                          NSLocalizedString(@"Middle Name", @"Middle name"),
                          NSLocalizedString(@"Family Name", @"Family name"),
                          [NSString stringWithFormat:@"%@2", NSLocalizedString(@"Family Name", @"Family name")]
                          ];
    self.addressViewKeys = @[[NSString stringWithFormat:@"%@ 1", NSLocalizedString(@"Address", "Address")],
                             [NSString stringWithFormat:@"%@ 2", NSLocalizedString(@"Address", "Address")],
                             [NSString stringWithFormat:@"%@ 3", NSLocalizedString(@"Address", "Address")],
                             [NSString stringWithFormat:@"%@ 4", NSLocalizedString(@"Address", "Address")],
                             [NSString stringWithFormat:@"%@ 5", NSLocalizedString(@"Address", "Address")],
                             [NSString stringWithFormat:@"%@ 6", NSLocalizedString(@"Address", "Address")],
                             NSLocalizedString(@"City Village", @"City village"),
                             NSLocalizedString(@"State Province" , @"State province"),
                             NSLocalizedString(@"Country", @"Country"),
                             NSLocalizedString(@"Postal Code", @"Postal code"),
                             NSLocalizedString(@"Longitude", @"Location longtiude"),
                             NSLocalizedString(@"Latitude", @"Location lattitude"),
                             NSLocalizedString(@"County District", "County District")
                             ];
    self.allViewsKeys = @[self.personViewKeys, self.nameViewKeys, self.addressViewKeys];
    self.translatedToOriginal = [[NSMutableDictionary alloc] init];
    for (int i=0;i<self.allKeys.count; i++) {
        for (int j=0;j < (unsigned long)[self.allKeys[i] count];j++) {
            [self.translatedToOriginal setValue:self.allKeys[i][j] forKey:self.allViewsKeys[i][j]];
        }
    }
    NSLog(@"Translating dictionary: %@", self.translatedToOriginal);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)updateFontSize {
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *labels = @[NSLocalizedString(@"Person", @"Label named person"), NSLocalizedString(@"Preferred Name", @"Label named -Preferred- -Name-)"), NSLocalizedString(@"Preferred Address", @"Label named -Preferred- -Address-")];
    return labels[section];
}

static id ObjectOrEmpty(id object)
{
    //YES THERE 2 NULLS (null) and <null>
    if ([MRSHelperFunctions isNull:object]) {
        return @"";
    } else {
        return object;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSDictionary *)(self.patientData[section]) count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    NSString *label = self.allViewsKeys[indexPath.section][indexPath.row];
    cell.textLabel.text = label;

    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(cell.bounds.size.width-150, 0, 130, cell.bounds.size.height)];
    field.backgroundColor = [UIColor clearColor];
    field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    field.textColor = self.view.tintColor;
    field.textAlignment = NSTextAlignmentRight;
    field.returnKeyType = UIReturnKeyDone;
    field.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    field.delegate = self;
    if ((indexPath.section == 0 && indexPath.row == 1)) {
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        if (indexPath.row == 1) {
            if (self.patient.birthdate != nil) {
                datePicker.date = [MRSDateUtilities dateFromOpenMRSFormattedString:self.patient.birthdate];
            } else {
                datePicker.date = [NSDate date];
            }
        }
        datePicker.datePickerMode = UIDatePickerModeDate;
        [field setInputView:datePicker];
    }
    field.text = self.patientData[indexPath.section][self.translatedToOriginal[label]];
    [cell addSubview:field];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UITableViewCell *cellForTextField = (UITableViewCell *)textField.superview;
    NSString *fieldName = self.translatedToOriginal[cellForTextField.textLabel.text];

    if ([fieldName isEqualToString:@"Dead"] || [fieldName isEqualToString:@"BirthDate Estimated"]) {
        if ([textField.text isEqualToString:NSLocalizedString(@"true", @"True value")] || [textField.text isEqualToString:@""] ) {
            textField.text = NSLocalizedString(@"false", @"False value");
        } else {
            textField.text = NSLocalizedString(@"true", @"True value");
        }
        [textField resignFirstResponder];
    }
    if ([fieldName isEqualToString:@"Gender"]) {
        if ([textField.text isEqualToString:NSLocalizedString(@"M", @"First character of gender -male-")])
            textField.text = NSLocalizedString(@"F", @"First character of gender -female-");
        else
            textField.text = NSLocalizedString(@"M", @"First character of gender -male-");
        [textField resignFirstResponder];
    }
    self.currentTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UITableViewCell *cellForTextField = (UITableViewCell *)textField.superview;
    NSString *property = self.translatedToOriginal[cellForTextField.textLabel.text];
    NSString *newValue = textField.text;
    
    NSLog(@"set property: %@", property);
    if([property isEqualToString:@"Dead"]) {
        if ([newValue isEqualToString:NSLocalizedString(@"true", @"True value")]) {
            self.patient.dead = YES;
        } else {
            self.patient.dead = NO;
        }
        self.patientData[0][@"Dead"]= self.patient.dead?NSLocalizedString(@"false", @"False value"):NSLocalizedString(@"true", @"True value");

    } else if ([property isEqualToString:@"BirthDate Estimated"]) {
        if ([newValue isEqualToString:NSLocalizedString(@"true", @"True value")]) {
            self.patient.birthdateEstimated = @"true";
            [self.patientData[0] setObject:NSLocalizedString(@"true", @"True value") forKey:property];
        } else {
            self.patient.birthdateEstimated = @"false";
            [self.patientData[0] setObject:NSLocalizedString(@"false", @"False value") forKey:property];
        }

    } else if ([property isEqualToString:@"BirthDate"]){
        UIDatePicker *picker = (UIDatePicker *)self.currentTextField.inputView;
        NSString *openmrsDate = [MRSDateUtilities openMRSFormatStringWithDate:picker.date];
        textField.text = openmrsDate;
        self.patientData[0][@"BirthDate"] = openmrsDate;
        [self.patient setValue:openmrsDate forKey:[MRSHelperFunctions formLabelToJSONLabel:property]];
    } else if ([property isEqualToString:@"Gender"]) {
        if ([newValue isEqualToString:NSLocalizedString(@"M", @"First character of gender -male-")]){
            self.patient.gender = @"M";
            [self.patientData[0] setObject:NSLocalizedString(@"M", @"First character of gender -male-") forKey:property];
        } else {
            self.patient.gender = @"F";
            [self.patientData[0] setObject:NSLocalizedString(@"F", @"First character of gender -female-") forKey:property];
        }
    } else {
        for (NSDictionary *dict in self.patientData) {
            if ([dict objectForKey:property]) {
                [dict setValue:newValue forKey:property];
                break;
            }
        }
        [self.patient setValue:newValue forKey:[MRSHelperFunctions formLabelToJSONLabel:property]];
    }
    NSLog(@"Set for: %@", [self.patient valueForKey:[MRSHelperFunctions formLabelToJSONLabel:property]]);
}

#pragma mark - barbuttonitem Action

- (void)updatePatient {
    if (![MRSHelperFunctions isNull:self.currentTextField]) {
        [self textFieldDidEndEditing:self.currentTextField];
    }
    [OpenMRSAPIManager EditPatient:self.patient completion:^(NSError *error) {
        if (!error) {
            self.patient.upToDate = YES;
            if ([self.patient isInCoreData]) {
                [self.patient saveToCoreData];
            }
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Saved", @"Response -saved- label")];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving", @"Warning label -Error- and -Saving-")
                                                                message:NSLocalizedString(@"Can't save your edits right now, choose Retry to retry now or Save to save your edits offline to sync later", @"Error message")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button label")
                                                      otherButtonTitles:NSLocalizedString(@"Retry", @"Retry button label"), NSLocalizedString(@"Save", @"Save button label"), nil];
            [alertView show];
        }
    }];
}

#pragma mark - alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self updatePatient];
    } else if (buttonIndex == 2){
        self.patient.upToDate = NO;
        [self.patient saveToCoreData];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {}

#pragma mark - UIViewRestoration

- (void) encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.patient forKey:@"patient"];
    [super decodeRestorableStateWithCoder:coder];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    EditPatient *editPatient = [[EditPatient alloc] init];
    editPatient.patient = [coder decodeObjectForKey:@"patient"];
    return editPatient;
}
@end
