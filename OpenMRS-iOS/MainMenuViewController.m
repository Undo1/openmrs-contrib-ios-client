//
//  MainMenuViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//  
//

#import "MainMenuViewController.h"
#import "PatientSearchViewController.h"
#import "SettingsViewController.h"
#import "AddPatientTableViewController.h"
@implementation MainMenuViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings)];
    
    self.title = @"OpenMRS";
}
-(void)showSettings
{
    SettingsViewController *settings = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:settings];
    
    [self presentViewController:navcon animated:YES completion:nil];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Patient Search";
            break;
        case 1:
            cell.textLabel.text = @"Register a Patient";
            break;
        default:
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        PatientSearchViewController *search = [[PatientSearchViewController alloc] initWithStyle:UITableViewStylePlain];
        
        [self.navigationController pushViewController:search animated:YES];
    }
    else if (indexPath.row == 1)
    {
        AddPatientTableViewController *add = [[AddPatientTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:add] animated:YES completion:nil];
    }
}
@end
