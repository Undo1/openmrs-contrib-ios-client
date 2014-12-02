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
@interface OpenMRSAPIManager : NSObject
+ (void)getPatientListWithSearch:(NSString *)search completion:(void (^)(NSError *error, NSArray *patients))completion;
+ (void)getDetailedDataOnPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, MRSPatient *detailedPatient))completion;
+ (void)verifyCredentialsWithUsername:(NSString *)username password:(NSString *)password host:(NSString *)host completion:(void (^)(BOOL success))completion;
+ (void)getVisitsForPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, NSArray *visits))completion;
+ (void)getEncountersForPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, NSArray *encounters))completion;
+ (void)logout;
@end
