//
//  SyncingAtLaunchViewController.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 6/25/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "SyncingAtLaunchViewController.h"
#import "AppDelegate.h"

@interface SyncingAtLaunchViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic) BOOL isButtonHidden;

@end

@implementation SyncingAtLaunchViewController


- (void)loadview {
    self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openmrs-logo"]];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    NSLog(@"view did load");
    [super viewDidLoad];
    self.isButtonHidden = YES;
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    self.button.hidden = self.isButtonHidden;
    
    self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openmrs-logo"]];
    self.view.backgroundColor = [UIColor whiteColor];

    self.label = [[UILabel alloc] init];
    self.label.text = NSLocalizedString(@"Syncing your offline saved patients...", @"Syncing with server message");
    [self.label sizeToFit];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.label];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.button sizeToFit];
    [self.button setTitle:NSLocalizedString(@"Retry", @"Button title retry") forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    self.button.hidden = self.isButtonHidden;
    [self.view addSubview:self.button];
    self.view.userInteractionEnabled = YES;
    NSDictionary *views = @{
                            @"label": self.label,
                            @"spinner": self.spinner,
                            @"retry": self.button
                            };
    NSLog(@"Self = %@", self.view);
    NSLog(@"Subviews = %@", self.view.subviews);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[retry]-10-[label]-10-[spinner]-20-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:@[
                                     [NSLayoutConstraint constraintWithItem:self.label
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:1.0],
                                     [NSLayoutConstraint constraintWithItem:self.spinner
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:1.0],
                                     [NSLayoutConstraint constraintWithItem:self.button
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:1.0]
                                     ]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self performSelector:@selector(retry) withObject:self afterDelay:2.0];
}


- (void)retry {
    NSLog(@"RETRY PRESSED");
    if (!self.isButtonHidden) {
        self.isButtonHidden = YES;
        self.button.hidden = self.isButtonHidden;
        [self.spinner startAnimating];
        self.label.text = NSLocalizedString(@"Syncing your offline saved patients.", @"Syncing with server message");
    }
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    [self foo:app];
}
- (void) foo:(AppDelegate *)app {
    [app updateExistingPatientsInCoreData:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.isButtonHidden = NO;
                self.button.hidden = self.isButtonHidden;
                [self.button becomeFirstResponder];
                self.label.text = NSLocalizedString(@"Make sure you are connected to the internet.", @"Error syncing with server message");
                [self.spinner stopAnimating];
            } else {
                NSLog(@"Done with user defualts: %d", [[NSUserDefaults standardUserDefaults] boolForKey:@"patientsAreSynced"]);
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"patientsAreSynced"];
                [self performSelector:@selector(dismissViewAfterDelay) withObject:self afterDelay:1.0];
            }
        });
    }];
}
- (void)dismissViewAfterDelay {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:[NSNumber numberWithBool:self.isButtonHidden] forKey:@"isButtonHidden"];
    [super encodeRestorableStateWithCoder:coder];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    SyncingAtLaunchViewController *sync = [[SyncingAtLaunchViewController alloc] init];
    sync.isButtonHidden = [[coder decodeObjectForKey:@"isButtonHidden"] boolValue];
    return sync;
}
@end
