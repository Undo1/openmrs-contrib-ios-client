//
//  AddVisitNoteTableViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/12/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "AddVisitNoteTableViewController.h"
#import "LocationListTableViewController.h"
#import "MRSPatient.h"
#import "MRSLocation.h"
#import "OpenMRSAPIManager.h"
@interface AddVisitNoteTableViewController ()

@end

@implementation AddVisitNoteTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add Visit Note";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
- (void)setPatient:(MRSPatient *)patient
{
    _patient = patient;
    [self.tableView reloadData];
}
- (void)done
{
    [OpenMRSAPIManager addVisitNote:self.currentVisitNote toPatient:self.patient atLocation:self.currentLocation completion:^(NSError *error) {
        if (!error) {
            [self.delegate didAddVisitNoteToPatient:self.patient];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 44;
    }
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"locCell"];
        cell.textLabel.text = @"Location";
        if (self.currentLocation) {
            cell.detailTextLabel.text = self.currentLocation.display;
        } else {
            cell.detailTextLabel.text = @"Choose...";
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, cell.bounds.size.width-20, cell.bounds.size.height-20)];
    textView.delegate = self;
    textView.font = [UIFont fontWithName:textView.font.fontName size:cell.textLabel.font.pointSize];
    textView.text = self.currentVisitNote;
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [cell addSubview:textView];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        LocationListTableViewController *locs = [[LocationListTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        locs.delegate = self;
        [self.navigationController pushViewController:locs animated:YES];
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"Location";
    }
    return [NSString stringWithFormat:@"Note on %@", self.patient.name];
}
- (void)textViewDidChange:(UITextView *)textView
{
    self.currentVisitNote = textView.text;
}
- (void)didChooseLocation:(MRSLocation *)location
{
    self.currentLocation = location;
    if (self.currentLocation) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [self.navigationController popToViewController:self animated:YES];
    [self.tableView reloadData];
}
@end
