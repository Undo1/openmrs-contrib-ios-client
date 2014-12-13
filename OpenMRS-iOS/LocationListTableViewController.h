//
//  LocationListTableViewController.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/12/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRSLocation;
@protocol LocationListTableViewControllerDelegate <NSObject>
- (void)didChooseLocation:(MRSLocation *)location;
@end
@interface LocationListTableViewController : UITableViewController
@property (nonatomic, strong) NSObject<LocationListTableViewControllerDelegate> *delegate;
@property (nonatomic, strong) NSArray *locations;
@end
