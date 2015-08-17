//
//  XFormsList.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/19/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XFormsList.h"
#import "XForms.h"
#import "XFormsStore.h"
#import "XFormViewController.h"
#import "OpenMRSAPIManager.h"
#import "MBProgressExtension.h"
#import "MBProgressHUD.h"
#import "MRSAlertHandler.h"

@interface XFormsList ()

@property (nonatomic, strong) NSMutableArray *forms;
@property (nonatomic) BOOL FilledForms;

@property (nonatomic) int counter;

@end

@implementation XFormsList

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.tabBarItem.title = NSLocalizedString(@"Form Entry", "Label form entry");
        self.tabBarItem.image = [UIImage imageNamed:@"form-icon"];
    }
    return self;
}

- (instancetype)initBlankForms {
    self = [self init];
    if (self) {
        self.FilledForms = NO;
    }
    return self;
}

- (instancetype)initFilledForms {
    self = [self init];
    if (self) {
        self.FilledForms = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.FilledForms) {
        self.restorationIdentifier = @"filledForms";
    } else {
        self.restorationIdentifier = @"blankForms";
    }
    self.restorationClass = [self class];

    self.navigationItem.title = @"XForms"; //That doesn't need localization.
    if (self.FilledForms) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Label close") style:UIBarButtonItemStylePlain target:self.pvc action:@selector(close)];
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    if (self.FilledForms) {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sync filled form", @"Label sync filled forms")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(sendAll)];
        [self.tableView reloadData];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save all offline", @"Label save all offline")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(saveOffline)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.counter = 1;
    [self updateForms];
}

- (void)updateForms {
    if (self.FilledForms) {
        self.forms = [NSMutableArray arrayWithArray:[[XFormsStore sharedStore] loadFilledFiles]];
    } else {
        [MBProgressExtension showBlockWithTitle:NSLocalizedString(@"Loading", @"Label loading") inView:self.view];
        [[XFormsStore sharedStore] loadForms:^(NSArray *forms, NSError *error) {
            if (!error) {
                if (self.counter == 1) {
                    self.counter = 2;
                } else if (self.counter == 2) {
                    [MBProgressExtension hideActivityIndicatorInView:self.view];
                    [MBProgressExtension showSucessWithTitle:NSLocalizedString(@"Completed", "Label completed") inView:self.view];
                    [self syncBetweenForms:self.forms andWebForms:forms];
                    self.counter = 3;
                }
                self.forms = [NSMutableArray arrayWithArray:forms];
            } else {
                if (self.counter == 2) {
                    [MBProgressExtension hideActivityIndicatorInView:self.view];
                    self.counter = 3;
                }
                [[MRSAlertHandler alertViewForError:self error:error] show];
            }
        }];
    }
}

- (void)syncBetweenForms:(NSArray *)forms andWebForms:(NSArray *)webForms {
    for (XForms *form in forms) {
        BOOL found = NO;
        for (XForms *webForm in webForms) {
            if ([form.name isEqualToString:webForm.name]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [[XFormsStore sharedStore] deleteBlankForm:form];
        }
    }
}

- (void)setForms:(NSMutableArray *)forms {
    NSArray *temp = [forms sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        XForms *form1 = obj1;
        XForms *form2 = obj2;
        return [form1.name compare:form2.name];
    }];
    _forms = [NSMutableArray arrayWithArray:temp];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)setPatient:(MRSPatient *)patient {
    _patient = patient;
    [[XFormsStore sharedStore] setPatient:patient];
}

- (void)close {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.forms.count == 0) {
        UILabel *backgroundLabel = [[UILabel alloc] init];
        backgroundLabel.textAlignment = NSTextAlignmentCenter;
        backgroundLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"No XForms available", @"Label no XForms")];
        if (self.FilledForms) {
            backgroundLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"No offline filled XForms saved", @"Label no offline filled XForms saved")];
        }
        self.tableView.backgroundView = backgroundLabel;
    } else {
        self.tableView.backgroundView = nil;
    }
    return self.forms.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }

    XForms *form = self.forms[indexPath.row];
    cell.textLabel.text = form.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XForms *selectedForm = self.forms[indexPath.row];
    NSString *formID = selectedForm.XFormsID;
    NSString *formName = selectedForm.name;
    NSLog(@"Selected form doc: %@", selectedForm.doc);
    if (selectedForm.doc) {
        NSLog(@"forms: %@", selectedForm.doc.rootElement);
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[XFormViewController alloc] initWithForm:selectedForm WithIndex:0]];
        // Make the form read only if read from Disk.
        if (self.FilledForms) {
            for (XLFormDescriptor *form in selectedForm.forms) {
                form.disabled = YES;
            }
        }
        [self presentViewController:nc animated:YES completion:nil];
    } else {
        if (!self.FilledForms) {
            [MBProgressExtension showBlockWithTitle:@"" inView:self.view];
            [[XFormsStore sharedStore] loadForm:formID andFormName:formName completion:^(XForms *xform, NSError *error) {
                [MBProgressExtension hideActivityIndicatorInView:self.view];
                if (!error) {
                    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[XFormViewController alloc] initWithForm:xform WithIndex:0]];
                    [self presentViewController:nc animated:YES completion:nil];
                } else {
                    [[MRSAlertHandler alertViewForError:self error:error] show];
                    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
            }];
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && self.FilledForms) {
        XForms *form = self.forms[indexPath.row];
        [[XFormsStore sharedStore] deleteFilledForm:form];
        [self.forms removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (void)saveOffline {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.progress = 0.0f;
    [hud show:YES];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSError *master_error = nil;
        for (int i=0;i<self.forms.count;i++) {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.progress = (float)(i)/self.forms.count + 0.001f;
                hud.labelText = [NSString stringWithFormat:@"%d of %lu", i, (unsigned long)self.forms.count];
            });
            XForms *form = self.forms[i];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [[XFormsStore sharedStore] loadForm:form.XFormsID andFormName:form.name completion:^(XForms *xform, NSError *error) {
                if (!error) {
                    self.forms[i] = xform;
                } else {
                    master_error = error;
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (master_error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error")
                                                message:[NSString stringWithFormat:@"%@ XForms", NSLocalizedString(@"Error saving", @"Warning label -Error- and -Saving-")]
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles: nil]
                     show];
                });
                break;
            }
        }
        if (!master_error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                if (self.forms.count == 0) {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No forms to save yet", @"warning no forms to save")
                                                message:@""
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles: nil]
                     show];
                }else {
                    [MBProgressExtension showSucessWithTitle:NSLocalizedString(@"Completed", @"Label completed") inView:self.view];
                }
            });
        }
    });
}

- (void)sendAll {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.progress = 0.0f;
    [hud show:YES];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSError *master_error = nil;
        __block NSMutableArray *finalArray = [NSMutableArray array];
        for (int i=0;i<self.forms.count;i++) {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.progress = (float)(i)/self.forms.count + 0.001f;
                hud.labelText = [NSString stringWithFormat:@"%d of %lu", i, (unsigned long)self.forms.count];
            });
            XForms *form = self.forms[i];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [OpenMRSAPIManager uploadXForms:form completion:^(NSError *error) {
                if (error) {
                    master_error = error;
                    for (int j=i;j<self.forms.count;j++) {
                        [finalArray addObject:self.forms[i]];
                    }
                } else {
                    [[XFormsStore sharedStore] deleteFilledForm:form];
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (master_error) {
                self.forms = finalArray;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    [self.tableView reloadData];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    [[MRSAlertHandler alertViewForError:self error:master_error] show];
                });
                break;
            }
        }
        self.forms = finalArray;
        if (!master_error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                [self.tableView reloadData];
                if (self.forms.count == 0) {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No forms to submit yet", @"warning no forms to submit")
                                                message:@""
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles: nil]
                     show];
                } else {
                    [[MRSAlertHandler alertForSucess:self] show];
                }
            });
        }
    });
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    NSString *lastObj = [identifierComponents lastObject];
    if ([lastObj isEqualToString:@"filledForms"]) {
        return [[self alloc] initFilledForms];
    } else {
        return [[self alloc] initBlankForms];
    }
}
@end
