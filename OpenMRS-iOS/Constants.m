//
//  Constants.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/5/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "Constants.h"
#import "XFormImageCell.h"
#import "XFormAudioCell.h"
#import <XLForm.h>

@implementation Constants

NSString *const kGivenName = @"givenName";
NSString *const kMiddleName = @"middleName";
NSString *const kFamilyName = @"familyName";
NSString *const kFamilyName2 = @"familyName2";
NSString *const kGender = @"gender";
NSString *const kbirthdateEstimated = @"birthdateEstimated";
NSString *const kAge = @"age";
NSString *const kBirthdate = @"birthdate";
NSString *const kIdentifier = @"identifier";
NSString *const kIdentifierType = @"identifierType";
NSString *const kDead = @"dead";
NSString *const kCauseOfDeath = @"causeOfDeath";
NSString *const kDeathDate = @"DeathDate";
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


NSString *const kXFormsString = @"xsd:string";
NSString *const kXFormsNumber = @"xsd:int";
NSString *const kXFormsDecimal = @"xsd:decimal";
NSString *const kXFormsDate = @"xsd:date";
NSString *const kXFormsTime = @"xsd:time";
NSString *const kXFormsDateTime = @"xsd:dateTime";
NSString *const kXFormsBoolean = @"xsd:boolean";

NSString *const kXFormsUpload = @"upload";
NSString *const kXFormsGroup = @"group";
NSString *const kXFormsSelect = @"select1";
NSString *const kXFormsMutlipleSelect = @"select";
NSString *const kXFormsRepeat = @"xf:repeat";
NSString *const kXFormBase64 = @"xsd:base64Binary";

NSString *const kXFormsImage = @"image";
NSString *const kXFormsAudio = @"audio";
NSString *const kXFormsGPS = @"gps";


+ (NSDictionary *)MAPPING_TYPES {
    return @{
             kXFormsString: XLFormRowDescriptorTypeText,
             kXFormsNumber: XLFormRowDescriptorTypeNumber,
             kXFormsDecimal: XLFormRowDescriptorTypeDecimal,
             kXFormsDate: XLFormRowDescriptorTypeDate,
             kXFormsTime: XLFormRowDescriptorTypeTime,
             kXFormsDateTime: XLFormRowDescriptorTypeDateTime,
             kXFormsBoolean: XLFormRowDescriptorTypeBooleanSwitch,
             kXFormsSelect: XLFormRowDescriptorTypeSelectorPush,
             kXFormsMutlipleSelect: XLFormRowDescriptorTypeMultipleSelector,
             kXFormsImage: XLFormRowDescriptorTypeImageInLine,
             kXFormsAudio: XLFormRowDescriptorTypeAudioInLine,
             kXFormsGPS: XLFormRowDescriptorTypeSelectorPush
             };
}

NSString *const UDisWizard = @"isWizard";
NSString *const UDblankForms = @"blankForms";
NSString *const UDfilledForms = @"filledForms";
NSString *const UDnewSession = @"newSession";
NSString *const UDrefreshInterval = @"refreshInterval";

+ (NSDictionary *)PATIENT_ATTRIBUTES {
    return @{
             @"patient.birthdate": @"birthdate",
             @"patient.birthdate_estimated": @"birthdateEstimated",
             @"patient.family_name": @"familyName",
             @"patient.given_name": @"givenName",
             @"patient.middle_name": @"middleName",
             @"patient.medical_record_number": @"displayName",
             @"patient.sex": @"gender",
             @"patient_address.address1": @"address1",
             @"patient_address.address2": @"address2"
             };
}

+ (NSDictionary *)PATIENT_ATTRIBUTES_TYPES {
    return @{
             @"patient.birthdate": kXFormsDate,
             @"patient.birthdate_estimated": kXFormsBoolean,
             @"patient.family_name": kXFormsString,
             @"patient.given_name": kXFormsString,
             @"patient.middle_name": kXFormsString,
             @"patient.medical_record_number": kXFormsString,
             @"patient.sex": kXFormsString,
             @"patient_address.address1": kXFormsString,
             @"patient_address.address2": kXFormsString
             };
}

NSInteger const errNoInternet = -1004;
NSInteger const errBadRequest = -1011;
NSInteger const errServerNotFound = -1003;
NSInteger const errTimeout = -1001;
NSInteger const errNetWorkLost = -1005;

@end
