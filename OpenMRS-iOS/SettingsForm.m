//
//  SettingsForm.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/15/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "SettingsForm.h"
#import "Constants.h"
#import "KeychainItemWrapper.h"
#import <Instabug/Instabug.h>
#import "AppDelegate.h"
#import "SyncingEngine.h"


@interface SettingsForm () <UIWebViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation SettingsForm

NSString *kUserName = @"username";
NSString *kHost = @"host";
NSString *kVersion = @"version";
NSString *kSendFeedback = @"sendFeedback";
NSString *kRemoveOfflinePatient = @"removePatient";
NSString *kSyncPatient = @"syncPatient";
NSString *kRefreshInterval = @"refreshInterval";
NSString *kWizardMode = @"wizardMode";


- (instancetype)init {
    self = [super init];
    if (self) {
        [[UIStepper appearance] setTintColor:[UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1]];
        [self initForm];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(exitSettings)];
}

- (void)initForm {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    host = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Backend host", @"Label backend host"), host];

    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"Settings", @"Label settings")];
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if ([appVersion componentsSeparatedByString:@"."].count == 2) {
        appVersion = [appVersion stringByAppendingString:@".0"];
    }
    
    [form addFormSection:section];

    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:kUserName rowType:XLFormRowDescriptorTypeInfo title:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Logged in as", @"Label -logged- -in- -as"), username]];
    row.disabled = @YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kHost rowType:XLFormRowDescriptorTypeInfo title:host];
    row.disabled = @YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kVersion rowType:XLFormRowDescriptorTypeInfo title:[NSString stringWithFormat:@"%@: (%@)", NSLocalizedString(@"App version", @"Label version"), appVersion]];
    row.disabled = @YES;
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSendFeedback rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"About the project", @"Label about the project")];
    row.action.formSelector = @selector(showCredits);
    [row.cellConfig setObject:[UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1] forKey:@"textLabel.color"];
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSendFeedback rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"Send feedback", @"Label send feedback")];
    row.action.formSelector = @selector(sendFeedback);
    [row.cellConfig setObject:[UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1] forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRemoveOfflinePatient rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"Remove Offline Patients", @"Label -remove- -offline- -patients-")];
    row.action.formSelector = @selector(removeOfflinePatients);
    [row.cellConfig setObject:[UIColor redColor] forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSyncPatient rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"Sync offline patients", @"Label -sync- -offline- -patients-")];
    row.action.formSelector = @selector(syncOfflinePatients);
    [row.cellConfig setObject:[UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1] forKey:@"textLabel.color"];
    [section addFormRow:row];
    
    double interval = [[NSUserDefaults standardUserDefaults] doubleForKey:UDrefreshInterval];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRefreshInterval
                                                rowType:XLFormRowDescriptorTypeStepCounter
                                                  title:[NSString stringWithFormat:@"%@\n(%.f %@)", NSLocalizedString(@"Patient refersh interval", @"Label -patient- -refresh- -interval-"), interval, NSLocalizedString(@"minutes", @"word minutes")]];
    row.value = @(interval);
    [row.cellConfig setObject:@(0) forKey:@"textLabel.numberOfLines"];
    [row.cellConfig setObject:@(NSLineBreakByWordWrapping) forKey:@"textLabel.lineBreakMode"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kWizardMode rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:NSLocalizedString(@"XForm View", @"Label xform view")];
    row.selectorOptions = @[NSLocalizedString(@"Single form", @"Label single form"),
                            NSLocalizedString(@"Wizard mode", @"Label wizard mode")];
    BOOL isWizard = [[NSUserDefaults standardUserDefaults] boolForKey:UDisWizard];
    if (isWizard)
        row.value = NSLocalizedString(@"Wizard mode", @"Label wizard mode");
    else
        row.value = NSLocalizedString(@"Single form", @"Label single form");
    
    [row.cellConfig setObject:@(0) forKey:@"textLabel.numberOfLines"];
    [row.cellConfig setObject:@(NSLineBreakByWordWrapping) forKey:@"textLabel.lineBreakMode"];
    [section addFormRow:row];
    
    self.form = form;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && (indexPath.row == 1  || indexPath.row == 2)) {
        return 33;
    } else {
        return 44;
    }
}

- (void)exitSettings {
    XLFormRowDescriptor *row = [self.form formRowWithTag:kWizardMode];
    if ([row.value isEqualToString: NSLocalizedString(@"Single form", @"Label single form")]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UDisWizard];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UDisWizard];
    }
    
    row = [self.form formRowWithTag:kRefreshInterval];
    [[NSUserDefaults standardUserDefaults] setDouble:[row.value floatValue] forKey:UDrefreshInterval];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showCredits {
    UIWebView *webview = [[UIWebView alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://wiki.openmrs.org/display/docs/OpenMRS+iOS+Client"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    webview.delegate = self;
    [webview loadRequest:request];

    UIViewController *webVC = [[UIViewController alloc] init];
    webVC.view = webview;
    webVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissWebView)];
    webVC.title = NSLocalizedString(@"About the project", @"Label about the project");

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    [webVC navigationItem].rightBarButtonItem = barButton;
    [self.activityIndicator startAnimating];

    UINavigationController *webViewNav = [[UINavigationController alloc] initWithRootViewController:webVC];

    [self presentViewController:webViewNav animated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}

- (void)dismissWebView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendFeedback {
    [Instabug invokeFeedbackSender];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:4 inSection:0] animated:YES];
}

- (void)removeOfflinePatients {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate clearStore];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] animated:YES];
}

- (void)syncOfflinePatients {
    [[SyncingEngine sharedEngine] updateExistingOutOfDatePatients:nil];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] animated:YES];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    return [[self alloc] init];
}
@end
