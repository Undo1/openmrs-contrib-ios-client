//
//  XFormsList.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/19/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRSPatient.h"

@interface XFormsList : UITableViewController

@property (nonatomic, strong) MRSPatient *patient;

- (instancetype)initBlankForms;
- (instancetype)initFilledForms;

@end
