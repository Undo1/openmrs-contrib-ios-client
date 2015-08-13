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

@property (nonatomic, strong) UISegmentedControl *filledOrBlank;
@property (nonatomic, strong) NSMutableArray *forms;

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

- (instancetype)initWithForms:(NSArray *)forms {
    self = [self init];
    if (self) {
        self.forms = [NSMutableArray arrayWithArray:forms];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"XForms"; //That doesn't need localization.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save offline", @"Label save offline")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(saveOffline)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.filledOrBlank = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Blank forms", @"Label blank forms"), NSLocalizedString(@"Filled forms", @"Label filled forms")]];
    self.filledOrBlank.selectedSegmentIndex = 0;
    [self.filledOrBlank addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIView *headerView = [[UIView alloc] init];
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat segmentHeight = 33;
    CGFloat segmentWidth = 250;
    CGFloat height = 44;
    [headerView setFrame:CGRectMake(0, 0, width, 44)];
    [self.filledOrBlank setFrame:CGRectMake((width-segmentWidth)/2.0, ((height-segmentHeight)/2), segmentWidth, segmentHeight)];
    self.filledOrBlank.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [headerView addSubview:self.filledOrBlank];
    self.tableView.tableHeaderView = headerView;
    
    [[XFormsStore sharedStore] loadForms:^(NSArray *forms, NSError *error) {
        if (!error) {
            self.forms = [NSMutableArray arrayWithArray:forms];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)setPatient:(MRSPatient *)patient {
    _patient = patient;
    [[XFormsStore sharedStore] setPatient:patient];
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
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[XFormViewController alloc] initWithForm:selectedForm WithIndex:0]];
        [self presentViewController:nc animated:YES completion:nil];
    } else {
        if (self.filledOrBlank.selectedSegmentIndex == 0) {
            [[XFormsStore sharedStore] loadForm:formID andFormName:formName completion:^(XForms *xform, NSError *error) {
                if (!error) {
                    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[XFormViewController alloc] initWithForm:xform WithIndex:0]];
                    [self presentViewController:nc animated:YES completion:nil];
                } else {
                    NSLog(@"can't get error");
                }
            }];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && self.filledOrBlank.selectedSegmentIndex == 1) {
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

- (void)switchValueChanged:(UISegmentedControl *)segmentControl {
    if (segmentControl.selectedSegmentIndex == 0) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Save offline", @"Label save offline");
        self.navigationItem.rightBarButtonItem.action = @selector(saveOffline);

        [[XFormsStore sharedStore] loadForms:^(NSArray *forms, NSError *error) {
            if (forms) {
                self.forms = [NSMutableArray arrayWithArray:forms];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    [self.tableView reloadData];
                });
            }
        }];
    } else {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Send all", @"Label send all");
        self.navigationItem.rightBarButtonItem.action = @selector(sendAll);

        self.forms = [NSMutableArray arrayWithArray:[[XFormsStore sharedStore] loadFilledFiles]];
        [self.tableView reloadData];
    }
}
@end
