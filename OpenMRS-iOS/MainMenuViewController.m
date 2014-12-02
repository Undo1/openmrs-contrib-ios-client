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
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = @"Patient Search";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PatientSearchViewController *search = [[PatientSearchViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [self.navigationController pushViewController:search animated:YES];
}
@end
