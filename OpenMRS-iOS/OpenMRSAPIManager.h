//
//  OpenMRSAPIManager.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//  
//

#import <Foundation/Foundation.h>
#import "MRSPatient.h"
#import "MRSEncounter.h"
#import "MRSLocation.h"
@interface OpenMRSAPIManager : NSObject
+ (void)getPatientListWithSearch:(NSString *)search completion:(void (^)(NSError *error, NSArray *patients))completion;
+ (void)getDetailedDataOnPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, MRSPatient *detailedPatient))completion;
+ (void)verifyCredentialsWithUsername:(NSString *)username password:(NSString *)password host:(NSString *)host completion:(void (^)(BOOL success))completion;
+ (void)getVisitsForPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, NSArray *visits))completion;
+ (void)getDetailedDataOnEncounter:(MRSEncounter *)encounter completion:(void (^)(NSError *, MRSEncounter *))completion;
+ (void)getEncounterTypesWithCompletion:(void (^)(NSError *, NSArray *))completion;
+ (void)getEncountersForPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, NSArray *encounters))completion;
+ (void)addVisitNote:(NSString *)note toPatient:(MRSPatient *)patient atLocation:(MRSLocation *)location completion:(void (^)(NSError *error))completion;
+ (void)captureVitals:(NSArray *)vitals toPatient:(MRSPatient *)patient atLocation:(MRSLocation *)location completion:(void (^)(NSError *error))completion;
+ (void)getLocationsWithCompletion:(void (^)(NSError *error, NSArray *locations))completion;
+ (void)logout;
@end
