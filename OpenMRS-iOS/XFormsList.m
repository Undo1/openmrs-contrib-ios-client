//
//  XFormsList.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/19/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XFormsList.h"
#import "XForms.h"
#import "OpenMRSAPIManager.h"
#import "XFormViewController.h"

@interface XFormsList ()

@property (nonatomic, strong) NSArray *forms;

@end

@implementation XFormsList

- (instancetype)initWithForms:(NSArray *)forms {
    self = [super init];
    if (self) {
        self.forms = forms;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"XForms"; //That doesn't need localization.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Label close")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(close)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.forms.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
    if (indexPath.row == 1) {
        formID = @"3";
    }
    [OpenMRSAPIManager getXformWithID:formID completion:^(XForms *form, NSError *error) {
        if (!error) {
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[XFormViewController alloc] initWithForm:form WithIndex:0]];
            [self presentViewController:nc animated:YES completion:nil];
        } else {
            NSLog(@"can't get error");
        }
    }];
}

- (void)close {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
