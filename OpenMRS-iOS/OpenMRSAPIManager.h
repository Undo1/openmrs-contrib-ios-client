//
//  OpenMRSAPIManager.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//  
//

#import <Foundation/Foundation.h>
#import "MRSPatient.h"
#import "MRSPatientIdentifier.h"
#import "MRSEncounter.h"
#import "MRSVisit.h"
#import "MRSLocation.h"
@class MRSVisitType;

@interface OpenMRSAPIManager : NSObject
+ (void)getPatientListWithSearch:(NSString *)search online:(BOOL)online completion:(void (^)(NSError *error, NSArray *patients))completion;
+ (void)getDetailedDataOnPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, MRSPatient *detailedPatient))completion;
+ (void)verifyCredentialsWithUsername:(NSString *)username password:(NSString *)password host:(NSString *)host completion:(void (^)(BOOL success))completion;
+ (void)getVisitsForPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, NSArray *visits))completion;
+ (void)getDetailedDataOnEncounter:(MRSEncounter *)encounter completion:(void (^)(NSError *, MRSEncounter *))completion;
+ (void)getEncounterTypesWithCompletion:(void (^)(NSError *, NSArray *))completion;
+ (void)getEncountersForPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, NSArray *encounters))completion;
+ (void)getPatientIdentifierTypesWithCompletion:(void (^)(NSError *error, NSArray *types))completion;
+ (void)addPatient:(NSDictionary *)parameters withIdentifier:(MRSPatientIdentifierType *)identifier completion:(void (^)(NSError *error, MRSPatient *createdPatient))completion;
+ (void)addVisitNote:(NSString *)note toPatient:(MRSPatient *)patient atLocation:(MRSLocation *)location completion:(void (^)(NSError *error))completion;
+ (void)captureVitals:(NSArray *)vitals toPatient:(MRSPatient *)patient atLocation:(MRSLocation *)location completion:(void (^)(NSError *error))completion;
+ (void)startVisitWithLocation:(MRSLocation *)location visitType:(MRSVisitType *)visitType forPatient:(MRSPatient *)patient completion:(void (^)(NSError *error))completion;
+ (void)stopVisit:(MRSVisit *)visit completion:(void (^)(NSError *))completion;
+ (void)currentlyActiveVisitFromVisits:(NSArray *)visits withCompletion:(void (^)(NSError *error, MRSVisit *visit))completion;
+ (void)getActiveVisits:(NSMutableArray *)activeVisits  From:(int)startIndex  withCompletion:(void (^)(NSError *error))completion;
+ (void)getVisitTypesWithCompletion:(void (^)(NSError *error, NSArray *types))completion;
+ (void)getLocationsWithCompletion:(void (^)(NSError *error, NSArray *locations))completion;
+ (void)EditPatient:(MRSPatient *)patient completion:(void (^)(NSError *error))completion;
+ (void)EditAddressForPatient:(MRSPatient *) patient completion:(void (^)(NSError *error))completion;
+ (void)EditNameForPatient:(MRSPatient *) patient completion:(void (^)(NSError *error))completion;
+ (void)logout;
@end
