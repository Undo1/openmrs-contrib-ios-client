//
//  AddPatientTableViewController.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/9/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPatientTableViewController : UITableViewController <UITextFieldDelegate>
@property (nonatomic, strong) NSString *selectedGender;
@property (nonatomic, strong) NSString *selectedGivenName;
@property (nonatomic, strong) NSString *selectedFamilyName;
@end
