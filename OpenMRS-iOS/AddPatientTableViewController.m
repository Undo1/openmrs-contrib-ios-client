//
//  AddPatientTableViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/9/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "AddPatientTableViewController.h"
#import "OpenMRSAPIManager.h"
#import "AppDelegate.h"
#import "MRSPatientIdentifierType.h"
#import "PatientViewController.h"
#import "SelectPatientIdentifierTypeTableViewController.h"
@interface AddPatientTableViewController ()

@end

@implementation AddPatientTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add Patient";
    self.selectedGender = @"";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
}
- (void)done
{
    MRSPatient *patient = [[MRSPatient alloc] init];
    patient.name = self.selectedGivenName;
    patient.familyName = self.selectedFamilyName;
    patient.age = [NSNumber numberWithInt:[self.selectedAge intValue]];
    patient.gender = self.selectedGender;
    MRSPatientIdentifier *identifier = [[MRSPatientIdentifier alloc] init];
    identifier.identifier = self.selectedIdentifier;
    identifier.identifierType = self.selectedIdentifierType;
    [OpenMRSAPIManager addPatient:patient withIdentifier:identifier completion:^(NSError *error, MRSPatient *createdPatient) {
        if (!error) {
            PatientViewController *patientVc = [[PatientViewController alloc] initWithStyle:UITableViewStyleGrouped];
            patientVc.patient = createdPatient;
            [self dismissViewControllerAnimated:YES completion:^ {
                AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                [(UINavigationController *)delegate.window.rootViewController pushViewController:patientVc animated:YES];
            }];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't save patient. Make sure all required fields are filled out" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}
- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
    case 0:
        return 2;
        break;
    case 1:
        return 2;
        break;
    case 2:
        return 1;
    case 3:
        return 2;
        break;
    default:
        return 0;
        break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"namecell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Given Name";
            break;
        case 1:
            cell.textLabel.text = @"Family Name";
            break;
        }
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(cell.bounds.size.width-150, 0, 130, cell.bounds.size.height)];
        field.backgroundColor = [UIColor clearColor];
        field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        field.textColor = self.view.tintColor;
        field.textAlignment = NSTextAlignmentRight;
        field.returnKeyType = UIReturnKeyDone;
        [field addTarget:self action:@selector(textFieldDidUpdate:) forControlEvents:UIControlEventEditingChanged];
        switch (indexPath.row) {
        case 0:
            field.placeholder = @"Given Name";
            field.text = self.selectedGivenName;
            field.tag = 1;
            break;
        case 1:
            field.placeholder = @"Family Name";
            field.text = self.selectedFamilyName;
            field.tag = 2;
            break;
        }
        [cell addSubview:field];
        return cell;
    }
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gendercell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gendercell"];
        }
        cell.textLabel.text = (indexPath.row == 1) ? @"Female" : @"Male";
        if (([self.selectedGender isEqualToString:@"M"] && indexPath.row == 0) || ([self.selectedGender isEqualToString:@"F"] && indexPath.row == 1)) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ageCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Age";
            UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(cell.bounds.size.width-150, 0, 130, cell.bounds.size.height)];
            field.backgroundColor = [UIColor clearColor];
            field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            field.textColor = self.view.tintColor;
            field.textAlignment = NSTextAlignmentRight;
            field.returnKeyType = UIReturnKeyDone;
            field.keyboardType = UIKeyboardTypeNumberPad;
            [field addTarget:self action:@selector(textFieldDidUpdate:) forControlEvents:UIControlEventEditingChanged];
            field.placeholder = @"Age";
            field.text = self.selectedAge;
            field.tag = 4;
            [cell addSubview:field];
            return cell;
        }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idTypeCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"idTypeCell"];
            }
            cell.textLabel.text = @"ID Type";
            if (self.selectedIdentifierType) {
                cell.detailTextLabel.text = self.selectedIdentifierType.display;
            } else {
                cell.detailTextLabel.text = @"Select";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        if (indexPath.row == 1) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"identifierCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Identifier ";
            UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(cell.bounds.size.width-150, 0, 130, cell.bounds.size.height)];
            field.backgroundColor = [UIColor clearColor];
            field.textColor = self.view.tintColor;
            field.textAlignment = NSTextAlignmentRight;
            field.returnKeyType = UIReturnKeyDone;
            field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [field addTarget:self action:@selector(textFieldDidUpdate:) forControlEvents:UIControlEventEditingChanged];
            field.placeholder = @"Identifier";
            field.text = self.selectedIdentifier;
            field.tag = 3;
            [cell addSubview:field];
            return cell;
        }
    }
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
    case 0:
        return @"Name";
        break;
    case 1:
        return @"Gender";
        break;
    case 2:
        return @"Age";
        break;
    case 3:
        return @"Identifier";
        break;
    default:
        return nil;
        break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            self.selectedGender = @"M";
        } else {
            self.selectedGender = @"F";
        }
        [self.tableView reloadData];
    }
    if (indexPath.section == 3 && indexPath.row == 0) {
        SelectPatientIdentifierTypeTableViewController *selectIdType = [[SelectPatientIdentifierTypeTableViewController alloc] initWithStyle:UITableViewStylePlain];
        selectIdType.delegate = self;
        [self.navigationController pushViewController:selectIdType animated:YES];
    } else {
        //Pick the textfield in tableviewcell and make it first responder.
        [(UITextField *)([self.tableView cellForRowAtIndexPath:indexPath].subviews[1]) becomeFirstResponder];
    }
}
- (void)textFieldDidUpdate:(UITextField *)sender
{
    switch (sender.tag) {
    case 1:
        self.selectedGivenName = sender.text;
        break;
    case 2:
        self.selectedFamilyName = sender.text;
        break;
    case 3:
        self.selectedIdentifier = sender.text;
        break;
    case 4:
        self.selectedAge = sender.text;
        break;
    }
}
- (void)didSelectPatientIdentifierType:(MRSPatientIdentifierType *)type
{
    self.selectedIdentifierType = type;
    [self.navigationController popToViewController:self animated:YES];
    [self.tableView reloadData];
}
@end
