//
//  SyncingEngine.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/4/15.
//

#import <CoreData/CoreData.h>
#import "OpenMRSAPIManager.h"
#import "SyncingEngine.h"
#import "AppDelegate.h"

@interface SyncingEngine ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation SyncingEngine

+ (SyncingEngine *)sharedEngine {
    static SyncingEngine *sharedEngine;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[SyncingEngine alloc] init];
    });
    return sharedEngine;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDelegate.managedObjectContext;
    }
    return self;
}

- (void)updateExistingPatientsInCoreData:(void (^)(NSError *error))completion {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Patient" inManagedObjectContext:self.managedObjectContext]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"upToDate == nil"];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error)
        return completion(error);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSError *master_error = nil;
        for (NSManagedObject *object in results) {

            __block MRSPatient *patient = [[MRSPatient alloc] init];
            patient.UUID = [object valueForKey:@"uuid"];
            NSLog(@"Updating patient: %@", patient.UUID);
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [OpenMRSAPIManager getDetailedDataOnPatient:patient completion:^(NSError *error, MRSPatient *detailedPatient) {
                if (!error) {
                    patient = detailedPatient;
                    patient.upToDate = YES;
                    [patient saveToCoreData];
                } else {
                    master_error = error;
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (master_error) {
                break;
            }
        }
        completion(master_error);
    });
}

- (void)updateExistingOutOfDatePatients:(void (^)(NSError *error))completion {
    NSLog(@"Started syncing");
    [self updateExistingPatientsInCoreData:^(NSError *error) {
        if (!error) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:@"Patient" inManagedObjectContext:self.managedObjectContext]];

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"upToDate == %@", [NSNumber numberWithBool:NO]];
            [request setPredicate:predicate];
            NSError *error = nil;
            NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
            if (error)
                return;
            NSLog(@"To sync %d", results.count);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (NSManagedObject *object in results) {

                    __block MRSPatient *patient = [[MRSPatient alloc] init];
                    patient.UUID = [object valueForKey:@"uuid"];
                    NSLog(@"Patient UUID syncing: %@", patient.UUID);
                    [patient updateFromCoreData];
                    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                    [OpenMRSAPIManager EditPatient:patient completion:^(NSError *error) {
                        if (!error) {
                            patient.upToDate = YES;
                            [patient saveToCoreData];
                        }
                        dispatch_semaphore_signal(semaphore);
                    }];
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

                }
                if (completion)
                    completion(nil);
            });
        } else {
            NSLog(@"Failed to sync");
            if (completion)
                completion(error);
        }
    }];
}

- (void)SyncPatient:(MRSPatient *)patient completion:(void (^)(NSError *error))completion {
    [OpenMRSAPIManager EditPatient:patient completion:^(NSError *error) {
        if (!error) {
            patient.upToDate = YES;
            if ([patient isInCoreData]) {
                [patient saveToCoreData];
            }
        }
        completion(error);
    }];
}

@end
