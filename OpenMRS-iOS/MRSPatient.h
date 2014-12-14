//
//  MRSPatient.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//  
//

#import <Foundation/Foundation.h>

@interface MRSPatient : NSObject
@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic) BOOL dead;
@property (nonatomic, strong) NSString *causeOfDeath;
@property (nonatomic, strong) NSString *locationDisplay;
@property (nonatomic, strong) NSString *address1;
@property (nonatomic, strong) NSString *address2;
@property (nonatomic, strong) NSString *address3;
@property (nonatomic, strong) NSString *address4;
@property (nonatomic, strong) NSString *address5;
@property (nonatomic, strong) NSString *address6;
@property (nonatomic, strong) NSString *cityVillage;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *countyDistrict;
@property (nonatomic, strong) NSString *display;
@property (nonatomic, strong) NSString *endDate;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *stateProvince;
@property (nonatomic, strong) NSString *birthdate;
@property (nonatomic, strong) NSString *birthdateEstimated;
@property (nonatomic, strong) NSString *deathDate;
@property (nonatomic, strong) NSString *familyName;
@property (nonatomic, strong) NSString *familyName2;
@property (nonatomic, strong) NSString *givenName;
@property (nonatomic, strong) NSString *middleName;

@property (nonatomic) BOOL fromCoreData;
@property (nonatomic) BOOL hasDetailedInfo;

- (void)saveToCoreData;
- (void)updateFromCoreData;
- (BOOL)isInCoreData;

@end
