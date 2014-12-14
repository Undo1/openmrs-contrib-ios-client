//
//  AppDelegate.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//

#import "AppDelegate.h"
#import "SignInViewController.h"
#import "MainMenuCollectionViewController.h"
#import "KeychainItemWrapper.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
// SignInViewController *vc = [[SignInViewController alloc] init];
    
//    [[[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil] resetKeychainItem];
    
    MainMenuCollectionViewController *menu = [[MainMenuCollectionViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:menu];
    
    [self.window makeKeyAndVisible];
    
    NSString *password = [[[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil] objectForKey:(__bridge id)(kSecValueData)];
    
    if ([password isEqual:@" "] || [password isEqual:@""] || password == nil)
    {
        //No password stored, go straight to login screen
        SignInViewController *signin = [[SignInViewController alloc] init];
        
        [self.window.rootViewController presentViewController:signin animated:NO completion:nil];
    }
    
    [[UIView appearance] setTintColor:[UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1]];
    [[UIView appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:30/255.0 green:130/255.0 blue:112/255.0 alpha:1]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    [[UINavigationBar appearance] setTranslucent:NO];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UISearchBar appearance] setBarTintColor:[UIColor colorWithRed:30/255.0 green:130/255.0 blue:112/255.0 alpha:1]];
    [[UISearchBar appearance] setClipsToBounds:YES];

    
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
