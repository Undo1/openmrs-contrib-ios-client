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
#import <CoreData/CoreData.h>

@implementation OpenMRSAPIManager
+ (void)verifyCredentialsWithUsername:(NSString *)username password:(NSString *)password host:(NSString *)host completion:(void (^)(BOOL success))completion
{
    [SVProgressHUD show];
    
    NSURL *hostUrl = [NSURL URLWithString:host];
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/user", host] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(YES);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"Logged In"];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Couldn't verify creds: %@", error);
        completion(NO);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error.code == -1003) //Server with specified hostname not found
            {
                [SVProgressHUD showErrorWithStatus:@"Couldn't find server"];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"Login failed"];
            }
        });
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
        if (error != nil)
        {
            completion(error, nil);
        }
        else
        {
            KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
            NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
            NSURL *hostUrl = [NSURL URLWithString:host];
            NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
            NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
            
            [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
            
            [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/patient", host] parameters:@{@"person" : createdPerson.UUID, @"identifiers" : @[@{@"identifier" : identifier.identifier, @"identifierType" : identifier.identifierType.UUID}]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
                
                MRSPatient *patient = [[MRSPatient alloc] init];
                patient.displayName = results[@"display"];
                patient.locationDisplay = results[@"location"][@"display"];
                if (((NSArray *)results[@"person"][@"addresses"]).count > 0)
                {
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
                patient.age = [results[@"person"][@"age"] stringValue];
                
                completion(nil, patient);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"failure: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
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
        parameters = @{@"names":@[@{@"givenName": person.name, @"familyName": person.familyName}],@"gender":person.gender,@"age":person.age};
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

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/patientidentifiertype", host] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        
        NSMutableArray *types = [[NSMutableArray alloc] init];
        
        for (NSDictionary *typeDict in results[@"results"]) {
            MRSPatientIdentifierType *type = [[MRSPatientIdentifierType alloc] init];
            type.UUID = typeDict[@"uuid"];
            type.display = typeDict[@"display"];
            [types addObject:type];
        }
        
        completion(nil, types);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

    NSDictionary *parameters = @{@"patient" : patient.UUID,
                                 @"encounterDatetime" : [self openMRSFormatStringWithDate:[NSDate date]],
                                 @"encounterType" : @"d7151f82-c1f3-4152-a605-2f9ea7414a79",
                                 @"obs" : @[ @{
                                             @"person" : patient.UUID,
                                             @"obsDatetime" : [self openMRSFormatStringWithDate:[NSDate date]],
                                             @"concept" : @"162169AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                                             @"value" : note
                                         }],
                                 @"location" : location.UUID};

    NSLog(@"parameters: %@", parameters);
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter", host] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure, %@", error);
        completion(error);
    }];
}
+ (NSString *)openMRSFormatStringWithDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-d'T'HH:mm:ss.SSSZ"];

    NSString *stringFromDate = [formatter stringFromDate:date];
    NSLog(@"stringFromDate: %@", stringFromDate);

    return stringFromDate;
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    
    NSLog(@"%@", encounter.UUID);
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter/%@?v=full", host, encounter.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSLog(@"encounter detail array: %@", results);
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (NSDictionary *obDict in results[@"obs"]) {
            MRSEncounterOb *ob = [[MRSEncounterOb alloc] init];
            ob.UUID = obDict[@"uuid"];
            ob.display = obDict[@"display"];
            [array addObject:ob];
        }
        encounter.obs = array;
        
        completion(nil, encounter);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == -1009) //network down
        {
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"EncounterOb" inManagedObjectContext:appDelegate.managedObjectContext]];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(encounter == %@)", encounter.UUID];
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if (error)
            {
                NSLog(@"error: %@", error);
            }
            
            if (results.count > 0)
            {
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
        }
        else
        {
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
        NSLog(@"encounter array: %@", results);
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (NSDictionary *visitDict in results[@"results"]) {
            MRSEncounter *visit = [[MRSEncounter alloc] init];
            visit.UUID = visitDict[@"uuid"];
            visit.displayName = visitDict[@"display"];
            [array addObject:visit];
        }
        completion(nil, array);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD popActivity];
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD popActivity];
        });
        if (error.code == -1009) //network down
        {
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"Encounter" inManagedObjectContext:appDelegate.managedObjectContext]];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(patient == %@)", patient.UUID];
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if (error)
            {
                NSLog(@"error: %@", error);
            }
            
            if (results.count > 0)
            {
                NSMutableArray *encounters = [[NSMutableArray alloc] init];
                for (NSManagedObject *object in results) {
                    MRSEncounter *encounter = [[MRSEncounter alloc] init];
                    encounter.UUID = [object valueForKey:@"uuid"];
                    encounter.displayName = [object valueForKey:@"displayName"];
                    [encounters addObject:encounter];
                }
                completion(nil, encounters);
            }
        }
        else
        {
            completion(error, nil);
        }
        NSLog(@"Failure, %@", error);
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
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/visit?patient=%@", host, patient.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (NSDictionary *visitDict in results[@"results"]) {
            MRSVisit *visit = [[MRSVisit alloc] init];
            visit.UUID = visitDict[@"uuid"];
            visit.displayName = visitDict[@"display"];
            [array addObject:visit];
        }
        completion(nil, array);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD popActivity];
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD popActivity];
        });
        if (error.code == -1009) //network down
        {
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:appDelegate.managedObjectContext]];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(patient == %@)", patient.UUID];
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if (error)
            {
                NSLog(@"error: %@", error);
            }
            
            if (results.count > 0)
            {
                NSMutableArray *visits = [[NSMutableArray alloc] init];
                for (NSManagedObject *object in results) {
                    MRSVisit *visit = [[MRSVisit alloc] init];
                    visit.UUID = [object valueForKey:@"uuid"];
                    visit.displayName = [object valueForKey:@"displayName"];
                    [visits addObject:visit];
                }
                completion(nil, visits);
            }
        }
        else
        {
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
        
        OrderedDictionary *dict = [[OrderedDictionary alloc] initWithObjectsAndKeys:vital.conceptUUID, @"concept", [self openMRSFormatStringWithDate:[NSDate date]], @"obsDatetime", patient.UUID, @"person", vital.value, @"value", nil];
        
        [obs addObject:dict];
    }
    
    NSDictionary *parameters = @{@"patient" : patient.UUID,
                                 @"encounterDatetime" : [self openMRSFormatStringWithDate:[NSDate date]],
                                 @"encounterType" : @"67a71486-1a54-468f-ac3e-7091a9a79584",
                                 @"obs" : obs,
                                 @"location" : location.UUID};
    
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter", host] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
        NSLog(@"Success capturing vitals");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error);
        NSLog(@"Failure, %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error, nil);
    }];
}
+ (void)getPatientListWithSearch:(NSString *)search completion:(void (^)(NSError *error, NSArray *patients))completion
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    
    [self cancelPreviousSearchOperations];
    
    delegate.currentSearchOperation = [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/patient?q=%@", host, [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Success, %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
//        NSLog(@"array: %@", results[@"results"]);
        
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure, %@", error);
        if (error.code == -1011 || error.code == -1002)
        {
            [OpenMRSAPIManager presentLoginController];
        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD popActivity];
//        });
        else
        {
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"Patient" inManagedObjectContext:appDelegate.managedObjectContext]];
            
            if (search.length != 0)
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@) OR (display CONTAINS[cd] %@) OR (display CONTAINS[cd] %@)", search, search, search];
                [fetchRequest setPredicate:predicate];
            }
            
            NSError *error;
            NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if (results.count > 0)
            {
                NSMutableArray *patients = [[NSMutableArray alloc] init];
                for (NSManagedObject *object in results) {
                    MRSPatient *patient = [[MRSPatient alloc] init];
                    patient.UUID = [object valueForKey:@"uuid"];
                    [patient updateFromCoreData];
                    [patients addObject:patient];
                }
                completion(nil, patients);
            }
            else
            {
                completion(error, nil);
            }
        }
    }];
}
+ (void)getDetailedDataOnPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, MRSPatient *detailedPatient))completion
{
    [SVProgressHUD show];
    
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/patient/%@?v=full", host, patient.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
//        NSLog(@"results: %@", results);
        
        MRSPatient *detailedPatient = [[MRSPatient alloc] init];
        detailedPatient.displayName = results[@"display"];
        detailedPatient.locationDisplay = results[@"location"][@"display"];
        if (((NSArray *)results[@"person"][@"addresses"]).count > 0)
        {
            detailedPatient.address1 = results[@"person"][@"addresses"][0][@"address1"];
            detailedPatient.address2 = results[@"person"][@"addresses"][0][@"address2"];
            detailedPatient.address3 = results[@"person"][@"addresses"][0][@"address3"];
            detailedPatient.address4 = results[@"person"][@"addresses"][0][@"address4"];
            detailedPatient.address5 = results[@"person"][@"addresses"][0][@"address5"];
            detailedPatient.address6 = results[@"person"][@"addresses"][0][@"address6"];
            detailedPatient.cityVillage = results[@"person"][@"addresses"][0][@"cityVillage"];
            detailedPatient.country = results[@"person"][@"addresses"][0][@"country"];
            detailedPatient.latitude = results[@"person"][@"addresses"][0][@"latitude"];
            detailedPatient.longitude = results[@"person"][@"addresses"][0][@"longitude"];
            detailedPatient.postalCode = results[@"person"][@"addresses"][0][@"postalCode"];
            detailedPatient.stateProvince = results[@"person"][@"addresses"][0][@"stateProvince"];
        }
        detailedPatient.birthdate = results[@"person"][@"birthdate"];
        detailedPatient.birthdateEstimated = results[@"person"][@"birthdateEstimated"];
        detailedPatient.causeOfDeath = results[@"person"][@"causeOfDeath"];
        detailedPatient.dead = ((int)results[@"person"][@"dead"] == 1);
        detailedPatient.gender = results[@"person"][@"gender"];
        detailedPatient.UUID = results[@"uuid"];
        detailedPatient.name = results[@"display"];
        detailedPatient.age = [results[@"person"][@"age"] stringValue];
        detailedPatient.hasDetailedInfo = YES;
        
        completion(nil, detailedPatient);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@""];
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure, %@", error);
        if (error.code == -1011 || error.code == -1002)
        {
            [OpenMRSAPIManager presentLoginController];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD popActivity];
        });
        
        if ([patient isInCoreData])
        {
            [patient updateFromCoreData];
            patient.hasDetailedInfo = YES;
            completion(nil, patient);
        }
        else
        {
            completion(error, nil);
        }
    }];
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
