//
//  PatientEncounterListView.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/2/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatientEncounterListView : UITableViewController <UIViewControllerRestoration>
@property (nonatomic, strong) NSArray *encounters;
@end
