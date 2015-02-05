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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSString *password = [[[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil] objectForKey:(__bridge id)(kSecValueData)];
    
    if ([password isEqual:@" "] || [password isEqual:@""] || password == nil)
    {
        //No password stored, go straight to login screen
        SignInViewController *signin = [[SignInViewController alloc] init];
        
        [self.window.rootViewController presentViewController:signin animated:NO completion:nil];
    }
    
    [[UIView appearance] setTintColor:[UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1]];
    [[UIView appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:30/255.0 green:130/255.0 blue:112/255.0 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    
    [[UISearchBar appearance] setBarTintColor:[UIColor colorWithRed:30/255.0 green:130/255.0 blue:112/255.0 alpha:1]];
    
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)])
    {
        if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 8) {
            [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
            [[UINavigationBar appearance] setTranslucent:NO];
            [[UISearchBar appearance] setClipsToBounds:YES];
        }
    }
    

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([self.managedObjectContext hasChanges] & ![self.managedObjectContext save:&error])
        {
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
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"openmrs-offline" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"openmrs-offline"];
    
    NSError *error = nil;
    
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSDictionary *options = @{ EncryptedStorePassphraseKey: [wrapper objectForKey:(__bridge id)(kSecValueData)] };
    
    _persistentStoreCoordinator = [EncryptedStore makeStoreWithOptions:options managedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:EncryptedStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
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
    if (self.persistentStoreCoordinator.persistentStores.count == 0)
    {
        return;
    }
    
    NSPersistentStore *store = self.persistentStoreCoordinator.persistentStores[0];
    NSError *error;
    NSURL *storeURL = store.URL;
    NSPersistentStoreCoordinator *storeCoordinator = self.persistentStoreCoordinator;
    [storeCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    
    [[self.managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:EncryptedStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
}
@end
