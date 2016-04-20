//
//  AddPatientTableViewController.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/9/14.
//

#import <UIKit/UIKit.h>
#import "SelectPatientIdentifierTypeTableViewController.h"
@class MRSPatient;
@protocol AddPatientTableViewControllerDelegate <NSObject>
- (void)didAddPatient:(MRSPatient *)patient;
@end

@interface AddPatientTableViewController : UITableViewController <UITextFieldDelegate, SelectPatientIdentifierTypeTableViewControllerDelegate, UIViewControllerRestoration>
@property (nonatomic, strong) NSString *selectedGender;
@property (nonatomic, strong) NSString *selectedGivenName;
@property (nonatomic, strong) NSString *selectedFamilyName;
@property (nonatomic, strong) NSString *selectedAge;
@property (nonatomic, strong) NSString *selectedIdentifier;
@property (nonatomic, strong) MRSPatientIdentifierType *selectedIdentifierType;
@end
