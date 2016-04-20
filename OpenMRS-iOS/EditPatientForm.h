//
//  EditPatientForm.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/5/15.
//

#import "XLForm.h"
#import "XLFormViewController.h"
#import "MRSPatient.h"

@interface EditPatientForm : XLFormViewController <UIAlertViewDelegate, UIViewControllerRestoration>

@property (nonatomic, strong) MRSPatient *patient;

- (instancetype)initWithPatient:(MRSPatient *)patient;

@end