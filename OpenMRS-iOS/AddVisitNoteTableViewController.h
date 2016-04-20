//
//  AddVisitNoteTableViewController.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/12/14.
//

#import <UIKit/UIKit.h>
#import "LocationListTableViewController.h"
@class MRSPatient;

@protocol AddVisitNoteTableViewControllerDelegate <NSObject>
- (void)didAddVisitNoteToPatient:(MRSPatient *)patient;
@end

@interface AddVisitNoteTableViewController : UITableViewController <UITextViewDelegate, LocationListTableViewControllerDelegate, UIViewControllerRestoration>
@property (nonatomic, strong) MRSPatient *patient;
@property (nonatomic, strong) NSObject<AddVisitNoteTableViewControllerDelegate> *delegate;
@property (nonatomic, strong) NSString *currentVisitNote;
@property (nonatomic, strong) MRSLocation *currentLocation;
@end
