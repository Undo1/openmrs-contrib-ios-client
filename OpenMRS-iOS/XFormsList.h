//
//  XFormsList.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/19/15.
//

#import <UIKit/UIKit.h>
#import "MRSPatient.h"
#import "PatientViewController.h"

@interface XFormsList : UITableViewController <UIViewControllerRestoration>

@property (nonatomic, strong) MRSPatient *patient;

- (instancetype)initBlankForms;
- (instancetype)initFilledForms;

@end
