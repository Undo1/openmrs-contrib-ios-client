//
//  PatientEncounterListView.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/2/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "PatientEncounterListView.h"
#import "MRSEncounter.h"

@implementation PatientEncounterListView
-(void)setEncounters:(NSArray *)encounters
{
    _encounters = encounters;
    [self.tableView reloadData];
}
-(void)viewDidLoad
{
    self.title = @"Encounters";
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.encounters.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    MRSEncounter *encounter = self.encounters[indexPath.row];
    
    cell.textLabel.text = encounter.displayName;
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}
@end
