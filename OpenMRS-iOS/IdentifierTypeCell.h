//
//  MRSVisitCell.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 6/26/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSPatientIdentifierType;
@interface IdentifierTypeCell : UITableViewCell

@property (nonatomic, strong) MRSPatientIdentifierType *IdentifierType;
@property (nonatomic, strong) NSNumber *index;

- (void)setIdentifierType:(MRSPatientIdentifierType *)identifierType;
+ (void)updateTableViewForDynamicTypeSize:(UITableView *) tableview;

@end
