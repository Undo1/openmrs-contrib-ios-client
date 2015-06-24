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
#import <CoreData/CoreData.h>
#import "EncryptedStore.h"
#import "MRSPatient.h"
#import "OpenMRSAPIManager.h"
#import "PatientViewController.h"
#import "PatientVisitListView.h"
#import "PatientEncounterListView.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
// SignInViewController *vc = [[SignInViewController alloc] init];
//    [[[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil] resetKeychainItem];
    if (!self.window.rootViewController) {
        NSLog(@"Adding a root view controller");
        MainMenuCollectionViewController *menu = [[MainMenuCollectionViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:menu];
        navController.restorationIdentifier = NSStringFromClass([navController class]);
        self.window.rootViewController = navController;
    }
    NSString *password = [[[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil] objectForKey:(__bridge id)(kSecValueData)];
    if ([password isEqual:@" "] || [password isEqual:@""] || password == nil) {
        //No password stored, go straight to login screen
        SignInViewController *signin = [[SignInViewController alloc] init];
        [self.window.rootViewController presentViewController:signin animated:NO completion:nil];
    }

    self.window.tintColor = [UIColor colorWithRed:39/255.0
                                            green:139/255.0
                                             blue:146/255.0
                                            alpha:1];

    //[self updateExistingOutOfDatePatients];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.window setTintColor:[UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1]];
    [[UIView appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:30/255.0 green:130/255.0 blue:112/255.0 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@ { NSForegroundColorAttributeName:[UIColor whiteColor] }];
    [[UISearchBar appearance] setBarTintColor:[UIColor colorWithRed:30/255.0 green:130/255.0 blue:112/255.0 alpha:1]];
    [self.window makeKeyAndVisible];
    
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
        if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 8) {
            [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
            [[UINavigationBar appearance] setTranslucent:NO];
            [[UISearchBar appearance] setClipsToBounds:YES];
        }
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}
- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    NSLog(@"Restoring: %@", [identifierComponents lastObject]);
    if ([[identifierComponents lastObject] isEqualToString:@"UITabBarController"]) {
        self.tabbar = [[UITabBarController alloc] init];
        self.tabbar.restorationIdentifier = [identifierComponents lastObject];
        return self.tabbar;
    }
    if ([[identifierComponents lastObject] isEqualToString:@"navController1"]) {
        self.nav1 = [[UINavigationController alloc] init];
        self.nav1.restorationIdentifier = [identifierComponents lastObject];
        return self.nav1;
    }
    if ([[identifierComponents lastObject] isEqualToString:@"navController2"]) {
        self.nav2 = [[UINavigationController alloc] init];
        self.nav2.restorationIdentifier = [identifierComponents lastObject];
        return self.nav2;
    }
    if ([[identifierComponents lastObject] isEqualToString:@"navContrller3"]) {
        self.nav3 = [[UINavigationController alloc] init];
        self.nav3.restorationIdentifier = [identifierComponents lastObject];
        NSLog(@"Restoring el zft");
        self.tabbar.viewControllers = [NSArray arrayWithObjects:self.nav1, self.nav2, self.nav3, nil];
        return self.nav3;
    }
    UIViewController *nc = [[UINavigationController alloc] init];
    nc.restorationIdentifier = [identifierComponents lastObject];
    if ([identifierComponents count] == 1) {
        self.window.rootViewController = nc;
    }
    return nc;
}
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] & ![self.managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.

             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"openmrs-offline" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"openmrs-offline"];
    NSError *error = nil;
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSDictionary *options = @ { EncryptedStorePassphraseKey: [wrapper objectForKey:(__bridge id)(kSecValueData)] };
    _persistentStoreCoordinator = [EncryptedStore makeStoreWithOptions:options managedObjectModel:[self managedObjectModel]];
    options = @{
                NSMigratePersistentStoresAutomaticallyOption : @YES,
                NSInferMappingModelAutomaticallyOption : @YES
                };
    if (![_persistentStoreCoordinator addPersistentStoreWithType:EncryptedStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)clearStore;
{
    if (self.persistentStoreCoordinator.persistentStores.count == 0) {
        return;
    }
    NSPersistentStore *store = self.persistentStoreCoordinator.persistentStores[0];
    NSError *error;
    NSURL *storeURL = store.URL;
    NSPersistentStoreCoordinator *storeCoordinator = self.persistentStoreCoordinator;
    [storeCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    [[self.managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:EncryptedStoreType configuration:nil URL:storeURL options:options error:&error];//recreates the persistent store
}

- (void)updateExistingOutOfDatePatients {
    NSLog(@"Updating offline patients...");
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Patient" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE", [NSNumber numberWithBool:YES]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"unUpdated: %lu", (unsigned long)results.count);
    for (NSManagedObject *object in results) {
        MRSPatient *patient = [[MRSPatient alloc] init];
        patient.UUID = [object valueForKey:@"uuid"];
        [patient updateFromCoreData];
        NSLog(@"\tUpdating patient: %@", patient.givenName);
        [OpenMRSAPIManager EditPatient:patient completion:^(NSError *error) {
            if (!error) {
                patient.upToDate = YES;
                [patient saveToCoreData];
            }
        }];
    }
}
@end
