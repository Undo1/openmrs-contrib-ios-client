//
//  MRSDateUtilities.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 5/21/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "MRSDateUtilities.h"
#import "MRSHelperFunctions.h"

@implementation MRSDateUtilities

+ (NSString *)openMRSFormatStringWithDate:(NSDate *)date
{
    if ([MRSHelperFunctions isNull:date]) {
        return @"";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timeZone];
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

+ (NSDate *)dateFromOpenMRSFormattedString:(NSString *) openmrsDate {
    if ([MRSHelperFunctions isNull:openmrsDate]) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    //NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    //[formatter setTimeZone:timeZone];
    NSDate *date = [formatter dateFromString:openmrsDate];
    return date;
}

@end
