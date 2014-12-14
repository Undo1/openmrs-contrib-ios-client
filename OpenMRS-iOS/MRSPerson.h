//
//  MRSPerson.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/9/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSPerson : NSObject
@property (nonatomic, strong) NSString *familyName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSString *birthdate;
@property (nonatomic, strong) NSString *estimatedBirthdate;
@property (nonatomic, strong) NSString *dead;
@property (nonatomic, strong) NSString *deathDate;
@property (nonatomic, strong) NSString *causeOfDeath;
@property (nonatomic, strong) NSString *addresses;
@end
