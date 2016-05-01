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

@protocol AddVisitNoteTableViewControllerDelegate;
@protocol StartVisitViewControllerDelegate;
@protocol CaptureVitalsTableViewControllerDelegate;

@interface PatientViewController : UITableViewController <AddVisitNoteTableViewControllerDelegate, CaptureVitalsTableViewControllerDelegate, StartVisitViewControllerDelegate, UIViewControllerRestoration>
@property (nonatomic, strong) MRSPatient *patient;
@property (nonatomic, strong) NSArray *information;
@property (nonatomic, strong) NSArray *visits;
@property (nonatomic, strong) NSArray *encounters;
@property (nonatomic) BOOL isShowingActions;
@property (nonatomic) BOOL hasActiveVisit;

@property (nonatomic, strong) NSTimer *refreshingTimer;

@property (nonatomic) BOOL patientEdited;
@property (nonatomic) BOOL encoutersEdited;
@property (nonatomic) BOOL visitsEdited;

- (void)updateWithDetailedInfo;
- (void)presentEditViewController:(MRSPatient *)patient;
- (void)presentEditViewController:(MRSPatient *)patient fromViewController:(UIViewController *)viewController;
- (void)presentCaptureVitalsViewController:(MRSPatient *)patient;
- (void)presentCaptureVitalsViewController:(MRSPatient *)patient fromViewController:(UIViewController *)viewController;
@end
