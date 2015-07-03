//
//  AddPatientForm.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/3/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "AddPatientForm.h"
#import "MRSDateUtilities.h"
#import "MRSHelperFunctions.h"
#import "MRSPatientIdentifierType.h"
#import "MRSPatientIdentifier.h"
#import "SelectPatientIdentifierTypeTableViewController.h"

NSString *const kGivenName = @"givenName";
NSString *const kMiddleName = @"middleName";
NSString *const kFamilyName = @"familyName";
NSString *const kFamilyName2 = @"familyName2";
NSString *const kGender = @"gender";
NSString *const kbirthdateEstimated = @"birthdateEstimated";
NSString *const kAge = @"age";
NSString *const kBirthdate = @"birthdate";
NSString *const kIdentifier = @"identifier";
NSString *const kAddress1 = @"address1";
NSString *const kAddress2 = @"address2";
NSString *const kAddress3 = @"address3";
NSString *const kAddress4 = @"address4";
NSString *const kAddress5 = @"address5";
NSString *const kAddress6 = @"address6";
NSString *const kCityVillage = @"cityVillage";
NSString *const kStateProvince = @"stateProvince";
NSString *const kCountry = @"country";
NSString *const kPostalCode = @"postalCode";

@interface AddPatientForm ()

@property (nonatomic, strong) MRSPatientIdentifier *patientIdentifier;

@end

@implementation AddPatientForm

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        [self initializeForm];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeForm];
    }
    return self;
}

- (void)initializeForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"Add Patient", @"Label -add- -patient-")];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    /* =========================================== Name Section =====================================*/
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Preferred Name", @"Label named -Preferred- -Name-)")];
    [form addFormSection:section];
    
    //Given Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kGivenName
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"Given Name", @"Given -first name")];
    [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"Required", @"Place holder -required-")] forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = YES;
    [section addFormRow:row];
    
    //Middle Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMiddleName
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"Middle Name", @"Middle name")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    //Family name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFamilyName
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"Family Name", @"Family name")];
    [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"Required", @"Place holder -required-")] forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = YES;
    [section addFormRow:row];
    
    //Family name2
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFamilyName2
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:[NSString stringWithFormat:@"%@2", NSLocalizedString(@"Family Name", @"Family name")]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
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
    row.required = YES;
    [section addFormRow:row];
    
    //Birthdate estimated?
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kbirthdateEstimated
                                                rowType:XLFormRowDescriptorTypeBooleanSwitch
                                                  title:NSLocalizedString(@"BirthDate Estimated", @"Is birth date estimated?")];
    row.value = @1;
    [section addFormRow:row];
    
    //Age
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAge
                                                rowType:XLFormRowDescriptorTypeInteger
                                                  title:NSLocalizedString(@"Age", @"Label age")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = YES;
    //Validation it is > 0 and < 120
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"" regex:@"^([1-9]|[1-9][0-9]|[1][0-1][0-9])$"]];
    [section addFormRow:row];
    row.hidden = [NSString stringWithFormat:@"$%@==0", kbirthdateEstimated];

    //Birthdate
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBirthdate
                                                rowType:XLFormRowDescriptorTypeDate
                                                  title:NSLocalizedString(@"BirthDate", @"Birth date of person")];
    row.required = YES;
    [section addFormRow:row];
    row.hidden = [NSString stringWithFormat:@"$%@==1", kbirthdateEstimated];
    
    // Identifier Type
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kIdentifier rowType:XLFormRowDescriptorTypeSelectorPush title:NSLocalizedString(@"Identifier", @"Label identifier")];
    row.action.viewControllerClass = [SelectPatientIdentifierTypeTableViewController class];
    row.required = YES;
    [section addFormRow:row];
    
    /* =========================================== Address Section =====================================*/
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"Preferred Address", @"Label named -Preferred- -Address-")];
    [form addFormSection:section];
    
    //Address 1
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress1
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:[NSString stringWithFormat:@"%@ 1", NSLocalizedString(@"Address", "Address")]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"Required", @"Place holder -required-")] forKey:@"textField.placeholder"];
    row.required = YES;
    [section addFormRow:row];
    
    //Address 2
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress2
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:[NSString stringWithFormat:@"%@ 2", NSLocalizedString(@"Address", "Address")]];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    //City Village
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCityVillage
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"City Village", @"City village")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    //State Province
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kStateProvince
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"State Province" , @"State province")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];

    
    //Country
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCountry
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:NSLocalizedString(@"Country", @"Country")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];

    
    //Postal Code
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPostalCode
                                                rowType:XLFormRowDescriptorTypeInteger
                                                  title:NSLocalizedString(@"Postal Code", @"Postal code")];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    self.form = form;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Label close")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(processForm)];
}

#pragma mark - SelectPatientIdentifierTypeTableViewControllerDelegate

- (void)didSelectPatientIdentifierType:(MRSPatientIdentifierType *)type {
    self.patientIdentifier = [[MRSPatientIdentifier alloc] init];
    self.patientIdentifier.identifierType = type;
    self.patientIdentifier.identifier = self.formValues[kIdentifier];
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - barbuttonActions

- (void)processForm {
    NSDictionary *values = self.form.formValues;
    if ([self validateForm]) {
        NSMutableDictionary *address_parameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                  kAddress1: values[kAddress1]
                                                                                                  }];
        XLFormSectionDescriptor *address_section = self.form.formSections[2];
        for (XLFormRowDescriptor *address_row in address_section.formRows) {
            if (![MRSHelperFunctions isNull:address_row.value]) {
                address_parameters[address_row.tag] = values[address_row.tag];
            }
        }
        
        NSMutableDictionary *name_parameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                               kGivenName: values[kGivenName],
                                                                                               kFamilyName: values[kFamilyName]
                                                                                               }];
        XLFormSectionDescriptor *name_section = self.form.formSections[0];
        for (XLFormRowDescriptor *name_row in name_section.formRows) {
            if (![MRSHelperFunctions isNull:name_row.value]) {
                name_parameters[name_row.tag] = values[name_row.tag];
            }
        }
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                          @"addresses": @[address_parameters],
                                                                                          @"names": @[name_parameters],
                                                                                          kGender: values[kGender]
                                                                                          }];
        if ([values[kbirthdateEstimated] integerValue] == 1) {
            parameters[kAge] = values[kAge];
        } else {
            parameters[kBirthdate] = [MRSDateUtilities openMRSFormatStringWithDate:values[kBirthdate]];
        }
    }
    NSLog(@"Values: %@", self.form.formValues);
}

- (BOOL)validateForm {
    NSArray * array = [self formValidationErrors];
    BOOL valid = YES;
    for(id obj in array) {
        XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
        NSString *tag = validationStatus.rowDescriptor.tag;
        if ([tag isEqualToString:kGivenName] || [tag isEqualToString:kFamilyName] ||
            [tag isEqualToString:kIdentifier] || [tag isEqualToString:kAddress1] ||
            [tag isEqualToString:kAge] || [tag isEqualToString:kBirthdate]){

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
@end
