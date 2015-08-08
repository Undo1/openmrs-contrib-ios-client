//
//  SettingsViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/2/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "SettingsViewController.h"
#import "OpenMRSAPIManager.h"
#import "KeychainItemWrapper.h"
#import "MRSHelperFunctions.h"
#import "AppDelegate.h"
#import "SyncingEngine.h"
#import "Constants.h"

@implementation SettingsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateFontSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
    self.title = NSLocalizedString(@"Settings", @"Label settings");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}

- (void)updateFontSize {
    [MRSHelperFunctions updateTableViewForDynamicTypeSize:self.tableView];
}
- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 1;
    } else {
        return 2;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logoutCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"logoutCell"];
            }
            cell.textLabel.text = NSLocalizedString(@"Logout", @"Label logout");
            cell.textLabel.textColor = self.view.tintColor;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
        } else if (indexPath.row == 0) {
            UITableViewCell *usernameCell = [tableView dequeueReusableCellWithIdentifier:@"usernameCell"];
            if (!usernameCell) {
                usernameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"usernameCell"];
            }
            KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
            NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
            usernameCell.textLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Logged in as", @"Label -logged- -in- -as"), username];
            usernameCell.textLabel.textColor = [UIColor grayColor];
            return usernameCell;
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clearCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clearCell"];
            }
            cell.textLabel.textColor = [UIColor redColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"Remove Offline Patients", @"Label -remove- -offline- -patients-");
            return cell;
        } else if (indexPath.row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clearCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clearCell"];
            }
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"Sync offline patients", @"Label -sync- -offline- -patients-");
            return cell;

        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            }
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.text = @"XForms Wizard";
            UISwitch *switchWizard = [[UISwitch alloc] initWithFrame:CGRectZero];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:UDisWizard]) {
                switchWizard.on = YES;
            } else {
                switchWizard.on = NO;
            }
            cell.accessoryView = switchWizard;
            [switchWizard addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
    }
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate clearStore];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self dismissViewControllerAnimated:NO completion:^ {
            [OpenMRSAPIManager logout];
        }];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [[SyncingEngine sharedEngine] updateExistingOutOfDatePatients:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UISwitch *wizardSwitch = cell.accessoryView;
        wizardSwitch.on = !wizardSwitch.isOn;
        BOOL isWizard = [[NSUserDefaults standardUserDefaults] boolForKey:UDisWizard];
        [[NSUserDefaults standardUserDefaults] setBool:!isWizard forKey:UDisWizard];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)updateSwitch:(UISwitch *)wizardSwitch {
    if (wizardSwitch.isOn) {
        NSLog(@"YES");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UDisWizard];
    } else {
        NSLog(@"NO");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UDisWizard];
    }
}

#pragma mark - UIViewControllerRestoration

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}
@end
