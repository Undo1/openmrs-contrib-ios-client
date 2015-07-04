//
//  AppDelegate.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@class PatientViewController;
@class PatientVisitListView;
@class PatientEncounterListView;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) AFHTTPRequestOperation *currentSearchOperation;

@property (nonatomic, strong) UITabBarController *tabbar;
@property (nonatomic, strong) UINavigationController *nav1;
@property (nonatomic, strong) UINavigationController *nav2;
@property (nonatomic, strong) UINavigationController *nav3;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)clearStore;

@end
