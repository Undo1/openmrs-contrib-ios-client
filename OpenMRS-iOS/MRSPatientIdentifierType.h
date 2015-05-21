//
//  MRSPatientIdentifiertype.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/11/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSPatientIdentifierType : NSObject
@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, strong) NSString *display;
@property (nonatomic, strong) NSString *typeDescription;
@end
