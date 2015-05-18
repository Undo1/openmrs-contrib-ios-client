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
@implementation SignInViewController
- (void)viewDidLoad
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSLog(@"Password: %@", [wrapper objectForKey:(__bridge id)(kSecValueData)]);
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *openMrsLogo = [UIImage imageNamed:@"openmrs-logo"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:openMrsLogo];
    [imageView sizeToFit];
    imageView.frame = CGRectMake(15, 50, 44, 44);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:imageView];
    self.hostTextField = [[UITextField alloc] initWithFrame:CGRectMake(74, 50, self.view.frame.size.width-84, 44)];
    self.hostTextField.borderStyle = UITextBorderStyleNone;
    self.hostTextField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.hostTextField.keyboardType = UIKeyboardTypeURL;
    self.hostTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.hostTextField.placeholder = @"Host (demo.openmrs.org/openmrs)";
    [self.view addSubview:self.hostTextField ];
    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 104, self.view.frame.size.width-40, 44)];
    self.usernameTextField.borderStyle = UITextBorderStyleNone;
    self.usernameTextField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.usernameTextField.placeholder = @"Username (admin)";
    [self.view addSubview:self.usernameTextField];
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 158, self.view.frame.size.width-40, 44)];
    self.passwordTextField.borderStyle = UITextBorderStyleNone;
    self.passwordTextField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.passwordTextField.placeholder = @"Password (••••••••)";
    self.passwordTextField.secureTextEntry = YES;
    [self.view addSubview:self.passwordTextField];
    UIButton *goButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 44)];
    goButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [goButton setTitle:@"Sign in" forState:UIControlStateNormal];
    [goButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goButton];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)signIn:(UIButton *)sender
{
    self.hostTextField.text = [self urlifiedString:self.hostTextField.text];
    NSString *password = self.passwordTextField.text;
    NSString *username = self.usernameTextField.text;
    NSString *host = self.hostTextField.text;
    if (username.length == 0) username = @"admin";
    if (password.length == 0) password = @"Admin123";
    if (host.length == 0 || [host isEqualToString:@"http://"]) host = @"http://demo.openmrs.org/openmrs";
    [OpenMRSAPIManager verifyCredentialsWithUsername:username password:password host:host completion:^(BOOL success) {
        if (success) {
            NSLog(@"Success!");
            [self updateKeychainWithHost:host username:username password:password];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self dismissViewControllerAnimated:YES completion:nil];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            });
        }
        else {
            NSLog(@"Failure!");
            NSString *hostWithOpenmrs = [host stringByAppendingString:@"/openmrs"];
            [OpenMRSAPIManager verifyCredentialsWithUsername:username password:password host:hostWithOpenmrs completion:^(BOOL success) {
                if (success) {
                    [self updateKeychainWithHost:hostWithOpenmrs username:username password:password];
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self dismissViewControllerAnimated:YES completion:nil];
                        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                    });
                }
                else {
                    NSLog(@"Failure");
                }
            }];
        }
    }];
}
- (void)updateKeychainWithHost:(NSString *)host username:(NSString *)username password:(NSString *)password
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    [wrapper setObject:password forKey:(__bridge id)(kSecValueData)];
    [wrapper setObject:username forKey:(__bridge id)(kSecAttrAccount)];
    [wrapper setObject:host forKey:(__bridge id)(kSecAttrService)];
}
- (NSString *)urlifiedString:(NSString *)inputUrl
{
    NSURL *url = [NSURL URLWithString:inputUrl];
    if (url.scheme.length == 0) {
        return [@"http://" stringByAppendingString:inputUrl];
    }
    return inputUrl;
}
@end