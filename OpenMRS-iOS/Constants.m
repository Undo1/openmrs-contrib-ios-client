//
//  Constants.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/5/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "Constants.h"
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
NSString *const kXFormsRepeat = @"repeat";
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
             kXFormsImage: XLFormRowDescriptorTypeSelectorPush,
             kXFormsAudio: XLFormRowDescriptorTypeSelectorPush,
             kXFormsGPS: XLFormRowDescriptorTypeSelectorPush
             };
}

@end
