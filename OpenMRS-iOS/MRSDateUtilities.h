//
//  MRSDateUtilities.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 5/21/15.
//

#import <Foundation/Foundation.h>

@interface MRSDateUtilities : NSObject

+ (NSDate *)dateFromOpenMRSFormattedString:(NSString *) openmrsDate;
+ (NSString *)XFormformatStringwithDate:(NSDate *)date type:(NSString *)type;
+ (NSString *)openMRSFormatStringWithDate:(NSDate *)date;
+ (NSDate *)DatefromXFormsString:(NSString *)dateString type:(NSString *)type;

@end
