//
//  SyncingEngine.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/4/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRSPatient;
@interface SyncingEngine : NSObject

+(SyncingEngine *)sharedEngine;
- (void)updateExistingPatientsInCoreData:(void (^)(NSError *error))completion;
- (void)updateExistingOutOfDatePatients:(void (^)(NSError *error))completion;
- (void)SyncPatient:(MRSPatient *)patient completion:(void (^)(NSError *error))completion;
@end
