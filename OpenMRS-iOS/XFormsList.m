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
#import "SVProgressHUD.h"
#import "OpenMRSAPIManager.h"

@interface XFormsList ()

@property (nonatomic, strong) NSMutableArray *forms;
@property (nonatomic) BOOL FilledForms;

@end

@implementation XFormsList

- (instancetype)init {
    self = [super init];
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
    
    self.navigationItem.title = @"XForms"; //That doesn't need localization.
    if (self.FilledForms) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    if (self.FilledForms) {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send all", @"Label send all")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(sendAll)];

        [self updateForms];
        [self.tableView reloadData];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save offline", @"Label save offline")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(saveOffline)];

        [self updateForms];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateForms];
}

- (void)updateForms {
    if (self.FilledForms) {
        self.forms = [NSMutableArray arrayWithArray:[[XFormsStore sharedStore] loadFilledFiles]];
    } else {
        [[XFormsStore sharedStore] loadForms:^(NSArray *forms, NSError *error) {
            if (!error) {
                self.forms = [NSMutableArray arrayWithArray:forms];
            } else {
                if (!self.forms) {
                    UIAlertView *alertLoadingForms = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error")
                                                                                message:NSLocalizedString(@"Cannot load xforms, If you are connected please check xforms support on server", @"Warning message for error loading xforms list")
                                                                               delegate:self
                                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Canel button label")
                                                                      otherButtonTitles: nil];
                    [alertLoadingForms show];
                }
            }
        }];
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
        [self presentViewController:nc animated:YES completion:nil];
    } else {
        if (!self.FilledForms) {
            [[XFormsStore sharedStore] loadForm:formID andFormName:formName completion:^(XForms *xform, NSError *error) {
                if (!error) {
                    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[XFormViewController alloc] initWithForm:xform WithIndex:0]];
                    [self presentViewController:nc animated:YES completion:nil];
                } else {
                    UIAlertView *corruptedForm = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error")
                                                                            message:NSLocalizedString(@"Can not open xform, If you are connected to the internet. this form maybe deleted or corrupted", @"Warning can not load xforms")
                                                                           delegate:self
                                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Canel button label")
                                                                  otherButtonTitles: nil];
                    [corruptedForm show];
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSError *master_error = nil;
        for (int i=0;i<self.forms.count;i++) {
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
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ XForms", NSLocalizedString(@"Error saving", @"Warning label -Error- and -Saving-")]];
                break;
            }
        }
    });
}

- (void)sendAll {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSError *master_error = nil;
        for (int i=0;i<self.forms.count;i++) {
            XForms *form = self.forms[i];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [OpenMRSAPIManager uploadXForms:form completion:^(NSError *error) {
                if (error) {
                    master_error = error;
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (master_error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ -%@- aborting..", NSLocalizedString(@"Error saving", @"Warning label -Error- and -Saving-"), form.name, NSLocalizedString(@"aborting", @"aborting")]];
                break;
            }
        }
    });
}
@end
