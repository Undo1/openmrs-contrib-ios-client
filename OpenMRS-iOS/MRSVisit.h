//
//  MRSVisit.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/2/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRSLocation.h"

@class MRSVisitType;
@interface MRSVisit : NSObject <NSCoding>
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, strong) NSString *startDateTime;
@property (nonatomic, strong) MRSVisitType *visitType;
@property (nonatomic, strong) MRSLocation *location;
@property (nonatomic) BOOL active;
@end
