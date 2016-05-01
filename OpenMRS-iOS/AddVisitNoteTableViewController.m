//
//  AddVisitNoteTableViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/12/14.
//

#import "AddVisitNoteTableViewController.h"
#import "LocationListTableViewController.h"
#import "MRSPatient.h"
#import "MRSLocation.h"
#import "OpenMRSAPIManager.h"
#import "MBProgressExtension.h"
#import "MRSAlertHandler.h"
@interface AddVisitNoteTableViewController ()

@end

@implementation AddVisitNoteTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    self.title = NSLocalizedString(@"Add Visit Note", @"Lable -add- -visit- -note-");
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
    [MBProgressExtension showBlockWithTitle:NSLocalizedString(@"Loading", @"Lable loading") inView:self.view];
    [OpenMRSAPIManager addVisitNote:self.currentVisitNote toPatient:self.patient atLocation:self.currentLocation completion:^(NSError *error) {
        [MBProgressExtension hideActivityIndicatorInView:self.view];
        if (!error) {
            [MBProgressExtension showSucessWithTitle:NSLocalizedString(@"Completed", @"Label completed") inView:self.presentingViewController.view];
            [self.delegate didAddVisitNoteToPatient:self.patient];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [[MRSAlertHandler alertViewForError:self error:error] show];
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
    static NSDictionary *cellHeightDictionary;

    if (!cellHeightDictionary) {
        cellHeightDictionary = @{ UIContentSizeCategoryExtraSmall : @44,
                                  UIContentSizeCategorySmall : @44,
                                  UIContentSizeCategoryMedium : @44,
                                  UIContentSizeCategoryLarge : @44,
                                  UIContentSizeCategoryExtraLarge : @55,
                                  UIContentSizeCategoryExtraExtraLarge : @65,
                                  UIContentSizeCategoryExtraExtraExtraLarge : @75 };
    }

    NSString *userSize =
    [[UIApplication sharedApplication] preferredContentSizeCategory];

    NSNumber *cellHeight = cellHeightDictionary[userSize];
    if (indexPath.section == 1) {
        return cellHeight.floatValue;
    }
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"locCell"];
        cell.textLabel.text = NSLocalizedString(@"Location", @"Label location");
        if (self.currentLocation) {
            cell.detailTextLabel.text = self.currentLocation.display;
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Choose", @"Label choose")];
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
    textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
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
        return NSLocalizedString(@"Location", @"Label location");
    }
    return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Note on", @"Label -note- -on"), self.patient.name];
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

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.patient forKey:@"patient"];
    [coder encodeObject:self.currentLocation forKey:@"location"];
    [coder encodeObject:self.currentVisitNote forKey:@"noteText"];
    [coder encodeObject:self.delegate forKey:@"delegate"];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    NSLog(@"hirearchy: %@", identifierComponents);
    AddVisitNoteTableViewController *addnoteVC = [[AddVisitNoteTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    addnoteVC.delegate = [coder decodeObjectForKey:@"delegate"];
    addnoteVC.currentVisitNote = [coder decodeObjectForKey:@"noteText"];
    addnoteVC.currentLocation = [coder decodeObjectForKey:@"location"];
    addnoteVC.patient = [coder decodeObjectForKey:@"patient"];
    return addnoteVC;
}
@end
