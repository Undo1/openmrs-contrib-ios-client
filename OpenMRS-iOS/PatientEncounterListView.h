//
//  PatientEncounterListView.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/2/14.
//

#import <UIKit/UIKit.h>
#import "PatientViewController.h"

@interface PatientEncounterListView : UITableViewController <UIViewControllerRestoration>
@property (nonatomic, strong) NSArray *encounters;
@end
