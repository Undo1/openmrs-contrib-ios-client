//
//  LocationListTableViewController.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/12/14.
//

#import <UIKit/UIKit.h>
#import "XLFormRowDescriptor.h"
@class MRSLocation;
@protocol LocationListTableViewControllerDelegate <NSObject>
- (void)didChooseLocation:(MRSLocation *)location;
@end
@interface LocationListTableViewController : UITableViewController <UIViewControllerRestoration, XLFormRowDescriptorViewController>
@property (nonatomic, strong) NSObject<LocationListTableViewControllerDelegate> *delegate;
@property (nonatomic, strong) NSArray *locations;
@end
