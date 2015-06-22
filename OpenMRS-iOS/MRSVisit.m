//
//  MRSVisit.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/2/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "MRSVisit.h"
#import "MRSHelperFunctions.h"

@implementation MRSVisit

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        for (NSString *key in [MRSHelperFunctions allPropertyNames:self]) {
            if (![MRSHelperFunctions isNull:[aDecoder decodeObjectForKey:key]]) {
                if ([key isEqualToString:@"active"]) {
                    self.active = [[aDecoder decodeObjectForKey:@"active"] boolValue];
                } else {
                    [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
                }
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *key in [MRSHelperFunctions allPropertyNames:self]) {
        if (![MRSHelperFunctions isNull:[self valueForKey:key]]) {
            if ([key isEqualToString:@"active"]) {
                [aCoder encodeObject:[NSNumber numberWithBool:self.active] forKey:@"active"];
            } else {
                [aCoder encodeObject:[self valueForKey:key] forKey:key];
            }
        }
    }
}
@end
