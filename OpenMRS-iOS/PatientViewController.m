//
//  PatientViewController.m
//  
//
//  Created by Parker Erway on 12/1/14.
//
//

#import "PatientViewController.h"
#import "OpenMRSAPIManager.h"
#import "PatientEncounterListView.h"
#import "PatientVisitListView.h"
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
                                 @{@"Address" : [self formatPatientAdress:self.patient]}];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                self.title = self.patient.name;
            });
        }
    }];
    [OpenMRSAPIManager getEncountersForPatient:self.patient completion:^(NSError *error, NSArray *encounters) {
        if (error == nil)
        {
            self.encounters = encounters;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    [OpenMRSAPIManager getVisitsForPatient:self.patient completion:^(NSError *error, NSArray *visits) {
       if (error == nil)
       {
           self.visits = visits;
           dispatch_async(dispatch_get_main_queue(), ^{
               [self.tableView reloadData];
           });
       }
    }];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *detail = cell.detailTextLabel.text;
    
    CGRect bounding = [detail boundingRectWithSize:CGSizeMake(self.view.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : cell.detailTextLabel.font} context:nil];
    return MAX(44,bounding.size.height+10);
}
-(id)notNil:(id)thing
{
    if (thing == nil || thing == [NSNull null])
    {
        return @"";
    }
    return thing;
}
-(NSString *)formatPatientAdress:(MRSPatient *)patient
{
    NSString *string = [self notNil:patient.address1];
    if (![[self notNil:patient.address2] isEqual:@""])
    {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.address2]];
    }
    if (![[self notNil:patient.address3] isEqual:@""])
    {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.address3]];
    }
    if (![[self notNil:patient.address4] isEqual:@""])
    {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.address4]];
    }
    if (![[self notNil:patient.address5] isEqual:@""])
    {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.address5]];
    }
    if (![[self notNil:patient.address6] isEqual:@""])
    {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.address6]];
    }
    if (![[self notNil:patient.cityVillage] isEqual:@""])
    {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.cityVillage]];
    }
    if (![[self notNil:patient.stateProvince] isEqual:@""])
    {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.stateProvince]];
    }
    if (![[self notNil:patient.country] isEqual:@""])
    {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.country]];
    }
    if (![[self notNil:patient.postalCode] isEqual:@""])
    {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\n%@", patient.postalCode]];
    }
    return string;
}
-(NSString *)formatDate:(NSString *)date
{
    if (date == nil)
    {
        return @"";
    }
    
    NSDateFormatter *stringToDateFormatter = [[NSDateFormatter alloc] init];
    [stringToDateFormatter setDateFormat:@"Y-MM-dd'T'HH:mm:ss.SSS-Z"];
    NSDate *newDate = [stringToDateFormatter dateFromString:date];
    
//    struct tm  sometime;
//    const char *formatString = "%Y-%m-%d'T'%H:%M:%S%Z";
//    (void) strptime_l(date, formatString, &sometime, NULL);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *string = [formatter stringFromDate:newDate];
    
    if (string == nil)
    {
        return @"";
    }
    else
    {
        return string;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.information.count;
    }
    else // section == 1
    {
        return 2;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"countCell"];
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"countCell"];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Visits";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.visits.count];
            
            return cell;
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"Encounters";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.encounters.count];
            
            return cell;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    NSString *key = ((NSDictionary *)self.information[indexPath.row]).allKeys[0];
    NSString *value = [self.information[indexPath.row] valueForKey:key];
    
    cell.textLabel.text = key;
    cell.detailTextLabel.text = value;
    cell.detailTextLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (indexPath.row == 1) //encounters row selected
        {
            PatientEncounterListView *encounterList = [[PatientEncounterListView alloc] initWithStyle:UITableViewStyleGrouped];
            encounterList.encounters = self.encounters;
            [self.navigationController pushViewController:encounterList animated:YES];
        }
        else if (indexPath.row == 0) //visits row selected
        {
            PatientVisitListView *visitsList = [[PatientVisitListView alloc] initWithStyle:UITableViewStyleGrouped];
            visitsList.visits = self.visits;
            [self.navigationController pushViewController:visitsList animated:YES];
        }
    }
}
@end
