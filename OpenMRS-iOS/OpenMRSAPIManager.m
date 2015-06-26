//
//  OpenMRSAPIManager.m
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//
//

#import "OpenMRSAPIManager.h"
#import "CredentialsLayer.h"
#import "MRSPatient.h"
#import "MRSVisit.h"
#import "MRSPerson.h"
#import "OrderedDictionary.h"
#import "MRSVital.h"
#import "MRSLocation.h"
#import "MRSEncounterOb.h"
#import "MRSEncounter.h"
#import "SignInViewController.h"
#import "AppDelegate.h"
#import "MRSPatientIdentifierType.h"
#import "KeychainItemWrapper.h"
#import "SVProgressHUD.h"
#import "MRSEncounterOb.h"
#import "MRSEncounterType.h"
#import "OpenMRS_iOS-Swift.h"
#import "MRSDateUtilities.h"
#import "MRSHelperFunctions.h"
#import <CoreData/CoreData.h>

@implementation OpenMRSAPIManager
+ (void)verifyCredentialsWithUsername:(NSString *)username password:(NSString *)password host:(NSString *)host completion:(void (^)(BOOL success))completion
{
    [SVProgressHUD show];
    NSURL *hostUrl = [NSURL URLWithString:host];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/user", host] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(YES);
        dispatch_async(dispatch_get_main_queue(), ^ {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Logged In", @"Message -logged- -in-")];
        });
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Couldn't verify creds: %@", error);
        completion(NO);
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (error.code == -1003) //Server with specified hostname not found
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Couldn't find server", @"Message -could- -not- -find- -server-")];
            } else
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Login failed", @"Message -login- -failed-")];
            }
        });
    }];
}
+ (void)getVisitTypesWithCompletion:(void (^)(NSError *, NSArray *))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/visittype", host] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSMutableArray *visitTypes = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in results[@"results"]) {
            MRSVisitType *type = [[MRSVisitType alloc] init];
            type.uuid = dict[@"uuid"];
            type.display = dict[@"display"];
            [visitTypes addObject:type];
        }
        completion(nil, visitTypes);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error, nil);
    }];
}
+ (void)addPatient:(MRSPatient *)patient withIdentifier:(MRSPatientIdentifier *)identifier completion:(void (^)(NSError *error, MRSPatient *createdPatient))completion;
{
    MRSPerson *person = [[MRSPerson alloc] init];
    person.familyName = patient.familyName;
    person.name = patient.name;
    person.age = patient.age;
    person.gender = patient.gender;
    [self addPerson:person completion:^(NSError *error, MRSPerson *createdPerson) {
        if (error != nil) {
            completion(error, nil);
        }
        else {
            KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
            NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
            NSURL *hostUrl = [NSURL URLWithString:host];
            NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
            NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
            [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
            [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/patient", host] parameters:@ {@"person":createdPerson.UUID, @"identifiers":@[@{@"identifier":identifier.identifier, @"identifierType":identifier.identifierType.UUID}]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
                NSLog(@"Results for details:\n\n%@", results);
                MRSPatient *patient = [[MRSPatient alloc] init];
                patient.displayName = results[@"display"];
                patient.locationDisplay = results[@"location"][@"display"];
                if (((NSArray *)results[@"person"][@"addresses"]).count > 0) {
                    patient.address1 = results[@"person"][@"addresses"][0][@"address1"];
                    patient.address2 = results[@"person"][@"addresses"][0][@"address2"];
                    patient.address3 = results[@"person"][@"addresses"][0][@"address3"];
                    patient.address4 = results[@"person"][@"addresses"][0][@"address4"];
                    patient.address5 = results[@"person"][@"addresses"][0][@"address5"];
                    patient.address6 = results[@"person"][@"addresses"][0][@"address6"];
                    patient.cityVillage = results[@"person"][@"addresses"][0][@"cityVillage"];
                    patient.country = results[@"person"][@"addresses"][0][@"country"];
                    patient.latitude = results[@"person"][@"addresses"][0][@"latitude"];
                    patient.longitude = results[@"person"][@"addresses"][0][@"longitude"];
                    patient.postalCode = results[@"person"][@"addresses"][0][@"postalCode"];
                    patient.stateProvince = results[@"person"][@"addresses"][0][@"stateProvince"];
                }
                patient.birthdate = results[@"person"][@"birthdate"];
                patient.birthdateEstimated = results[@"person"][@"birthdateEstimated"];
                patient.causeOfDeath = results[@"person"][@"causeOfDeath"];
                patient.dead = ((int)results[@"person"][@"dead"] == 1);
                patient.gender = results[@"person"][@"gender"];
                patient.UUID = results[@"uuid"];
                patient.name = results[@"display"];
                if (results[@"person"][@"age"] != [NSNull null]) {
                    patient.age = [results[@"person"][@"age"] stringValue];
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"failure: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
                completion(error, nil);
            }];
        }
    }];
}
+ (void)addPerson:(MRSPerson *)person completion:(void (^)(NSError *error, MRSPerson *createdPerson))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    NSDictionary *parameters;
    @try {
        parameters = @ {@"names":@[@{@"givenName":person.name, @"familyName":person.familyName}],@"gender":person.gender,@"age":person.age};
        NSLog(@"Parameters: %@", parameters);
    }
    @catch (NSException *exception) {
        completion([[NSError alloc] init], nil);
        return;
    }
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/person", host] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        MRSPerson *createdPerson = [[MRSPerson alloc] init];
        createdPerson.UUID = results[@"uuid"];
        completion(nil, createdPerson);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure adding patient: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        completion(error, nil);
    }];
}
+ (void)getPatientIdentifierTypesWithCompletion:(void (^)(NSError *error, NSArray *types))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/patientidentifiertype/?v=full", host] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSMutableArray *types = [[NSMutableArray alloc] init];
        for (NSDictionary *typeDict in results[@"results"]) {
            MRSPatientIdentifierType *type = [[MRSPatientIdentifierType alloc] init];
            type.UUID = typeDict[@"uuid"];
            type.display = typeDict[@"display"];
            type.typeDescription = typeDict[@"description"];
            [types addObject:type];
        }
        completion(nil, types);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error, nil);
        NSLog(@"Failure, %@", error);
    }];
}
+ (void)addVisitNote:(NSString *)note toPatient:(MRSPatient *)patient atLocation:(MRSLocation *)location completion:(void (^)(NSError *error))completion;
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    NSDictionary *parameters = @ {@"patient" :
                                  patient.UUID,
                                  @"encounterDatetime" :
                                  [MRSDateUtilities openMRSFormatStringWithDate:[NSDate date]],
                                  @"encounterType" :
                                  @"d7151f82-c1f3-4152-a605-2f9ea7414a79",
                                  @"obs" :
    @[ @{
@"person":patient.UUID,
@"obsDatetime":[MRSDateUtilities openMRSFormatStringWithDate:[NSDate date]],
@"concept":@"162169AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
@"value":note
    }],
    @"location" :
    location.UUID
                                 };
    NSLog(@"parameters: %@", parameters);
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter", host] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        completion(nil);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure, %@", error);
        completion(error);
    }];
}

+ (void)getEncounterTypesWithCompletion:(void (^)(NSError *, NSArray *))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/encountertype", host] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSLog(@"encounter types array: %@", results);
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in results[@"results"]) {
            MRSEncounterType *type = [[MRSEncounterType alloc] init];
            type.UUID = dict[@"uuid"];
            type.display = dict[@"display"];
            [array addObject:type];
        }
        completion(nil, array);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error, nil);
        NSLog(@"Failure, %@", error);
    }];
}
+ (void)getDetailedDataOnEncounter:(MRSEncounter *)encounter completion:(void (^)(NSError *, MRSEncounter *))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter/%@?v=full", host, encounter.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSDictionary *obDict in results[@"obs"]) {
            MRSEncounterOb *ob = [[MRSEncounterOb alloc] init];
            ob.UUID = obDict[@"uuid"];
            ob.display = obDict[@"display"];
            [array addObject:ob];
        }
        encounter.obs = array;
        completion(nil, encounter);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == -1009) { //network down
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"EncounterOb" inManagedObjectContext:appDelegate.managedObjectContext]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(encounter == %@)", encounter.UUID];
            [fetchRequest setPredicate:predicate];
            NSError *error;
            NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (error) {
                NSLog(@"error: %@", error);
            }
            if (results.count > 0) {
                NSMutableArray *obs = [[NSMutableArray alloc] init];
                for (NSManagedObject *object in results) {
                    MRSEncounterOb *encounterOb = [[MRSEncounterOb alloc] init];
                    encounterOb.UUID = [object valueForKey:@"uuid"];
                    encounterOb.encounterDisplay = [object valueForKey:@"encounterDisplay"];
                    encounterOb.display = [object valueForKey:@"display"];
                    [obs addObject:encounterOb];
                }
                encounter.obs = obs;
                completion(nil, encounter);
            }
        } else {
            completion(error, nil);
        }
        NSLog(@"Failure, %@", error);
    }];
}
+ (void)getEncountersForPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, NSArray *encounters))completion
{
    [SVProgressHUD show];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter?patient=%@", host, patient.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSDictionary *visitDict in results[@"results"]) {
            MRSEncounter *visit = [[MRSEncounter alloc] init];
            visit.UUID = visitDict[@"uuid"];
            visit.displayName = visitDict[@"display"];
            [array addObject:visit];
        }
        completion(nil, array);
        dispatch_async(dispatch_get_main_queue(), ^ {
            [SVProgressHUD popActivity];
        });
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [SVProgressHUD popActivity];
        });
        if (error.code == -1009) { //network down
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"Encounter" inManagedObjectContext:appDelegate.managedObjectContext]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(patient == %@)", patient.UUID];
            [fetchRequest setPredicate:predicate];
            NSError *error;
            NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (error) {
                NSLog(@"error: %@", error);
            }
            if (results.count > 0) {
                NSMutableArray *encounters = [[NSMutableArray alloc] init];
                for (NSManagedObject *object in results) {
                    MRSEncounter *encounter = [[MRSEncounter alloc] init];
                    encounter.UUID = [object valueForKey:@"uuid"];
                    encounter.displayName = [object valueForKey:@"displayName"];
                    [encounters addObject:encounter];
                }
                completion(nil, encounters);
            }
        } else {
            completion(error, nil);
        }
        NSLog(@"Failure, %@", error);
    }];
}
+ (void)currentlyActiveVisitFromVisits:(NSArray *)visits withCompletion:(void (^)(NSError *error, MRSVisit *visit))completion
{
    return;
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    __block NSError *error = nil;
    for (MRSVisit *visit in visits) {
        [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/visit/%@?v=custom:(uuid,stopDatetime)", host, visit.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *failureReason) {
            error = failureReason;
        }];
    }
    completion(error, nil);
}

+ (void)getActiveVisits:(NSMutableArray *)activeVisits  From:(int)startIndex  withCompletion:(void (^)(NSError *error))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/visit?includeInactive=false&startIndex=%d&v=full",host,startIndex] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        for (NSDictionary *visit in results[@"results"]) {
            MRSVisit *newVisit = [[MRSVisit alloc] init];
            newVisit.displayName = visit[@"display"];
            newVisit.UUID = visit[@"uuid"];
            newVisit.startDateTime = visit[@"startDatetime"];

            MRSLocation *location = [[MRSLocation alloc] init];
            location.display = visit[@"location"][@"display"];
            location.UUID = visit[@"location"][@"uuid"];
            newVisit.location = location;

            MRSVisitType *type = [[MRSVisitType alloc] init];
            type.uuid = visit[@"visitType"][@"uuid"];
            type.display = visit[@"visitType"][@"display"];
            newVisit.visitType = type;
            
            newVisit.active = [MRSHelperFunctions isNull:visit[@"stopDatetime"]]?YES:NO;

            [activeVisits addObject:newVisit];
        }
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *failureReason) {
        completion(failureReason);
    }];
    
}
+ (void)getVisitsForPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, NSArray *visits))completion
{
    [SVProgressHUD show];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/visit?v=full&patient=%@", host, patient.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSDictionary *visitDict in results[@"results"]) {
            MRSVisit *visit = [[MRSVisit alloc] init];
            MRSLocation *location = [[MRSLocation alloc] init];
            MRSVisitType *visitType =  [[MRSVisitType alloc] init];

            visit.UUID = visitDict[@"uuid"];
            visit.displayName = visitDict[@"display"];
            visit.active = (visitDict[@"stopDatetime"] == nil || visitDict[@"stopDatetime"] == [NSNull null]);
            visit.startDateTime = visitDict[@"startDatetime"];

            location.UUID = visitDict[@"location"][@"uuid"];
            location.display = visitDict[@"location"][@"display"];

            visitType.uuid = visitDict[@"visitType"][@"uuid"];
            visitType.display = visitDict[@"visitType"][@"display"];

            visit.visitType = visitType;
            visit.location = location;
            [array addObject:visit];
        }
        completion(nil, array);
        dispatch_async(dispatch_get_main_queue(), ^ {
            [SVProgressHUD popActivity];
        });
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [SVProgressHUD popActivity];
        });
        if (error.code == -1009) { //network down
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:appDelegate.managedObjectContext]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(patient == %@)", patient.UUID];
            [fetchRequest setPredicate:predicate];
            NSError *error;
            NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (error) {
                NSLog(@"error: %@", error);
            }
            if (results.count > 0) {
                NSMutableArray *visits = [[NSMutableArray alloc] init];
                for (NSManagedObject *object in results) {
                    MRSVisit *visit = [[MRSVisit alloc] init];
                    visit.UUID = [object valueForKey:@"uuid"];
                    visit.displayName = [object valueForKey:@"displayName"];
                    [visits addObject:visit];
                }
                completion(nil, visits);
            }
        } else {
            completion(error, nil);
        }
        NSLog(@"Failure, %@", error);
    }];
}
+ (void)captureVitals:(NSArray *)vitals toPatient:(MRSPatient *)patient atLocation:(MRSLocation *)location completion:(void (^)(NSError *error))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    NSMutableArray *obs = [[NSMutableArray alloc] init];
    for (MRSVital *vital in vitals) {
//        [obs addObject:@{
//                         @"concept" : vital.conceptUUID,
//                         @"obsDatetime" : [self openMRSFormatStringWithDate:[NSDate date]],
//                         @"person" : patient.UUID,
//                         @"value" : vital.value} ];
        OrderedDictionary *dict = [[OrderedDictionary alloc] initWithObjectsAndKeys:vital.conceptUUID,
                                   @"concept", [MRSDateUtilities openMRSFormatStringWithDate:[NSDate date]],
                                   @"obsDatetime", patient.UUID, @"person", vital.value, @"value", nil];
        [obs addObject:dict];
    }
    NSDictionary *parameters = @ {@"patient" :
                                  patient.UUID,
                                  @"encounterDatetime" :
                                  [MRSDateUtilities openMRSFormatStringWithDate:[NSDate date]],
                                  @"encounterType" :
                                  @"67a71486-1a54-468f-ac3e-7091a9a79584",
                                  @"obs" :
                                  obs,
                                  @"location" :
                                  location.UUID
                                 };
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter", host] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
        NSLog(@"Success capturing vitals");
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error);
        NSLog(@"Failure, %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    }];
}
+ (void)startVisitWithLocation:(MRSLocation *)location visitType:(MRSVisitType *)visitType forPatient:(MRSPatient *)patient completion:(void (^)(NSError *error))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    NSDictionary *parameters = @ {};
    @try {
        parameters = @ {@"patient":
                        patient.UUID,
                        @"visitType" :
                        visitType.uuid,
                        @"location" :
                        location.UUID,
                        @"startDatetime" :
                        [MRSDateUtilities openMRSFormatStringWithDate:[NSDate date]]
                       };
        NSLog(@"Parameters: %@", parameters);
    }
    @catch (NSException *exception) {
        completion([[NSError alloc] init]);
        return;
    }
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/visit", host] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error starting visit: %@", error);
        completion(error);
    }];
}

+ (void)stopVisit:(MRSVisit *)visit completion:(void (^)(NSError *))completion {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];

    NSDictionary *parameters = nil;
    @try {
        parameters = @ {
            @"visitType" :
            visit.visitType.uuid,
            @"location" :
            visit.location.UUID,
            @"startDatetime" :
            visit.startDateTime,
            @"stopDatetime" :
            [MRSDateUtilities openMRSFormatStringWithDate:[NSDate date]]
        };
    }
    @catch (NSException *exception) {
        completion([[NSError alloc] init]);
        return;
    }
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/visit/%@", host, visit.UUID] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure, %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        completion([[NSError alloc] init]);
    }];
}

+ (void)getLocationsWithCompletion:(void (^)(NSError *error, NSArray *locations))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/location", host] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSMutableArray *locations = [[NSMutableArray alloc] init];
        for (NSDictionary *locDict in results[@"results"]) {
            MRSLocation *location = [[MRSLocation alloc] init];
            location.UUID = locDict[@"uuid"];
            location.display = locDict[@"display"];
            [locations addObject:location];
        }
        completion(nil, locations);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error, nil);
    }];
}
+ (void)getPatientListWithSearch:(NSString *)search online:(BOOL)online  completion:(void (^)(NSError *error, NSArray *patients))completion
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (online) {
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
        NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
        NSURL *hostUrl = [NSURL URLWithString:host];
        NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
        NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
        [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
        [self cancelPreviousSearchOperations];
        delegate.currentSearchOperation = [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/patient?q=%@", host, [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
            NSMutableArray *patients = [[NSMutableArray alloc] init];
            for (NSDictionary *patient in results[@"results"]) {
                MRSPatient *patientObject = [[MRSPatient alloc] init];
                patientObject.UUID = patient[@"uuid"];
                patientObject.name = patient[@"display"];
                [patients addObject:patientObject];
            }
            completion(nil, patients);
            //        dispatch_async(dispatch_get_main_queue(), ^{
            //            [SVProgressHUD popActivity];
            //        });
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(error, nil);
        }];
    } else {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Patient" inManagedObjectContext:appDelegate.managedObjectContext]];
        if (search.length != 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@) OR (display CONTAINS[cd] %@)", search, search, search];
            [fetchRequest setPredicate:predicate];
        }
        NSError *error;
        NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        NSLog(@"error: %@", error);
        if (results.count > 0) {
            NSMutableArray *patients = [[NSMutableArray alloc] init];
            for (NSManagedObject *object in results) {
                MRSPatient *patient = [[MRSPatient alloc] init];
                patient.UUID = [object valueForKey:@"uuid"];
                [patient updateFromCoreData];
                [patients addObject:patient];
            }
            completion(nil, patients);
        } else {
            completion(error, nil);
        }
    }
}
+ (void)getDetailedDataOnPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, MRSPatient *detailedPatient))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/patient/%@?v=full", host, patient.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        MRSPatient *detailedPatient = [[MRSPatient alloc] init];
        detailedPatient.displayName = results[@"display"];
        detailedPatient.locationDisplay = results[@"location"][@"display"];
        if (![MRSHelperFunctions isNull:results[@"person"][@"preferredAddress"]]) {
            detailedPatient.preferredAddressUUID = results[@"person"][@"preferredAddress"][@"uuid"];
            detailedPatient.address1 = results[@"person"][@"preferredAddress"][@"address1"];
            detailedPatient.address2 = results[@"person"][@"preferredAddress"][@"address2"];
            detailedPatient.address3 = results[@"person"][@"preferredAddress"][@"address3"];
            detailedPatient.address4 = results[@"person"][@"preferredAddress"][@"address4"];
            detailedPatient.address5 = results[@"person"][@"preferredAddress"][@"address5"];
            detailedPatient.address6 = results[@"person"][@"preferredAddress"][@"address6"];
            detailedPatient.cityVillage = results[@"person"][@"preferredAddress"][@"cityVillage"];
            detailedPatient.country = results[@"person"][@"preferredAddress"][@"country"];
            detailedPatient.latitude = results[@"person"][@"preferredAddress"][@"latitude"];
            detailedPatient.longitude = results[@"person"][@"preferredAddress"][@"longitude"];
            detailedPatient.postalCode = results[@"person"][@"preferredAddress"][@"postalCode"];
            detailedPatient.stateProvince = results[@"person"][@"preferredAddress"][@"stateProvince"];
            detailedPatient.countyDistrict = results[@"person"][@"preferredAddress"][@"countyDistrict"];
            detailedPatient.preferredAddressUUID = results[@"person"][@"preferredAddress"][@"uuid"];
        }
        detailedPatient.birthdate = results[@"person"][@"birthdate"];
        detailedPatient.birthdateEstimated = [results[@"person"][@"birthdateEstimated"] boolValue]?@"true":@"false";
        detailedPatient.causeOfDeath = results[@"person"][@"causeOfDeath"];
        detailedPatient.dead = ((int)results[@"person"][@"dead"] == 1);
        detailedPatient.gender = results[@"person"][@"gender"];
        detailedPatient.UUID = results[@"uuid"];
        detailedPatient.name = results[@"display"];
        detailedPatient.preferredNameUUID = results[@"person"][@"preferredName"][@"uuid"];
        detailedPatient.familyName = results[@"person"][@"preferredName"][@"familyName"];
        detailedPatient.familyName2 = results[@"person"][@"preferredName"][@"familyName2"];
        detailedPatient.givenName = results[@"person"][@"preferredName"][@"givenName"];
        detailedPatient.middleName = results[@"person"][@"preferredName"][@"middleName"];
        detailedPatient.preferredNameUUID = results[@"person"][@"preferredName"][@"uuid"];
        if (results[@"person"][@"age"] != [NSNull null]) {
            detailedPatient.age = [results[@"person"][@"age"] stringValue];
        }
        detailedPatient.hasDetailedInfo = YES;
        completion(nil, detailedPatient);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == -1011 || error.code == -1002) {
            [OpenMRSAPIManager presentLoginController];
        }
        completion(error, nil);
    }];
}

+ (void)EditPatient:(MRSPatient *)patient completion:(void (^)(NSError *error))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    
    NSArray *personKeys = @[@"BirthDate", @"BirthDate Estimated", @"Dead", @"Cause Of Death"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                   @"gender": patient.gender
                                                                   }];
    for (NSString *propertyLabel in personKeys) {
        NSString *property = [MRSHelperFunctions formLabelToJSONLabel:propertyLabel];
        if ([property isEqualToString:@"dead"]){
            [parameters setValue:patient.dead?@YES:@NO forKey:property];
            continue;
        }
        if (![MRSHelperFunctions isNull:[patient valueForKey:property]] && ![[patient valueForKey:property] isEqualToString:@""]){
            [parameters setValue:[patient valueForKey:property] forKey:property];
        }
    }
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/person/%@", host, patient.UUID] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        //NSLog(@"Person response: %@", results);
        [self EditNameForPatient:patient completion:completion];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Operation failed... with Error: %@", error);
        completion(error);
    }];
}


+ (void)EditNameForPatient:(MRSPatient *) patient completion:(void (^)(NSError *error))completion {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                        @"givenName": patient.givenName?patient.givenName:[NSNull null],
                                                                                        @"familyName": patient.familyName?patient.familyName:[NSNull null]
                                                                                        }];
    if (![MRSHelperFunctions isNull:patient.middleName] && ![patient.middleName isEqualToString:@""])
        [parameters setValue:patient.middleName forKey:@"middleName"];
    if (![MRSHelperFunctions isNull:patient.familyName2] && ![patient.familyName2 isEqualToString:@""])
        [parameters setValue:patient.familyName2 forKey:@"familyName2"];
    
    //NSLog(@"Name parameters: %@", parameters);
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/person/%@/name/%@", host, patient.UUID, patient.preferredNameUUID] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        //NSLog(@"%@", results);
        [self EditAddressForPatient:patient completion:completion];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Operation failed... with Error: %@", error);
        completion(error);
    }];
}

+ (void)EditAddressForPatient:(MRSPatient *) patient completion:(void (^)(NSError *error))completion {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    
    NSMutableDictionary *parameters =[[NSMutableDictionary alloc] init];
    NSArray *addressKeys = @[@"Address 1", @"Address 2", @"Address 3", @"Address 4", @"Address 5", @"Address 6",
                             @"City Village", @"State Province", @"Country" ,@"Postal Code", @"Latitude", @"Latitude", @"County District"];
    for (NSString *key in addressKeys) {
        NSString *propertyKey = [MRSHelperFunctions formLabelToJSONLabel:key];
        if (![MRSHelperFunctions isNull:[patient valueForKey:propertyKey]]  && ![[patient valueForKey:propertyKey] isEqualToString:@""]) {
            if ([propertyKey  isEqual: @"preferred"]) {
                NSLog(@"propety: %@", propertyKey);
                NSString *value = [patient valueForKey:propertyKey];
                [parameters setValue:[value isEqualToString:@"1"]?@"true":@"false" forKey:propertyKey];
                continue;
            }
            [parameters setValue:[patient valueForKey:propertyKey] forKey:propertyKey];
        }
    }
    //NSLog(@"Address parameters:\n%@", parameters);
    if (parameters.count != 0) {
        NSString *preferredAddressUUID = [MRSHelperFunctions isNull:patient.preferredAddressUUID] ? @"" : [NSString stringWithFormat:@"/%@", patient.preferredAddressUUID];
        [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/person/%@/address%@", host, patient.UUID, preferredAddressUUID] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
            //NSLog(@"%@", results);
            patient.preferredAddressUUID = results[@"uuid"];
            completion(nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Operation failed... with Error: %@", error);
            completion(error);
        }];
    } else {
        completion(nil);
    }
}

+ (void)presentLoginController
{
    SignInViewController *vc = [[SignInViewController alloc] init];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
}
+ (void)logout
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    [[CredentialsLayer sharedManagerWithHost:host] setUsername:nil andPassword:nil];
    [wrapper resetKeychainItem];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [OpenMRSAPIManager presentLoginController];
}
+ (void)cancelPreviousSearchOperations
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.currentSearchOperation cancel];
}
@end
