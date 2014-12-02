//
//  PatientViewController.m
//  
//
//  Created by Parker Erway on 12/1/14.
//
//

#import "PatientViewController.h"
#import "OpenMRSAPIManager.h"
@implementation PatientViewController
-(void)setPatient:(MRSPatient *)patient
{
    _patient = patient;
    
    self.information = @[@{@"Name" : patient.name}];
    
    [self.tableView reloadData];
    if (!patient.hasDetailedInfo)
    {
        [self updateWithDetailedInfo];
    }
}
-(void)updateWithDetailedInfo
{
    [OpenMRSAPIManager getDetailedDataOnPatient:self.patient completion:^(NSError *error, MRSPatient *detailedPatient) {
        if (error == nil)
        {
            self.patient = detailedPatient;
            self.information = @[@{@"Name" : [self notNil:self.patient.name]},
                                 @{@"Age" : [self notNil:self.patient.age]},
                                 @{@"Gender" : [self notNil:self.patient.gender]},
                                 @{@"Address Line 1" : [self notNil:self.patient.address1]},
                                 @{@"Address Line 2" : [self notNil:self.patient.address2]},
                                 @{@"Address Line 3" : [self notNil:self.patient.address3]},
                                 @{@"Address Line 4" : [self notNil:self.patient.address4]},
                                 @{@"Address Line 5" : [self notNil:self.patient.address5]},
                                 @{@"Address Line 6" : [self notNil:self.patient.address6]}];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                self.title = self.patient.name;
            });
        }
    }];
}
-(id)notNil:(id)thing
{
    if (thing == nil)
    {
        return @"";
    }
    return thing;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.information.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    NSString *key = ((NSDictionary *)self.information[indexPath.row]).allKeys[0];
    NSString *value = [self.information[indexPath.row] valueForKey:key];
    
    cell.textLabel.text = key;
    cell.detailTextLabel.text = value;
    
    return cell;
}
@end
