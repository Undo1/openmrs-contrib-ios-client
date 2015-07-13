//
//  EditPatientForm.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/5/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "EditPatientForm.h"
#import "MRSHelperFunctions.h"
#import "MRSDateUtilities.h"
#import "Constants.h"
#import "OpenMRSAPIManager.h"
#import "SVProgressHUD.h"


@implementation EditPatientForm

- (instancetype)initWithPatient:(MRSPatient *)patient {
    self = [super init];
    if (self) {
        self.patient = patient;
        [self initilaizeForms];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Label close")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(close)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save button label")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(processForm)];
}

- (void)initilaizeForms {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"Edit patient", @"Title -Edit- -patient-")];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    /* =========================================== Person Section =====================================*/
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Person", @"Label named person")];
    [form addFormSection:section];
    
    //Gender
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGender
                                                rowType:XLFormRowDescriptorTypePicker title:@"Gender"];
    row.selectorOptions = @[
                            NSLocalizedString(@"Male", @"Label female"),
                            NSLocalizedString(@"Female", @"Label male")
                            ];
    row.value = row.selectorOptions[0];
    if (self.patient.gender) {
        row.value = [self.patient.gender isEqualToString:@"M"]?row.selectorOptions[0]:row.selectorOptions[1];
    }
    row.required = YES;
    [section addFormRow:row];
    
    //Birthdate estimated
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kbirthdateEstimated
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:NSLocalizedString(@"BirthDate Estimated", @"Is birth date estimated?")];
    row.value = @0;
    if (self.patient.birthdateEstimated) {
        row.value = [self.patient.birthdateEstimated isEqualToString:@"true"]?@1:@0;
    }
    [section addFormRow:row];
    
    //Age
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAge
                                                rowType:XLFormRowDescriptorTypeInteger
                                                  title:NSLocalizedString(@"Age", @"Label age")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = YES;
    //Validation it is > 0 and < 120
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"" regex:@"^([1-9]|[1-9][0-9]|[1][0-1][0-9])$"]];
    if (self.patient.age) {
        row.value = self.patient.age;
    }
    [section addFormRow:row];
    row.hidden = [NSString stringWithFormat:@"$%@==0", kbirthdateEstimated];
    
    //Birthdate
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBirthdate
                                                rowType:XLFormRowDescriptorTypeDate
                                                  title:NSLocalizedString(@"BirthDate", @"Birth date of person")];
    row.required = YES;
    if (self.patient.birthdate) {
        row.value = [MRSDateUtilities dateFromOpenMRSFormattedString:self.patient.birthdate];
    }
    [section addFormRow:row];
    row.hidden = [NSString stringWithFormat:@"$%@==1", kbirthdateEstimated];
    
    //Dead
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDead
                                                rowType:XLFormRowDescriptorTypeBooleanCheck
                                                  title:NSLocalizedString(@"Dead", @"Is dead?")];
    row.value = @0;
    if (self.patient.dead) {
        row.value = @1;
    }
    [section addFormRow:row];

    //Cause of Death
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCauseOfDeath
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"Cause Of Death", @"Cause of death")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"Required", @"Place holder -required-")] forKey:@"textField.placeholder"];
    if (self.patient.causeOfDeath) {
        row.value = self.patient.causeOfDeath;
    }
    row.required = YES;
    [section addFormRow:row];
    row.hidden = [NSString stringWithFormat:@"$%@!=1", kDead];

    //DeathDate
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDeathDate
                                                rowType:XLFormRowDescriptorTypeDate
                                                  title:NSLocalizedString(@"Death Date", @"Label dead")];
    if (self.patient.deathDate) {
        row.value = [MRSDateUtilities dateFromOpenMRSFormattedString:self.patient.deathDate];
    }
    row.required = YES;
    [section addFormRow:row];
    row.hidden = [NSString stringWithFormat:@"$%@!=1", kDead];

    /* =========================================== Name Section =====================================*/
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Preferred Name", @"Label named -Preferred- -Name-)")];
    [form addFormSection:section];
    
    //Given Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGivenName
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"Given Name", @"Given -first name")];
    [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"Required", @"Place holder -required-")] forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.givenName) {
        row.value = self.patient.givenName;
    }
    row.required = YES;
    [section addFormRow:row];
    
    //Middle Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMiddleName
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"Middle Name", @"Middle name")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.middleName) {
        row.value = self.patient.middleName;
    }
    [section addFormRow:row];
    
    //Family name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFamilyName
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"Family Name", @"Family name")];
    [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"Required", @"Place holder -required-")] forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = YES;
    if (self.patient.familyName) {
        row.value = self.patient.familyName;
    }
    [section addFormRow:row];
    
    //Family name2
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFamilyName2
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:[NSString stringWithFormat:@"%@2", NSLocalizedString(@"Family Name", @"Family name")]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.familyName2) {
        row.value = self.patient.familyName2;
    }
    [section addFormRow:row];

    /* =========================================== Address Section =====================================*/
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Preferred Address", @"Label named -Preferred- -Address-")];
    [form addFormSection:section];
    
    //Address 1
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress1
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:[NSString stringWithFormat:@"%@ 1", NSLocalizedString(@"Address", "Address")]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.address1) {
        row.value = self.patient.address1;
    }
    [section addFormRow:row];
    
    //Address 2
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress2
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:[NSString stringWithFormat:@"%@ 2", NSLocalizedString(@"Address", "Address")]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.address2) {
        row.value = self.patient.address2;
    }
    [section addFormRow:row];
    
    //Address 3
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress3
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:[NSString stringWithFormat:@"%@ 3", NSLocalizedString(@"Address", "Address")]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.address3) {
        row.value = self.patient.address3;
    }
    [section addFormRow:row];
    
    //Address 4
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress4
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:[NSString stringWithFormat:@"%@ 4", NSLocalizedString(@"Address", "Address")]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.address4) {
        row.value = self.patient.address4;
    }
    [section addFormRow:row];
    
    //Address 5
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress5
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:[NSString stringWithFormat:@"%@ 5", NSLocalizedString(@"Address", "Address")]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.address5) {
        row.value = self.patient.address5;
    }
    [section addFormRow:row];
    
    //Address 6
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress2
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:[NSString stringWithFormat:@"%@ 6", NSLocalizedString(@"Address", "Address")]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.address6) {
        row.value = self.patient.address6;
    }
    [section addFormRow:row];
    
    //City Village
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCityVillage
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"City Village", @"City village")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.cityVillage) {
        row.value = self.patient.cityVillage;
    }
    [section addFormRow:row];
    
    //State Province
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kStateProvince
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"State Province" , @"State province")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.stateProvince) {
        row.value = self.patient.stateProvince;
    }
    [section addFormRow:row];
    
    
    //Country
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCountry
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"Country", @"Country")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.country) {
        row.value = self.patient.country;
    }
    [section addFormRow:row];
    
    
    //Postal Code
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostalCode
                                                rowType:XLFormRowDescriptorTypeInteger
                                                  title:NSLocalizedString(@"Postal Code", @"Postal code")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    if (self.patient.postalCode) {
        row.value = self.patient.postalCode;
    }
    [section addFormRow:row];
    
    self.form = form;
}
- (void)processForm {
    NSDictionary *values = self.form.formValues;
    NSLog(@"Values: %@", values);
    if ([self validateForm]) {
        XLFormSectionDescriptor *address_section = self.form.formSections[2];
        for (XLFormRowDescriptor *address_row in address_section.formRows) {
            if (![MRSHelperFunctions isNull:address_row.value]) {
                [self.patient setValue:address_row.value forKey:address_row.tag];
            }
        }

        XLFormSectionDescriptor *name_section = self.form.formSections[1];
        for (XLFormRowDescriptor *name_row in name_section.formRows) {
            if (![MRSHelperFunctions isNull:name_row.value]) {
                [self.patient setValue:name_row.value forKey:name_row.tag];
            }
        }

        if ([values[kGender] isEqualToString:NSLocalizedString(@"Male", @"Label female")]) {
            self.patient.gender = @"M";
        } else {
            self.patient.gender = @"F";
        }
        if ([values[kbirthdateEstimated] integerValue] == 1) {
            self.patient.birthdateEstimated = @"true";
        } else {
            self.patient.birthdateEstimated = @"false";
        }
        if (![MRSHelperFunctions isNull:values[kBirthdate]]) {
            self.patient.birthdate = [MRSDateUtilities openMRSFormatStringWithDate:values[kBirthdate]];
        }
        if (values[kbirthdateEstimated]) {
            self.patient.age = values[kAge];
        } else {
            self.patient.birthdate = [MRSDateUtilities openMRSFormatStringWithDate:values[kBirthdate]];
        }
        if ([values[kDead] boolValue]) {
            self.patient.dead = YES;
            self.patient.causeOfDeath = values[kCauseOfDeath];
        }
        [SVProgressHUD show];
        [self updatePatient];

    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error")
                                    message:NSLocalizedString(@"Couldn't save patient. Make sure all required fields are filled out", @"Error message")
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
    }
}

- (BOOL)validateForm {
    NSArray * array = [self formValidationErrors];
    BOOL valid = YES;
    for(id obj in array) {
        XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
        NSString *tag = validationStatus.rowDescriptor.tag;
        if ([tag isEqualToString:kGivenName] || [tag isEqualToString:kFamilyName] || [tag isEqualToString:kAddress1] ||
            [tag isEqualToString:kAge] || [tag isEqualToString:kBirthdate] || [tag isEqualToString:kCauseOfDeath] ||
            [tag isEqualToString:kDeathDate]){
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            cell.backgroundColor = [UIColor orangeColor];
            [UIView animateWithDuration:0.5 animations:^{
                cell.backgroundColor = [UIColor whiteColor];
            }];
            valid = NO;
        }
    }
    return valid;
}

- (void)updatePatient {
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self updatePatient];
    } else if (buttonIndex == 2){
        self.patient.upToDate = NO;
        [self.patient saveToCoreData];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    [SVProgressHUD dismiss];
}

#pragma mark - UIViewStateRestoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.patient forKey:@"patient"];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    MRSPatient *patient = [coder decodeObjectForKey:@"patient"];
    EditPatientForm *editPatient = [[EditPatientForm alloc] initWithPatient:patient];
    return editPatient;
}
- (void)close {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
