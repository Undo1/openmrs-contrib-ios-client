//
//  CaptureVitalsTableViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/12/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "CaptureVitalsTableViewController.h"
#import "OpenMRSAPIManager.h"
#import "LocationListTableViewController.h"
#import "MRSVital.h"
#import "MRSHelperFunctions.h"

@interface CaptureVitalsTableViewController ()

@end

@implementation CaptureVitalsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateFontSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];

    self.title = NSLocalizedString(@"Capture Vitals", @"Label -capture- -vitals-");
    self.fields = @[@ { @"label":@"Height", @"units":@"cm", @"uuid":@"5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"},
                    @ { @"label" : @"Weight", @"units" : @"kg", @"uuid" : @"5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"},
//                    @{ @"label" : @"Calculated BMI", @"units" : @""},
                    @ { @"label" : @"Temperature", @"units" : @"C", @"uuid" : @"5088AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"},
                    @ { @"label" : @"Pulse", @"units" : @"", @"uuid" : @"5087AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"},
                    @ { @"label" : @"Respiratory rate", @"units" : @"/min", @"uuid" : @"5242AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"},
//                    @{ @"label" : @"Blood Pressure", @"units" : @""},
                    @ { @"label" : @"Blood Oxygen Sat.", @"units" : @"%", @"uuid" : @"5092AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"}];
    if ([MRSHelperFunctions isNull:self.textFieldValues]) {
        self.textFieldValues = [[NSMutableDictionary alloc] init];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    if ([MRSHelperFunctions isNull:self.currentLocation]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)updateFontSize {
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)done
{
    NSMutableArray *vitals = [[NSMutableArray alloc] init];
    for (NSString *key in self.textFieldValues.allKeys) {
        MRSVital *vital = [[MRSVital alloc] init];
        vital.conceptUUID = key;
        vital.value = self.textFieldValues[key];
        [vitals addObject:vital];
    }
    [OpenMRSAPIManager captureVitals:vitals toPatient:self.patient atLocation:self.currentLocation completion:^(NSError *error) {
        if (!error) {
            [self.delegate didCaptureVitalsForPatient:self.patient];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return self.fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"locCell"];
        cell.textLabel.text = @"Location";
        if (self.currentLocation) {
            cell.detailTextLabel.text = self.currentLocation.display;
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Select", @"Label select")];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSDictionary *field = self.fields[indexPath.row];
    if ([field[@"units"] length] > 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", field[@"label"], field[@"units"]];
    } else {
        cell.textLabel.text = field[@"label"];
    }
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(cell.bounds.size.width-150, 0, 130, cell.bounds.size.height)];
    textField.backgroundColor = [UIColor clearColor];
    textField.textColor = self.view.tintColor;
    textField.textAlignment = NSTextAlignmentRight;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.returnKeyType = UIReturnKeyDone;
    textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    if (indexPath.row != 3) { //The pulse field.
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    } else {
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    [textField addTarget:self action:@selector(textFieldDidUpdate:) forControlEvents:UIControlEventEditingChanged];
    textField.placeholder = NSLocalizedString(@"Value", @"Label value");
    textField.text = self.textFieldValues[field[@"uuid"]];
    textField.tag = indexPath.row;
    [cell addSubview:textField];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        LocationListTableViewController *locList = [[LocationListTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        locList.delegate = self;
        [self.navigationController pushViewController:locList animated:YES];
    } else {
        //Pick the textfield in tableviewcell and make it first responder.
        [(UITextField *)([self.tableView cellForRowAtIndexPath:indexPath].subviews[1]) becomeFirstResponder];
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
    case 0:
        return NSLocalizedString(@"Location", @"Label location");
        break;
    case 1:
        return NSLocalizedString(@"Vitals", @"Label vitals");
        break;
    default:
        return nil;
        break;
    }
}
- (void)textFieldDidUpdate:(UITextField *)sender
{
    NSDictionary *field = self.fields[sender.tag];
    [self.textFieldValues setObject:sender.text forKey:field[@"uuid"]];
}
- (void)didChooseLocation:(MRSLocation *)location
{
    self.currentLocation = location;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.navigationController popToViewController:self animated:YES];
    [self.tableView reloadData];
}

#pragma mark - UIViewControllerRestoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    NSLog(@"Values at save: %@", self.textFieldValues);
    [coder encodeObject:self.patient forKey:@"patient"];
    [coder encodeObject:self.fields forKey:@"fields"];
    [coder encodeObject:self.textFieldValues forKey:@"values"];
    [coder encodeObject:self.currentLocation forKey:@"location"];
    [coder encodeObject:self.delegate forKey:@"delegate"];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    CaptureVitalsTableViewController *captureVC = [[CaptureVitalsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    captureVC.delegate = [coder decodeObjectForKey:@"delegate"];
    captureVC.patient = [coder decodeObjectForKey:@"patient"];
    captureVC.fields = [coder decodeObjectForKey:@"fields"];
    captureVC.textFieldValues = [coder decodeObjectForKey:@"values"];
    captureVC.currentLocation = [coder decodeObjectForKey:@"location"];
    NSLog(@"Values at restore: %@", captureVC.textFieldValues);
    return captureVC;
}

@end
