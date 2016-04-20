//
//  MRSLocation.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/12/14.
//

#import "MRSLocation.h"
#import "MRSHelperFunctions.h"

@implementation MRSLocation

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        for (NSString *key in [MRSHelperFunctions allPropertyNames:self]) {
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *key in [MRSHelperFunctions allPropertyNames:self]) {
        if (![MRSHelperFunctions isNull:[self valueForKey:key]]) {
            NSLog(@"key: %@, value: %@", key, [self valueForKey:key]);
            [aCoder encodeObject:[self valueForKey:key] forKey:key];
        }
    }
}

@end
