//
//  PatientSearchViewController.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//  
//

#import <UIKit/UIKit.h>

@interface PatientSearchViewController : UITableViewController <UISearchBarDelegate, UIViewControllerRestoration>
@property (nonatomic, strong) NSArray *currentSearchResults;
@end
