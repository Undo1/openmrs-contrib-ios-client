//
//  AppDelegate.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) AFHTTPRequestOperation *currentSearchOperation;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)clearStore;
- (void)updateExistingOutOfDatePatients;

@end
