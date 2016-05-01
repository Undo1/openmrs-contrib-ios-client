//
//  AppDelegate.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//

#import "AppDelegate.h"
#import "MainMenuCollectionViewController.h"
#import "KeychainItemWrapper.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "EncryptedStore.h"
#import "MRSPatient.h"
#import "OpenMRSAPIManager.h"
#import "PatientViewController.h"
#import "PatientVisitListView.h"
#import "PatientEncounterListView.h"
#import "SyncingEngine.h"
#import <Instabug/Instabug.h>
#import "Flurry.h"
#import "Constants.h"
#import "OpenMRSAPIManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
// SignInViewController *vc = [[SignInViewController alloc] init];
//    [[[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil] resetKeychainItem];
    [Instabug startWithToken:@"9827bbb908adffd0d628b2b1f6890899" invocationEvent:IBGInvocationEventShake];
    [Flurry startSession:@"ZTXS4QTSX5499GPKQ6G4"];
    if (!self.window.rootViewController) {
        NSLog(@"Adding a root view controller");
        MainMenuCollectionViewController *menu = [[MainMenuCollectionViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:menu];
        navController.restorationIdentifier = NSStringFromClass([navController class]);
        self.window.rootViewController = navController;
        [self.window makeKeyAndVisible];
    }
    NSString *password = [[[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil] objectForKey:(__bridge id)(kSecValueData)];
    if ([password isEqual:@" "] || [password isEqual:@""] || password == nil) {
        //No password stored, go straight to login screen
        [OpenMRSAPIManager presentLoginController];

    } else {
        [[SyncingEngine sharedEngine] updateExistingOutOfDatePatients:nil];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.window.tintColor = [UIColor colorWithRed:39/255.0
                                            green:139/255.0
                                             blue:146/255.0
                                            alpha:1];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.window setTintColor:[UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1]];
    [[UIView appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:30/255.0 green:130/255.0 blue:112/255.0 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@ { NSForegroundColorAttributeName:[UIColor whiteColor] }];
    [[UISearchBar appearance] setBarTintColor:[UIColor colorWithRed:30/255.0 green:130/255.0 blue:112/255.0 alpha:1]];
    [self.window makeKeyAndVisible];

    /* Setting user defaults */
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:UDisWizard]) {
        [userDefaults setBool:NO forKey:UDisWizard];
    }


    /* Setting paths for offline savingf of XForms */
    NSString * resourcePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *blankFormsPath = [resourcePath stringByAppendingPathComponent:@"blank_forms"];
    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:blankFormsPath
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error])
    {
        NSLog(@"Create directory error: %@", error);
    }
    [userDefaults setObject:blankFormsPath forKey:UDblankForms];

    NSString *filledFormsPath = [resourcePath  stringByAppendingPathComponent:@"filled_forms"];
    error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filledFormsPath
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error])
    {
        NSLog(@"Create directory error: %@", error);
    }
    [userDefaults setObject:filledFormsPath forKey:UDfilledForms];

    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:nil];

    for (int i=0;i<directoryContent.count;i++) {
        NSString *fileAbsPath = [resourcePath stringByAppendingPathComponent:directoryContent[i]];
        if ([directoryContent[i] hasPrefix:@"Audio"]) {
            [[NSFileManager defaultManager] removeItemAtPath:fileAbsPath error:nil];
        }
    }

    if (![userDefaults objectForKey:UDnewSession]) {
        [userDefaults setBool:YES forKey:UDnewSession];
    }
    if (![userDefaults objectForKey:UDrefreshInterval]) {
        [userDefaults setDouble:5 forKey:UDrefreshInterval];
    }
    if (![userDefaults objectForKey:UDshowLocked]) {
        [userDefaults setBool:YES forKey:UDshowLocked];
    }
    if (![userDefaults objectForKey:UDdateFormat]) {
        [userDefaults setObject:@"yyyy-MM-dd" forKey:UDdateFormat];
    }
    if (![userDefaults objectForKey:UDtimeFromat]) {
        [userDefaults setObject:@"HH:mm:ss" forKey:UDtimeFromat];
    }
    if (![userDefaults objectForKey:UDdateTimeFormat]) {
        [userDefaults setObject:@"yyyy-MM-dd'T'HH:mm:ss" forKey:UDdateTimeFormat];
    }

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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return NO;
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return NO;
    }
    return YES;
}
- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
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
        return self.nav3;
    }
    if ([[identifierComponents lastObject] isEqualToString:@"navController4"])  {
        self.nav4 = [[UINavigationController alloc] init];
        self.nav4.restorationIdentifier = [identifierComponents lastObject];
        self.tabbar.viewControllers = [NSArray arrayWithObjects:self.nav1, self.nav2, self.nav3, self.nav4, nil];
        return self.nav4;
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
    /*if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }*/
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];

    [[NSFileManager defaultManager] createDirectoryAtURL:[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] withIntermediateDirectories:NO attributes:nil error:nil];

    NSURL *databaseURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:[NSString stringWithFormat:@"OpenMRS-iOS.sqlite"]];
    NSDictionary *options = @ { EncryptedStorePassphraseKey: [wrapper objectForKey:(__bridge id)(kSecValueData)],EncryptedStoreDatabaseLocation : [databaseURL description],
        NSMigratePersistentStoresAutomaticallyOption : @YES,
        NSInferMappingModelAutomaticallyOption : @YES
    };
    _persistentStoreCoordinator = [EncryptedStore makeStoreWithOptions:options
                                    managedObjectModel:[self managedObjectModel]];
    //_persistentStoreCoordinator = [EncryptedStore makeStoreWithOptions:options managedObjectModel:[self managedObjectModel]];
    /*if (![_persistentStoreCoordinator addPersistentStoreWithType:EncryptedStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }*/
    return _persistentStoreCoordinator;
}
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)clearStore;
{
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"OpenMRS-iOS.sqlite"];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    [fileManager removeItemAtURL:storeURL error:NULL];

    NSError* error = nil;

    if([fileManager fileExistsAtPath:[NSString stringWithContentsOfURL:storeURL encoding:NSASCIIStringEncoding error:&error]])
    {
        [fileManager removeItemAtURL:storeURL error:nil];
    }

    self.managedObjectContext = nil;
    self.persistentStoreCoordinator = nil;
}

@end
