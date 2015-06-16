//
//  EditPatient.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 6/15/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRSPatient.h"

@interface EditPatient : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) MRSPatient *patient;

@end
