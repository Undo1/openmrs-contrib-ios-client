//
//  CaptureVitalsTableViewController.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/12/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationListTableViewController.h"

@class MRSPatient;
@class MRSLocation;

@protocol CaptureVitalsTableViewControllerDelegate <NSObject>
- (void)didCaptureVitalsForPatient:(MRSPatient *)patient;
@end

@interface CaptureVitalsTableViewController : UITableViewController <LocationListTableViewControllerDelegate>
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSMutableDictionary *textFieldValues;
@property (nonatomic, strong) MRSPatient *patient;
@property (nonatomic, strong) MRSLocation *currentLocation;
@property (nonatomic, strong) NSObject<CaptureVitalsTableViewControllerDelegate> *delegate;
@end
