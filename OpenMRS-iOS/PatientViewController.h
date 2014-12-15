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

@interface PatientViewController : UITableViewController <AddVisitNoteTableViewControllerDelegate, CaptureVitalsTableViewControllerDelegate>
@property (nonatomic, strong) MRSPatient *patient;
@property (nonatomic, strong) NSArray *information;
@property (nonatomic, strong) NSArray *visits;
@property (nonatomic, strong) NSArray *encounters;
@property (nonatomic) BOOL isShowingActions;
@end
