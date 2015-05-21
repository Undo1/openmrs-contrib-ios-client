//
//  MRSDateUtilities.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 5/21/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSDateUtilities : NSObject

+ (NSDate *)dateFromOpenMRSFormattedString:(NSString *) openmrsDate;
+ (NSString *)openMRSFormatStringWithDate:(NSDate *)date;

@end
