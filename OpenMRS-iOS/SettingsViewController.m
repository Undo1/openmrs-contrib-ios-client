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
#import "AppDelegate.h"
@implementation SettingsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView)];
}
- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
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
            cell.textLabel.text = @"Logout";
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
            usernameCell.textLabel.text = [NSString stringWithFormat:@"Logged in as: %@", username];
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
            cell.textLabel.text = @"Remove Offline Patients";
            return cell;
        } else if (indexPath.row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clearCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clearCell"];
            }
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = @"Sync offline patients";
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
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self dismissViewControllerAnimated:NO completion:^ {
            [OpenMRSAPIManager logout];
        }];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate updateExistingOutOfDatePatients];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}
@end
