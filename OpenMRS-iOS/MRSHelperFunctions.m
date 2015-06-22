//
//  MRSHelperFunctions.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 6/16/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "MRSHelperFunctions.h"
#import <objc/runtime.h>

@implementation MRSHelperFunctions

+ (NSArray *)allPropertyNames:(id)forClass
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([forClass class], &count);
    NSMutableArray *propetiesList = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [propetiesList addObject:name];
    }
    free(properties);
    return propetiesList;
}

+ (BOOL)isNull:(id)object {
    if (object == nil || object == (id)[NSNull null]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *) formLabelToJSONLabel:(NSString *) label {
    NSMutableArray *words = (NSMutableArray *)[label componentsSeparatedByString:@" "];
    if (words.count == 1){
        return [label lowercaseString];
    }
    words[0] = [words[0] lowercaseString];;
    return [words componentsJoinedByString:@""];
}

@end
