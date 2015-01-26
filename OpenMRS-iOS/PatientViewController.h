//
//  PatientViewController.h
//  
//
//  Created by Parker Erway on 12/1/14.
//
//

#import <UIKit/UIKit.h>
#import "MRSPatient.h"
#import "AddVisitNoteTableViewController.h"
#import "CaptureVitalsTableViewController.h"
#import "OpenMRS_iOS-Swift.h"

@interface PatientViewController : UITableViewController <AddVisitNoteTableViewControllerDelegate, CaptureVitalsTableViewControllerDelegate, StartVisitViewControllerDelegate>
@property (nonatomic, strong) MRSPatient *patient;
@property (nonatomic, strong) NSArray *information;
@property (nonatomic, strong) NSArray *visits;
@property (nonatomic, strong) NSArray *encounters;
@property (nonatomic) BOOL isShowingActions;
@property (nonatomic) BOOL hasActiveVisit;
@end
