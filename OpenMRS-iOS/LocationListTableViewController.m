//
//  LocationListTableViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/12/14.
//

#import "LocationListTableViewController.h"
#import "MRSLocation.h"
#import "MRSHelperFunctions.h"
#import "OpenMRSAPIManager.h"
#import "MBProgressExtension.h"
#import "MRSAlertHandler.h"
#import "XLForm.h"

@interface LocationListTableViewController ()

@end

@implementation LocationListTableViewController

@synthesize rowDescriptor = _rowDescriptor;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateFontSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
    
    self.title = NSLocalizedString(@"Choose Location", @"Label -choose- -location-");
    [self refreshData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)updateFontSize {
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)refreshData
{
    [MBProgressExtension showBlockWithTitle:NSLocalizedString(@"Loading", @"Label loading") inView:self.view];
    [OpenMRSAPIManager getLocationsWithCompletion:^(NSError *error, NSArray *locations) {
        [MBProgressExtension hideActivityIndicatorInView:self.view];
        if (!error) {
            [MBProgressExtension showSucessWithTitle:NSLocalizedString(@"Completed", @"Label completed") inView:self.view];
            self.locations = locations;
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
            });
        } else {
            [[MRSAlertHandler alertViewForError:self error:error] show];
        }
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    MRSLocation *location = self.locations[indexPath.row];
    cell.textLabel.text = location.display;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRSLocation *location = self.locations[indexPath.row];
    XLFormOptionsObject *opValue = [XLFormOptionsObject formOptionsObjectWithValue:location.UUID displayText:location.display];
    _rowDescriptor.value = opValue;
    if (self.delegate == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.delegate didChooseLocation:location];
}

#pragma mark - UIViewRestoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.delegate forKey:@"delegate"];
    [super encodeRestorableStateWithCoder:coder];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    LocationListTableViewController *locationList = [[LocationListTableViewController alloc] initWithStyle:UITableViewStylePlain];
    locationList.delegate = [coder decodeObjectForKey:@"delegate"];
    return locationList;
}
@end
