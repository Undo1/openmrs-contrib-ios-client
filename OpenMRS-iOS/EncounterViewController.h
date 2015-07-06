//
//  EncounterViewController.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/4/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRSEncounter.h"
@interface EncounterViewController : UITableViewController <UIViewControllerRestoration>
@property (nonatomic, strong) MRSEncounter *encounter;
@end
