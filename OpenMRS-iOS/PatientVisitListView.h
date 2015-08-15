//
//  PatientVisitListView.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/2/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientViewController.h"

@interface PatientVisitListView : UITableViewController <UIViewControllerRestoration>
@property (nonatomic, strong) NSArray *visits;

@property (nonatomic, strong) PatientViewController *pvc;
@end
