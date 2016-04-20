//
//  MRSHelperFunctions.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 6/16/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MRSPatient.h"

@interface MRSHelperFunctions : NSObject

+ (NSArray *)allPropertyNames:(id)forClass;
+ (BOOL)isNull:(id)object;
+ (NSString *) formLabelToJSONLabel:(NSString *) label;
+ (void)updateTableViewForDynamicTypeSize:(UITableView *) tableview;
+ (MRSPatient *)fillPatientWithResponse:(NSDictionary *)results;

@end
