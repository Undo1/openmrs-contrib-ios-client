//
//  EditPatientForm.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/5/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XLForm.h"
#import "XLFormViewController.h"
#import "MRSPatient.h"

@interface EditPatientForm : XLFormViewController <UIAlertViewDelegate>

- (instancetype)initWithPatient:(MRSPatient *)patient;
@property (nonatomic, strong) MRSPatient *patient;

@end