//
//  SignInViewController.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//
//

#import "SignInViewController.h"
#import "OpenMRSAPIManager.h"
#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import "MRSAlertHandler.h"
#import "MBProgressExtension.h"

@interface SignInViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *host;
@property (nonatomic, strong) UILabel *username;
@property (nonatomic, strong) UILabel *password;
@property (nonatomic, strong) UIButton *goButton;
@property (nonatomic, strong) UIButton *demoButton;

@end

@implementation SignInViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];

    [self setUpViews];
    [self setUpContrains];
}

- (void)setUpViews{
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *openMrsLogo = [UIImage imageNamed:@"openmrs-logo"];
    self.imageView = [[UIImageView alloc] initWithImage:openMrsLogo];
    [self.imageView sizeToFit];
    //imageView.frame = CGRectMake(15, 50, 44, 44);
    //imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.imageView];

    self.host = [[UILabel alloc] init];
    self.host.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Host", @"Label host")];
    [self.host sizeToFit];
    self.host.translatesAutoresizingMaskIntoConstraints = NO;
    self.host.textColor = [UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1];
    [self.host setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.view addSubview:self.host];

    self.hostTextField = [[UITextField alloc] init];
    self.hostTextField.borderStyle = UITextBorderStyleNone;
    self.hostTextField.keyboardType = UIKeyboardTypeURL;
    self.hostTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.hostTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.hostTextField.placeholder = @"host URL";
    self.hostTextField.font = self.host.font;
#ifdef DEBUG
    self.hostTextField.text = @"http://52.27.34.83:8080/openmrs";
#endif
    self.hostTextField.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.hostTextField ];

    self.username = [[UILabel alloc] init];
    self.username.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Username", @"Label username")];
    [self.username sizeToFit];
    self.username.translatesAutoresizingMaskIntoConstraints = NO;
    self.username.textColor = [UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1];
    [self.view addSubview:self.username];

    self.usernameTextField = [[UITextField alloc] init];
    self.usernameTextField.borderStyle = UITextBorderStyleNone;
    self.usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameTextField.textAlignment = NSTextAlignmentLeft;
    self.usernameTextField.placeholder = @"username";
#ifdef DEBUG
    self.usernameTextField.text = @"admin";
#endif
    [self.view addSubview:self.usernameTextField];

    self.password = [[UILabel alloc] init];
    self.password.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Password", @"Label password")];
    [self.password sizeToFit];
    self.password.translatesAutoresizingMaskIntoConstraints = NO;
    self.password.textColor = [UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1];
    [self.view addSubview:self.password];

    self.passwordTextField = [[UITextField alloc] init];
    self.passwordTextField.borderStyle = UITextBorderStyleNone;
    self.passwordTextField.placeholder = @"password";
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.textAlignment = NSTextAlignmentLeft;
    self.passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
#ifdef DEBUG
    self.passwordTextField.text = @"Admin123";
#endif
    [self.view addSubview:self.passwordTextField];

    self.goButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.goButton setTitle:NSLocalizedString(@"Sign in", @"Lable -sign- -in") forState:UIControlStateNormal];
    [self.goButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.goButton.titleLabel.font = self.host.font;
    [self.goButton setBackgroundColor:[UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1]];
    self.goButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.goButton addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
    //[self.goButton sizeToFit];
    self.goButton.layer.cornerRadius = 10;
    [self.view addSubview:self.goButton];
    
    self.demoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.demoButton setTitle:@"Demo" forState:UIControlStateNormal];
    [self.demoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.demoButton.titleLabel.font = self.host.font;
    [self.demoButton setBackgroundColor:[UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1]];
    self.demoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.demoButton addTarget:self action:@selector(demo:) forControlEvents:UIControlEventTouchUpInside];
    self.demoButton.layer.cornerRadius = 10;
    [self.view addSubview:self.demoButton];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)setUpContrains {
    NSDictionary *viewsDict = @{
                                @"image": self.imageView,
                                @"host": self.host,
                                @"hostTF": self.hostTextField,
                                @"username": self.username,
                                @"usernameTF": self.usernameTextField,
                                @"password": self.password,
                                @"passwordTF": self.passwordTextField,
                                @"button": self.goButton,
                                @"demo": self.demoButton
                                };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[image]-20-[host]-10-[username]-10-[password]-50-[button(40)]-10-[demo(40)]" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.host attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self.hostTextField attribute:NSLayoutAttributeBaseline multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.username attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self.usernameTextField attribute:NSLayoutAttributeBaseline multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.password attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeBaseline multiplier:1 constant:0]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[host]-5-[hostTF]-5-|" options:0 metrics:nil views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[username]-5-[usernameTF]-5-|" options:0 metrics:nil views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[password]-5-[passwordTF]-5-|" options:0 metrics:nil views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[button]-20-|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[demo]-20-|" options:0 metrics:nil views:viewsDict]];
    
}

- (void)signIn:(UIButton *)sender
{
    NSMutableArray *fieldNames = [NSMutableArray array];
    if ([self.hostTextField.text  isEqualToString:@""]) {
        [fieldNames addObject:NSLocalizedString(@"Host", @"Label host")];
    }
    if ([self.usernameTextField.text isEqualToString:@""]) {
        [fieldNames addObject:NSLocalizedString(@"Username", @"Label username")];
    }
    if ([self.passwordTextField.text isEqualToString:@""]) {
        [fieldNames addObject:NSLocalizedString(@"Password", @"Label password")];
    }
    if (fieldNames.count > 0) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error")
                                    message:[NSString stringWithFormat:@"(%@) %@.",
                                             [fieldNames componentsJoinedByString:@", "],
                                             NSLocalizedString(@"is empty", @"alert msesage empty files")]
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]
         show];
        return;
    }

    NSString *password = self.passwordTextField.text;
    NSString *username = self.usernameTextField.text;
    NSString *host = self.hostTextField.text;
    host = [self reCheckHost:host];
    self.hostTextField.text = host;

    [MBProgressExtension showBlockWithTitle:NSLocalizedString(@"Loading", @"Label loading") inView:self.view];
    [OpenMRSAPIManager verifyCredentialsWithUsername:username password:password host:host completion:^(NSError *error) {
        [MBProgressExtension hideActivityIndicatorInView:self.view];
        if (!error) {
            [MBProgressExtension showSucessWithTitle:NSLocalizedString(@"Logged In", @"Message -logged- -in-") inView:self.presentingViewController.view];
            [self updateKeychainWithHost:host username:username password:password];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self dismissViewControllerAnimated:YES completion:nil];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            });
        }
        else {
            if (error.code == errBadRequest) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error")
                                           message:[NSString stringWithFormat:@"%@!", NSLocalizedString(@"Invalid credentials", @"warning label invalid credentials")]
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles: nil]
                 show];
            } else {
                [[MRSAlertHandler alertViewForError:self error:error] show];
            }
        }
    }];
}

- (NSString *)reCheckHost:(NSString *)host {
    if (![host hasPrefix:@"http://"]) {
        host = [@"http://" stringByAppendingString:host];
    }
    return host;
}

- (void)demo:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Demo"
                                message:[NSString stringWithFormat:@"%@?", NSLocalizedString(@"Are you sure that you want to Demo the iOS app using OpenMRS demo server", @"warning going to demo server")]
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"No", @"No")
                      otherButtonTitles:NSLocalizedString(@"Yes", "Yes"), nil]
     show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Demo"]) {
        if (buttonIndex == 1) {
            self.hostTextField.text = @"http://demo.openmrs.org/openmrs";
            self.usernameTextField.text = @"admin";
            self.passwordTextField.text = @"Admin123";
            [self signIn:nil];
        }
    }
}
- (void)updateKeychainWithHost:(NSString *)host username:(NSString *)username password:(NSString *)password
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    [wrapper setObject:password forKey:(__bridge id)(kSecValueData)];
    [wrapper setObject:username forKey:(__bridge id)(kSecAttrAccount)];
    [wrapper setObject:host forKey:(__bridge id)(kSecAttrService)];
}

@end