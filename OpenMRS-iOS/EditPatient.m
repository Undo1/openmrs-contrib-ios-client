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

@interface EditPatient ()

@property (nonatomic, strong) NSArray *patientData;
@property (nonatomic, strong) NSArray *personKeys;
@property (nonatomic, strong) NSArray *nameKeys;
@property (nonatomic, strong) NSArray *addressKeys;
@property (nonatomic, strong) NSArray *allKeys;
@property (nonatomic, strong) UITextField *currentTextField;

@end

@implementation EditPatient

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"birthdateestimated!: %@", ObjectOrEmpty(self.patient.birthdateEstimated));
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                            action:@selector(updatePatient)];
    self.navigationItem.title = @"Edit patient";
    self.patientData = @[
                         @{
                             @"Gender": ObjectOrEmpty(self.patient.gender),
                             @"BirthDate": ObjectOrEmpty(self.patient.birthdate),
                             @"BirthDate Estimated": ObjectOrEmpty(self.patient.birthdateEstimated),
                             @"Dead": ObjectOrEmpty(self.patient.dead?@"true":@"false"),
                             @"Cause Of Death": ObjectOrEmpty(self.patient.causeOfDeath)
                             },
                         @{
                             @"Given Name": ObjectOrEmpty(self.patient.givenName),
                             @"Middle Name": ObjectOrEmpty(self.patient.middleName),
                             @"Family Name": ObjectOrEmpty(self.patient.familyName),
                             @"Family Name2": ObjectOrEmpty(self.patient.familyName2)
                             },
                         @{
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
                             @"Longtiude": ObjectOrEmpty(self.patient.longitude),
                             @"Latitude": ObjectOrEmpty(self.patient.latitude),
                             @"County District": ObjectOrEmpty(self.patient.countyDistrict)
                             }
                         ];
    self.personKeys = @[@"Gender", @"BirthDate", @"BirthDate Estimated", @"Dead", @"Cause Of Death"];
    self.nameKeys = @[@"Given Name", @"Middle Name", @"Family Name", @"Family Name2"];
    self.addressKeys = @[@"Address 1", @"Address 2", @"Address 3", @"Address 4", @"Address 5", @"Address 6",
                         @"City Village", @"State Province", @"Country" ,@"Postal Code", @"Latitude", @"Latitude", @"County District"];
    self.allKeys = @[self.personKeys, self.nameKeys, self.addressKeys];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *labels = @[@"Person", @"Preferred Name", @"Preferred Address"];
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
    NSString *label = self.allKeys[indexPath.section][indexPath.row];
    cell.textLabel.text = label;

    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(cell.bounds.size.width-150, 0, 130, cell.bounds.size.height)];
    field.backgroundColor = [UIColor clearColor];
    field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    field.textColor = self.view.tintColor;
    field.textAlignment = NSTextAlignmentRight;
    field.returnKeyType = UIReturnKeyDone;
    field.delegate = self;
    if ((indexPath.section == 0 && indexPath.row == 1) || (indexPath.section == 2 && indexPath.row == 14)) {
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        if (indexPath.row == 1) {
            if (self.patient.birthdate != nil) {
                datePicker.date = [MRSDateUtilities dateFromOpenMRSFormattedString:self.patient.birthdate];
            } else {
                datePicker.date = [NSDate date];
            }
        }
        //[datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
        datePicker.datePickerMode = UIDatePickerModeDate;
        [field setInputView:datePicker];
    }
    field.text = self.patientData[indexPath.section][label];
    [cell addSubview:field];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UITableViewCell *cellForTextField = (UITableViewCell *)textField.superview;
    NSString *fieldName = cellForTextField.textLabel.text;

    if ([fieldName isEqualToString:@"Dead"] || [fieldName isEqualToString:@"BirthDate Estimated"]) {
        if ([textField.text isEqualToString:@"true"] || [textField.text isEqualToString:@""] ) {
            textField.text = @"false";
        } else {
            textField.text = @"true";
        }
        [textField resignFirstResponder];
    }
    if ([fieldName isEqualToString:@"Gender"]) {
        if ([textField.text isEqualToString:@"M"])
            textField.text = @"F";
        else
            textField.text = @"M";
        [textField resignFirstResponder];
    }
    self.currentTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UITableViewCell *cellForTextField = (UITableViewCell *)textField.superview;
    NSString *property = cellForTextField.textLabel.text;
    NSString *newValue = textField.text;

    if([property isEqualToString:@"Dead"]) {
        if ([newValue isEqualToString:@"true"]) {
            self.patient.dead = YES;
        } else {
            self.patient.dead = NO;
        }
    } else if ([property isEqualToString:@"BirthDate Estimated"]) {
        [self.patient setValue:newValue forKey:[MRSHelperFunctions formLabelToJSONLabel:property]];

    } else if ([property isEqualToString:@"BirthDate"]){
        UIDatePicker *picker = (UIDatePicker *)self.currentTextField.inputView;
        NSString *openmrsDate = [MRSDateUtilities openMRSFormatStringWithDate:picker.date];
        textField.text = openmrsDate;
        [self.patient setValue:openmrsDate forKey:[MRSHelperFunctions formLabelToJSONLabel:property]];
    } else {
        [self.patient setValue:newValue forKey:[MRSHelperFunctions formLabelToJSONLabel:property]];
    }
}

#pragma mark - barbuttonitem Action

- (void)updatePatient {
    [OpenMRSAPIManager EditPatient:self.patient completion:nil];
    if (![MRSHelperFunctions isNull:self.currentTextField]) {
        [self textFieldDidEndEditing:self.currentTextField];
    }
    //[self.navigationController popViewControllerAnimated:YES];
}

@end
