//
//  MainMenuCollectionViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/8/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import "MainMenuCollectionViewController.h"
#import "PatientSearchViewController.h"
#import "SettingsViewController.h"
#import "AddPatientTableViewController.h"
#import "ActiveVisitsList.h"
#import "AddPatientForm.h"

@implementation MainMenuCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    self.title = NSLocalizedString(@"OpenMRS", @"Orgnaization name");
    self.view.backgroundColor = [UIColor whiteColor];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"Label settings") style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings)];
    }

    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}
- (void)showSettings
{
    SettingsViewController *settings = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:settings];
    navcon.restorationIdentifier = NSStringFromClass([navcon class]);
    [self presentViewController:navcon animated:YES completion:nil];
}
- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // additional setup here if required.
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 4;
    }
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UIImage *image;
    switch (indexPath.row) {
    case 0:
        image = [UIImage imageNamed:@"search_icon"];
        break;
    case 1:
        image = [UIImage imageNamed:@"add_patient_icon"];
        break;
    case 2:
        image = [UIImage imageNamed:@"active_visits_icon"];
        break;
    case 3:
        image = [UIImage imageNamed:@"settings-icon"];
    default:
        break;
    }
    UIImageView *iView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    iView.frame = CGRectMake(25, 0, cell.frame.size.width-50, cell.frame.size.height-44);
    iView.contentMode = UIViewContentModeScaleAspectFit;
    iView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [cell addSubview:iView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 44, cell.frame.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    switch (indexPath.row) {
    case 0:
        label.text = NSLocalizedString(@"Patient Search", @"Label -patient- -search-");
        break;
    case 1:
        label.text = NSLocalizedString(@"Add Patient", @"Label -add- -patient-");
        break;
    case 2:
        label.text = NSLocalizedString(@"Active visits", @"Label -active- -visits");
        break;
    case 3:
        label.text = NSLocalizedString(@"Settings", @"Label settings");
    default:
        break;
    }
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [cell addSubview:label];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width/2, 100);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
    (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20,0,0,0);
}


#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        PatientSearchViewController *search = [[PatientSearchViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:search animated:YES];
    } else if (indexPath.item == 1) {
        AddPatientTableViewController *addPatient = [[AddPatientTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        AddPatientForm *addPatientForm = [[AddPatientForm alloc] init];
        UINavigationController *addPatientNavController = [[UINavigationController alloc] initWithRootViewController:addPatientForm];
        addPatientNavController.restorationIdentifier = NSStringFromClass([addPatientNavController class]);
        [self presentViewController:addPatientNavController animated:YES completion:nil];
    } else if (indexPath.item == 2) {
        ActiveVisitsList *activeVisits = [[ActiveVisitsList alloc] initWithStyle:UITableViewStyleGrouped];
        UINavigationController *activeVisitsNavController = [[UINavigationController alloc] initWithRootViewController:activeVisits];
        activeVisitsNavController.restorationIdentifier = NSStringFromClass([activeVisitsNavController class]);
        [self presentViewController:activeVisitsNavController animated:YES completion:nil];
    } else {
        SettingsViewController *settings = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:settings];
        navcon.restorationIdentifier = NSStringFromClass([navcon class]);
        navcon.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navcon animated:YES completion:nil];
    }
}

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    return [[self alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
}

@end
