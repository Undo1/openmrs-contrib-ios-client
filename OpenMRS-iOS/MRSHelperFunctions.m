//
//  MRSHelperFunctions.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 6/16/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "MRSHelperFunctions.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "MRSPatient.h"

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

+ (void)updateTableViewForDynamicTypeSize:(UITableView *) tableview {
    static NSDictionary *cellHeightDictionary;
    
    if (!cellHeightDictionary) {
        cellHeightDictionary = @{ UIContentSizeCategoryExtraSmall : @33,
                                  UIContentSizeCategorySmall : @33,
                                  UIContentSizeCategoryMedium : @44,
                                  UIContentSizeCategoryLarge : @44,
                                  UIContentSizeCategoryExtraLarge : @55,
                                  UIContentSizeCategoryExtraExtraLarge : @66,
                                  UIContentSizeCategoryExtraExtraExtraLarge : @70
                                  };
    }
    
    NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    
    NSNumber *cellHeight = cellHeightDictionary[userSize];
    [tableview setRowHeight:cellHeight.floatValue];
    [tableview reloadData];
}

+ (MRSPatient *)fillPatientWithResponse:(NSDictionary *)results {
    MRSPatient *detailedPatient = [[MRSPatient alloc] init];
    detailedPatient.displayName = results[@"display"];
    detailedPatient.locationDisplay = results[@"location"][@"display"];
    if (![MRSHelperFunctions isNull:results[@"person"][@"preferredAddress"]]) {
        detailedPatient.preferredAddressUUID = results[@"person"][@"preferredAddress"][@"uuid"];
        detailedPatient.address1 = results[@"person"][@"preferredAddress"][@"address1"];
        detailedPatient.address2 = results[@"person"][@"preferredAddress"][@"address2"];
        detailedPatient.address3 = results[@"person"][@"preferredAddress"][@"address3"];
        detailedPatient.address4 = results[@"person"][@"preferredAddress"][@"address4"];
        detailedPatient.address5 = results[@"person"][@"preferredAddress"][@"address5"];
        detailedPatient.address6 = results[@"person"][@"preferredAddress"][@"address6"];
        detailedPatient.cityVillage = results[@"person"][@"preferredAddress"][@"cityVillage"];
        detailedPatient.country = results[@"person"][@"preferredAddress"][@"country"];
        detailedPatient.latitude = results[@"person"][@"preferredAddress"][@"latitude"];
        detailedPatient.longitude = results[@"person"][@"preferredAddress"][@"longitude"];
        detailedPatient.postalCode = results[@"person"][@"preferredAddress"][@"postalCode"];
        detailedPatient.stateProvince = results[@"person"][@"preferredAddress"][@"stateProvince"];
        detailedPatient.countyDistrict = results[@"person"][@"preferredAddress"][@"countyDistrict"];
        detailedPatient.preferredAddressUUID = results[@"person"][@"preferredAddress"][@"uuid"];
    }
    detailedPatient.birthdate = results[@"person"][@"birthdate"];
    detailedPatient.birthdateEstimated = [results[@"person"][@"birthdateEstimated"] boolValue]?@"true":@"false";
    detailedPatient.causeOfDeath = results[@"person"][@"causeOfDeath"];
    detailedPatient.dead = ((int)results[@"person"][@"dead"] == 1);
    detailedPatient.gender = results[@"person"][@"gender"];
    detailedPatient.UUID = results[@"uuid"];
    detailedPatient.name = results[@"display"];
    detailedPatient.preferredNameUUID = results[@"person"][@"preferredName"][@"uuid"];
    detailedPatient.familyName = results[@"person"][@"preferredName"][@"familyName"];
    detailedPatient.familyName2 = results[@"person"][@"preferredName"][@"familyName2"];
    detailedPatient.givenName = results[@"person"][@"preferredName"][@"givenName"];
    detailedPatient.middleName = results[@"person"][@"preferredName"][@"middleName"];
    detailedPatient.preferredNameUUID = results[@"person"][@"preferredName"][@"uuid"];
    if (results[@"person"][@"age"] != [NSNull null]) {
        detailedPatient.age = [results[@"person"][@"age"] stringValue];
    }
    detailedPatient.hasDetailedInfo = YES;
    return detailedPatient;
}

@end
