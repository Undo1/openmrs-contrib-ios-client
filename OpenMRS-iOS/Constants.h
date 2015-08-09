//
//  Constants.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/5/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString *const kGivenName;
extern NSString *const kMiddleName;
extern NSString *const kFamilyName;
extern NSString *const kFamilyName2;
extern NSString *const kGender;
extern NSString *const kbirthdateEstimated;
extern NSString *const kAge;
extern NSString *const kBirthdate;
extern NSString *const kDead;
extern NSString *const kCauseOfDeath;
extern NSString *const kDeathDate;
extern NSString *const kIdentifier;
extern NSString *const kIdentifierType;
extern NSString *const kAddress1;
extern NSString *const kAddress2;
extern NSString *const kAddress3;
extern NSString *const kAddress4;
extern NSString *const kAddress5;
extern NSString *const kAddress6;
extern NSString *const kCityVillage;
extern NSString *const kStateProvince;
extern NSString *const kCountry;
extern NSString *const kPostalCode;


extern NSString *const kXFormsString;
extern NSString *const kXFormsNumber;
extern NSString *const kXFormsDecimal;
extern NSString *const kXFormsDate;
extern NSString *const kXFormsTime;
extern NSString *const kXFormsDateTime;
extern NSString *const kXFormsBoolean;

extern NSString *const kXFormsUpload;
extern NSString *const kXFormsGroup;
extern NSString *const kXFormsSelect;
extern NSString *const kXFormsMutlipleSelect;
extern NSString *const kXFormsRepeat;
extern NSString *const kXFormBase64;

extern NSString *const kXFormsImage;
extern NSString *const kXFormsAudio;
extern NSString *const kXFormsGPS;

+ (NSDictionary *)MAPPING_TYPES;


extern NSString *const UDisWizard;
extern NSString *const UDblankForms;
extern NSString *const UDfilledForms;
extern NSString *const UDnewSession;
@end
