//
//  MRSDateUtilities.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 5/21/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "MRSDateUtilities.h"

@implementation MRSDateUtilities

+ (NSString *)openMRSFormatStringWithDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-d'T'HH:mm:ss.SSS-ZZZZ"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timeZone];
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

+ (NSDate *)dateFromOpenMRSFormattedString:(NSString *) openmrsDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-d'T'HH:mm:ss.SSSZ"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timeZone];
    NSDate *date = [formatter dateFromString:openmrsDate];
    return date;
}

@end
