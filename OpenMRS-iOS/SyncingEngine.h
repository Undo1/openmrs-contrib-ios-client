//
//  SyncingEngine.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/4/15.
//

#import <Foundation/Foundation.h>

@class MRSPatient;
@interface SyncingEngine : NSObject

+(SyncingEngine *)sharedEngine;
- (void)updateExistingPatientsInCoreData:(void (^)(NSError *error))completion;
- (void)updateExistingOutOfDatePatients:(void (^)(NSError *error))completion;
- (void)SyncPatient:(MRSPatient *)patient completion:(void (^)(NSError *error))completion;
@end
