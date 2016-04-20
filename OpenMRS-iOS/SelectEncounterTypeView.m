//
//  SelectEncounterTypeView.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/5/14.
//

#import "SelectEncounterTypeView.h"
#import "OpenMRSAPIManager.h"
#import "MRSEncounterType.h"
@implementation SelectEncounterTypeView
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Select Type", @"Label -select- -type-");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    [self refreshEncounterTypes];
}
- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setEncounterTypes:(NSArray *)encounterTypes
{
    _encounterTypes = encounterTypes;
    [self.tableView reloadData];
}
- (void)refreshEncounterTypes
{
    [OpenMRSAPIManager getEncounterTypesWithCompletion:^(NSError *error, NSArray *types) {
        if (!error) {
            self.encounterTypes = types;
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
            });
        }
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.encounterTypes.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    MRSEncounterType *type = self.encounterTypes[indexPath.row];
    cell.textLabel.text = type.display;
    return cell;
}
@end
