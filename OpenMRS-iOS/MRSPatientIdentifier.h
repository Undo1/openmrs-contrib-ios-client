//
//  MRSPatientIdentifier.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/11/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MRSPatientIdentifierType;
@interface MRSPatientIdentifier : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) MRSPatientIdentifierType *identifierType;
@end
