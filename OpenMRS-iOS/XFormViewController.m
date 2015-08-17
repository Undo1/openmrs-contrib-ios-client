
//
//  XFormViewController.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/20/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XFormViewController.h"
#import "XFormElement.h"
#import "Constants.h"
#import "XFormsParser.h"
#import "OpenMRSAPIManager.h"
#import "SVProgressHUD.h"
#import "XFormsStore.h"
#import "XFormImageCell.h"
#import "MRSDateUtilities.h"
#import "MBProgressExtension.h"
#import "MRSAlertHandler.h"

@interface XFormViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) XForms *XForm;
@property (nonatomic) int index;
@property (nonatomic, strong) XFormElement *repeatElement;
@property (nonatomic, strong) XLFormViewController *reviewForm;

@property (nonatomic, strong) UIView *tutorialView;
@property (nonatomic, strong) NSString *allNonValidFields;
@end

@implementation XFormViewController

- (instancetype)initWithForm:(XForms *)form WithIndex:(int)index {
    self = [super init];
    if (self) {
        self.XForm = form;
        self.index = index;
        [self initView];
    }
    return self;
}

- (void)initView {
    XLFormDescriptor *formDescriptor = self.XForm.forms[self.index];
    self.form = formDescriptor;
    if ([self isRepeat]) {
        [self addButtons];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *leftLabel = self.index > 0 ? NSLocalizedString(@"Pervious", @"Label pervious") : NSLocalizedString(@"Cancel", @"Cancel button label");
    NSString *rightLabel =  self.index < (self.XForm.forms.count - 1) ? NSLocalizedString(@"Next", @"Label next") : NSLocalizedString(@"Done", @"Label done");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:leftLabel style:UIBarButtonItemStylePlain target:self action:@selector(pervious:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightLabel style:UIBarButtonItemStylePlain target:self action:@selector(next:)];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%d/%lu)", self.XForm.name, self.index + 1, (unsigned long)self.XForm.forms.count];
    
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(next:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(pervious:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:UDnewSession] &&
        [[NSUserDefaults standardUserDefaults] boolForKey:UDisWizard]) {
        [self addTutorialView];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UDnewSession];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)addTutorialView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.tutorialView = [[UIView alloc] initWithFrame:screenRect];
    self.tutorialView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tutorialView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    
    UILabel *swipeLabel = [[UILabel alloc] init];
    swipeLabel.text = NSLocalizedString(@"Swipe left or right to navigate", @"Message for user to swipe");
    swipeLabel.textColor = [UIColor whiteColor];
    swipeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [swipeLabel sizeToFit];
    swipeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tutorialView addSubview:swipeLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.tutorialView.bounds];
    imageView.image = [UIImage imageNamed:@"swipe-icon"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tutorialView addSubview:imageView];
    
    [self.tutorialView addConstraint:[NSLayoutConstraint constraintWithItem:swipeLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.tutorialView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    [self.tutorialView addConstraint:[NSLayoutConstraint constraintWithItem:swipeLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.tutorialView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    NSDictionary *viewsDictionary = @{
                                      @"label": swipeLabel,
                                      @"image": imageView
                                      };
    [self.tutorialView addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-100-[label]"
                          options:0
                          metrics:nil
                          views:viewsDictionary]];
    [self.tutorialView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:[image]-100-|"
                                       options:0
                                       metrics:nil
                                       views:viewsDictionary]];
    [self.tutorialView addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-0-[image]-0-|"
                          options:0
                          metrics:nil
                          views:viewsDictionary]];
    UITapGestureRecognizer *tab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeTutorial)];
    [self.tutorialView addGestureRecognizer:tab];
    [self.navigationController.view addSubview:self.tutorialView];
}

- (void)removeTutorial {
    [self.tutorialView removeFromSuperview];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // change cell height of a particular cell
    if ([[self.form formRowAtIndex:indexPath].tag isEqualToString:@"info"]){
        return 30.0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    if (section == 0) {
        myLabel.frame = CGRectMake(10, 25, 999, 20);
    } else {
        
        myLabel.frame = CGRectMake(10, 10, 999, 20);
    }
    myLabel.font = [UIFont boldSystemFontOfSize:14];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    return headerView;
}

- (void)pervious:(id)sender {
    if (self.index > 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)next:(id)sender {

    if (self.index < (self.XForm.forms.count - 1)) {
        if ([self isValid]) {
            XFormViewController *nextForm = [[XFormViewController alloc] initWithForm:self.XForm WithIndex:self.index+1];
            [self.navigationController pushViewController:nextForm animated:YES];
        } else {
            [self showValidationWarning];
        }
    } else {
        if ([self isValid]) {
            if ([sender isKindOfClass:[UIBarButtonItem class]]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:UDisWizard]) {
                    self.reviewForm = [[XLFormViewController alloc] initWithForm:[self.XForm getReviewForm]];
                    self.reviewForm.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissNew:)];
                    self.reviewForm.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Submit form", @"Button label submit form") style:UIBarButtonItemStylePlain target:self action:@selector(submitForm)];
                    self.reviewForm.navigationItem.title = self.XForm.name;
                    [self.navigationController pushViewController:self.reviewForm animated:YES];
                } else {
                    [self submitForm];
                }
            }
        } else {
            [self showValidationWarning];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        XLFormViewController *xlform = [[XLFormViewController alloc] initWithForm:[self.XForm getReviewForm]];
        xlform.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissNew:)];
        xlform.navigationItem.title = self.XForm.name;
        [self.navigationController pushViewController:xlform animated:YES];
    } else {
        [self submitForm];
    }
}

- (void)submitForm {
    if (!self.form.disabled) {
        // Then it's read from disk so don't reinject it.
        [XFormsParser InjecValues:self.XForm];
    }
    
    UIView *view;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:UDisWizard]) {
        view = self.reviewForm.view;
    } else {
        view = self.view;
    }
    [MBProgressExtension showBlockWithDetailTitle:NSLocalizedString(@"Please wait, Communicating with OpenMRS server", @"Label submitting xforms") inView:view];
    [OpenMRSAPIManager uploadXForms:self.XForm completion:^(NSError *error) {
        [MBProgressExtension hideActivityIndicatorInView:view];
        if (!error) {
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Form Submitted Successfully", @"Title submitted successfully") message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        } else {
            if (error.code ==  errNetWorkLost || error.code == errNetworkDown || error.code == errNetWorkLost || error.code == errCanNotConnect) {
                UIAlertView *errorUploading = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error uploading", @"Title error uploading")
                                                                         message:NSLocalizedString(@"Oops, Seems there's no internet connectivity available now, Do you want to save the form for offline usage or discard now.", @"Message for error submitting form")
                                                                        delegate:self
                                                               cancelButtonTitle:NSLocalizedString(@"Discard", @"Discard button label")
                                                               otherButtonTitles:NSLocalizedString(@"Save Offline", @"Label save offline"), nil];
                [errorUploading show];
            } else {
                [[MRSAlertHandler alertViewForError:self error:error] show];
                [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }

        }
    }];
}

- (void)dismissNew:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController pushViewController:[[XFormViewController alloc] initWithForm:self.XForm WithIndex:self.index] animated:NO];
}

- (BOOL)isValid {
    NSArray * array = [self formValidationErrors];
    self.allNonValidFields = @"";
    for(id obj in array) {
        XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
        NSString *tag = validationStatus.rowDescriptor.tag;
        XFormElement *element = [self.XForm.groups[self.index] objectForKey:tag];
        NSString *title = element.label;
    
        if ([self.allNonValidFields isEqualToString:@""]) {
            self.allNonValidFields = title;
        } else {
            self.allNonValidFields = [self.allNonValidFields stringByAppendingString:[NSString stringWithFormat:@", %@", title]];
        }
    }
    return [self formValidationErrors].count == 0;
}

- (void)showValidationWarning {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error")
                                message:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Plese fill", @"Error message"), self.allNonValidFields]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

- (BOOL)isRepeat {
    //Check if already repeat, so we don't repeat repeat.
    XLFormDescriptor *form = self.XForm.forms[self.index];
    for (XLFormSectionDescriptor *section in form.formSections) {
        XLFormRowDescriptor *row = section.formRows[0];
        if ([row.tag isEqual:@"add"] || [row.tag isEqual:@"delete"]) {
            return NO;
        }
    }
    
    NSDictionary *elements = self.XForm.groups[self.index];
    for (NSString *key in elements) {
        XFormElement *element = elements[key];
        if ([element.type isEqualToString:kXFormsRepeat]) {
            return YES;
        }
    }
    return NO;
}

- (void)addButtons {
    XLFormDescriptor *form = self.XForm.forms[self.index];
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:@"add" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"Add", @"Label add")];
    row.action.formSelector = @selector(addNewSection:);
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"delete" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"Remove", @"Label remove")];
    row.action.formSelector = @selector(removeSection:);
    [section addFormRow:row];
}

- (void)addNewSection:(XLFormRowDescriptor *)sender {
    XLFormDescriptor *form = self.XForm.forms[self.index];
    NSUInteger count = form.formSections.count;
    XLFormSectionDescriptor *section = form.formSections[0];
    XLFormSectionDescriptor *newSection = [XLFormSectionDescriptor formSectionWithTitle:section.title];
    if (section.footerTitle) {
        newSection.footerTitle = section.footerTitle;
    }
    NSDictionary *group = self.XForm.groups[self.index];
    
    
    XFormElement *element;
    NSString *type;
    for (NSString *key in group) {
        element = group[key];
    }
    
    for (XLFormRowDescriptor *row in section.formRows) {
        XFormElement *subElement;
        for (NSString *tag in element.subElements) {
            if ([tag isEqualToString:row.tag]) {
                subElement = element.subElements[tag];
                type = subElement.type;
            }
        }
        if ([row.tag isEqualToString:@"info"]) {
            XLFormRowDescriptor *infoRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"info" rowType:XLFormRowDescriptorTypeInfo title:row.title];
            [infoRow.cellConfig setObject:[UIColor colorWithRed:39/255.0
                                                          green:139/255.0
                                                           blue:146/255.0
                                                          alpha:1] forKey:@"backgroundColor"];
            [infoRow.cellConfig setObject:[UIColor whiteColor] forKey:@"textLabel.textColor"];
            [infoRow.cellConfig setObject:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] forKey:@"textLabel.font"];
            [newSection addFormRow:infoRow];
            continue;
        }
        XLFormRowDescriptor *newRow = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@~NEW" , row.tag, count]
                                                                              rowType:[[Constants MAPPING_TYPES] objectForKey:type]
                                                                                title:row.title];
        if (!([[NSUserDefaults standardUserDefaults] boolForKey:UDisWizard]) &&
            ([type isEqualToString:kXFormsString] ||
             [type isEqualToString:kXFormsNumber] ||
             [type isEqualToString:kXFormsDecimal])) {
                [newRow.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
            }
        if (subElement.defaultValue) {
            newRow.value = subElement.defaultValue;
        }
        if (row.selectorOptions) {
            newRow.selectorOptions = row.selectorOptions;
        }
        if (row.hidden) {
            newRow.hidden = row.hidden;
        }
        if (row.disabled) {
            newRow.disabled = row.disabled;
        }
        if (row.required) {
            newRow.required = row.required;
        }
        [newSection addFormRow:newRow];
    }
    [form addFormSection:newSection atIndex:count-1];
    [self deselectFormRow:sender];
}

- (void)removeSection:(XLFormRowDescriptor *)sender {
    XLFormDescriptor *form = self.XForm.forms[self.index];
    NSUInteger count = form.formSections.count;
    if (count > 2) {
        [form removeFormSectionAtIndex:count-2];
    }
    [self deselectFormRow:sender];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (self.XForm.loadedLocaly) {
            [[XFormsStore sharedStore] saveFilledForm:self.XForm];
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        NSString *filename = [NSString stringWithFormat:@"%@_%@", self.XForm.name, [MRSDateUtilities openMRSFormatStringWithDate:[NSDate date]]];
        self.XForm.name = filename;
        NSLog(@"name: %@", self.XForm.name);
        [[XFormsStore sharedStore] saveFilledForm:self.XForm];
    }
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
