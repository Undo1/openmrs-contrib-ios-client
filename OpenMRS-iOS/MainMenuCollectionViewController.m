//
//  MainMenuCollectionViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/8/14.
//

#import "MainMenuCollectionViewController.h"
#import "PatientSearchViewController.h"
#import "AddPatientTableViewController.h"
#import "ActiveVisitsList.h"
#import "AddPatientForm.h"
#import "PatientViewController.h"
#import "PatientVisitListView.h"
#import "PatientEncounterListView.h"
#import "XFormsList.h"
#import "XFormViewController.h"
#import "XFormsStore.h"
#import "SettingsForm.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "OpenMRSAPIManager.h"

@implementation MainMenuCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    self.title = @"OpenMRS";
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem   alloc] initWithTitle:NSLocalizedString(@"Logout", @"Label logout") style:UIBarButtonItemStylePlain target:self action:@selector(logout)];

    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionView reloadData];
}
- (void)showSettings
{
    SettingsForm *settings = [[SettingsForm alloc] init];
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
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];

    // Remove all subviews from cell - otherwise we get nastiness if we reload the collection view
    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }

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
        image = [UIImage imageNamed:@"form-thumbnail"];
        break;
    case 4:
        image = [UIImage imageNamed:@"settings_icon"];
    default:
        break;
    }
    UIImageView *iView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    iView.frame = CGRectMake(25, 0, cell.frame.size.width-50, cell.frame.size.height-44);
    iView.tintColor = self.navigationController.navigationBar.barTintColor;
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
        label.text = NSLocalizedString(@"Filled XForms", @"Label filled xforms");
        break;
    case 4:
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(self.view.frame.size.width/4, 100);
    }
    else
    {
        return CGSizeMake(self.view.frame.size.width/2, 100);
    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 25;
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            PatientSearchViewController *search = [[PatientSearchViewController alloc] initWithStyle:UITableViewStylePlain];
            
            /* Image VC */
            UIViewController *vc = [[UIViewController alloc] init];
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            vc.view = view;

            UILabel *noItemsLabel = [[UILabel alloc] init];
            noItemsLabel.text = @"No patient selected";
            noItemsLabel.textColor = [UIColor darkGrayColor];

            noItemsLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [noItemsLabel sizeToFit];
            [view addSubview:noItemsLabel];


            // Center horizontally
            [view addConstraint:[NSLayoutConstraint constraintWithItem:noItemsLabel
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0.0]];

            // Center vertically
            [view addConstraint:[NSLayoutConstraint constraintWithItem:noItemsLabel
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]];

            UINavigationController *masterNav = [[UINavigationController alloc] initWithRootViewController:search];
            UINavigationController *vcNav = [[UINavigationController alloc] initWithRootViewController:vc];
            UISplitViewController *splitView = [[UISplitViewController alloc] init];
            splitView.viewControllers = @[masterNav, vcNav];
            splitView.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
            [self presentViewController:splitView animated:YES completion:nil];
            
        } else {
            PatientSearchViewController *search = [[PatientSearchViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:search animated:YES];
        }
    } else if (indexPath.item == 1) {
        AddPatientForm *addPatientForm = [[AddPatientForm alloc] init];
        addPatientForm.restorationIdentifier = NSStringFromClass([addPatientForm class]);
        addPatientForm.restorationClass = [addPatientForm class];
        UINavigationController *addPatientNavController = [[UINavigationController alloc] initWithRootViewController:addPatientForm];
        addPatientNavController.restorationIdentifier = NSStringFromClass([addPatientNavController class]);
        addPatientNavController.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:addPatientNavController animated:YES completion:nil];
    } else if (indexPath.item == 2) {
        ActiveVisitsList *activeVisits = [[ActiveVisitsList alloc] initWithStyle:UITableViewStyleGrouped];
        UINavigationController *activeVisitsNavController = [[UINavigationController alloc] initWithRootViewController:activeVisits];
        activeVisitsNavController.restorationIdentifier = NSStringFromClass([activeVisitsNavController class]);
        activeVisitsNavController.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:activeVisitsNavController animated:YES completion:nil];
    } else if (indexPath.item == 3) {
        
        XFormsList *formsList = [[XFormsList alloc] initFilledForms];
        UINavigationController *formListNavigationController = [[UINavigationController alloc] initWithRootViewController:formsList];
        formListNavigationController.restorationIdentifier = NSStringFromClass([formListNavigationController class]);
        formListNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:formListNavigationController animated:YES completion:nil];
    } else {
        SettingsForm *settings = [[SettingsForm alloc] init];
        UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:settings];
        navcon.restorationIdentifier = NSStringFromClass([navcon class]);
        navcon.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navcon animated:YES completion:nil];
    }
}

- (void)logout {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"Label warning") message:NSLocalizedString(@"When logged out your current offline saved forms and patients will be removed",     ) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button label") otherButtonTitles:@"OK", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [OpenMRSAPIManager logout];
    }
}

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    NSLog(@"@mainmenu :%@", identifierComponents);
    return [[self alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
}

@end
