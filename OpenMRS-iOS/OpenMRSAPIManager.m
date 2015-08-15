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
#import "XMLDictionary.h"
#import "XForms.h"
#import "GDataXMLNode.h"
#import "XFormsParser.h"
#import "Constants.h"
#import <CoreData/CoreData.h>

@implementation OpenMRSAPIManager
+ (void)verifyCredentialsWithUsername:(NSString *)username password:(NSString *)password host:(NSString *)host completion:(void (^)(NSError *error))completion
{
    NSURL *hostUrl = [NSURL URLWithString:host];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/user", host] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Couldn't verify creds: %@", error);
        completion(error);
    }];
}

+ (NSURL *)setUpCredentialsLayer {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    
    return hostUrl;
}

+ (void)getVisitTypesWithCompletion:(void (^)(NSError *, NSArray *))completion
{
    NSURL *hostUrl = [self setUpCredentialsLayer];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/visittype", [hostUrl absoluteString]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
+ (void)addPatient:(NSDictionary *)parameters withIdentifier:(NSArray *)identifier completion:(void (^)(NSError *error, MRSPatient *createdPatient))completion
{
    [self addPerson:parameters completion:^(NSError *error, MRSPerson *createdPerson) {
        if (error != nil) {
            completion(error, nil);
        }
        else {
            NSURL *hostUrl = [self setUpCredentialsLayer];

            [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/patient", [hostUrl absoluteString]]
                                                             parameters:@ {@"person":createdPerson.UUID, @"identifiers":identifier} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
                NSLog(@"Results for details:\n\n%@", results);
                MRSPatient *patient = [MRSHelperFunctions fillPatientWithResponse:results];
                completion(nil, patient);
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"failure: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
                completion(error, nil);
            }];
        }
    }];
}
+ (void)addPerson:(NSDictionary *)parameters completion:(void (^)(NSError *error, MRSPerson *createdPerson))completion
{
    NSURL *hostUrl = [self setUpCredentialsLayer];
    /*NSDictionary *parameters;
    
    if ([MRSHelperFunctions isNull:person.name] || [MRSHelperFunctions isNull:person.familyName] || [MRSHelperFunctions isNull:person.gender]
        || [MRSHelperFunctions isNull:person.age]) {
        completion([[NSError alloc] init], nil);
    }
    //Not throwing exception when a value is null but it crash the app.
    @try {
        parameters = @ {@"names":@[@{@"givenName":person.name, @"familyName":person.familyName}],@"gender":person.gender,@"age":person.age};
        NSLog(@"Parameters: %@", parameters);
    }
    @catch (NSException *exception) {
        completion([[NSError alloc] init], nil);
        return;
    }*/
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/person", [hostUrl absoluteString]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        MRSPerson *createdPerson = [[MRSPerson alloc] init];
        createdPerson.UUID = results[@"uuid"];
        NSLog(@"Created patient: %@", results);
        completion(nil, createdPerson);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure adding patient: %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        completion(error, nil);
    }];
}
+ (void)getPatientIdentifierTypesWithCompletion:(void (^)(NSError *error, NSArray *types))completion
{
    NSURL *hostUrl = [self setUpCredentialsLayer];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/patientidentifiertype/?v=full", [hostUrl absoluteString]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSMutableArray *types = [[NSMutableArray alloc] init];
        for (NSDictionary *typeDict in results[@"results"]) {
            MRSPatientIdentifierType *type = [[MRSPatientIdentifierType alloc] init];
            type.UUID = typeDict[@"uuid"];
            type.display = typeDict[@"name"];
            type.typeDescription = typeDict[@"description"];
            if (![typeDict[@"retired"] boolValue]) {
                NSLog(@"uuid: %@", type.UUID);
                [types addObject:type];
            }
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
    NSURL *hostUrl = [self setUpCredentialsLayer];
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
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter", [hostUrl absoluteString]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    NSURL *hostUrl = [self setUpCredentialsLayer];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/encountertype", [hostUrl absoluteString]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    NSURL *hostUrl = [self setUpCredentialsLayer];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter/%@?v=full", [hostUrl absoluteString], encounter.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    NSURL *hostUrl = [self setUpCredentialsLayer];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter?patient=%@", [hostUrl absoluteString], patient.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSDictionary *visitDict in results[@"results"]) {
            MRSEncounter *visit = [[MRSEncounter alloc] init];
            visit.UUID = visitDict[@"uuid"];
            visit.displayName = visitDict[@"display"];
            [array addObject:visit];
        }
        completion(nil, array);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    NSURL *hostUrl = [self setUpCredentialsLayer];
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/visit?includeInactive=false&startIndex=%d&v=full",[hostUrl absoluteString],startIndex] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        for (NSDictionary *visit in results[@"results"]) {
            MRSVisit *newVisit = [[MRSVisit alloc] init];
            newVisit.displayName = visit[@"display"];
            newVisit.UUID = visit[@"uuid"];
            newVisit.startDateTime = visit[@"startDatetime"];
            
            if (![MRSHelperFunctions isNull:visit[@"location"]]) {
                MRSLocation *location = [[MRSLocation alloc] init];
                location.display = visit[@"location"][@"display"];
                location.UUID = visit[@"location"][@"uuid"];
                newVisit.location = location;
            }

            if (![MRSHelperFunctions isNull:visit[@"visitType"]]) {
                MRSVisitType *type = [[MRSVisitType alloc] init];
                type.uuid = visit[@"visitType"][@"uuid"];
                type.display = visit[@"visitType"][@"display"];
                newVisit.visitType = type;
            }

            newVisit.active = [MRSHelperFunctions isNull:visit[@"stopDatetime"]]?YES:NO;

            [activeVisits addObject:newVisit];
        }
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *failureReason) {
        NSLog(@"Failing reason: %@", failureReason);
        completion(failureReason);
    }];
    
}
+ (void)getVisitsForPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, NSArray *visits))completion
{
    NSURL *hostUrl = [self setUpCredentialsLayer];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/visit?v=full&patient=%@", [hostUrl absoluteString], patient.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    NSURL *hostUrl = [self setUpCredentialsLayer];
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
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter", [hostUrl absoluteString]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    NSURL *hostUrl = [self setUpCredentialsLayer];
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
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/visit", [hostUrl absoluteString]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error starting visit: %@", error);
        completion(error);
    }];
}

+ (void)stopVisit:(MRSVisit *)visit completion:(void (^)(NSError *))completion {
    NSURL *hostUrl = [self setUpCredentialsLayer];

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
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/visit/%@", [hostUrl absoluteString], visit.UUID] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure, %@", [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
        completion([[NSError alloc] init]);
    }];
}

+ (void)getLocationsWithCompletion:(void (^)(NSError *error, NSArray *locations))completion
{
    NSURL *hostUrl = [self setUpCredentialsLayer];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/location", [hostUrl absoluteString]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        NSURL *hostUrl = [self setUpCredentialsLayer];
        [self cancelPreviousSearchOperations];
        delegate.currentSearchOperation = [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/patient?q=%@", [hostUrl absoluteString], [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    NSURL *hostUrl = [self setUpCredentialsLayer];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/patient/%@?v=full", [hostUrl absoluteString], patient.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        MRSPatient *detailedPatient = [MRSHelperFunctions fillPatientWithResponse:results];
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
    NSURL *hostUrl = [self setUpCredentialsLayer];
    
    NSArray *personKeys = @[@"BirthDate", @"BirthDate Estimated", @"Dead", @"Cause Of Death"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                   @"gender": patient.gender
                                                                   }];
    for (NSString *propertyLabel in personKeys) {
        NSString *property = [MRSHelperFunctions formLabelToJSONLabel:propertyLabel];
        if ([property isEqualToString:@"dead"]){
            [parameters setValue:patient.dead?@"true":@"false" forKey:property];
            continue;
        }
        if (![MRSHelperFunctions isNull:[patient valueForKey:property]] && ![[patient valueForKey:property] isEqualToString:@""]){
            [parameters setValue:[patient valueForKey:property] forKey:property];
        }
    }
    NSLog(@"person parameters %@", parameters);
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/person/%@", [hostUrl absoluteString], patient.UUID] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        //NSLog(@"Person response: %@", results);
        [self EditNameForPatient:patient completion:completion];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Edit patient failed... with Error: %@", error);
        completion(error);
    }];
}


+ (void)EditNameForPatient:(MRSPatient *) patient completion:(void (^)(NSError *error))completion {
    NSURL *hostUrl = [self setUpCredentialsLayer];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                        @"givenName": patient.givenName?patient.givenName:[NSNull null],
                                                                                        @"familyName": patient.familyName?patient.familyName:[NSNull null]
                                                                                        }];
    if (![MRSHelperFunctions isNull:patient.middleName] && ![patient.middleName isEqualToString:@""])
        [parameters setValue:patient.middleName forKey:@"middleName"];
    if (![MRSHelperFunctions isNull:patient.familyName2] && ![patient.familyName2 isEqualToString:@""])
        [parameters setValue:patient.familyName2 forKey:@"familyName2"];
    
    //NSLog(@"Name parameters: %@", parameters);
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/person/%@/name/%@", [hostUrl absoluteString], patient.UUID, patient.preferredNameUUID] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        //NSLog(@"%@", results);
        [self EditAddressForPatient:patient completion:completion];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Edit name.. with Error: %@", error);
        completion(error);
    }];
}

+ (void)EditAddressForPatient:(MRSPatient *) patient completion:(void (^)(NSError *error))completion {
    NSURL *hostUrl = [self setUpCredentialsLayer];
    
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
        [[CredentialsLayer sharedManagerWithHost:hostUrl.host] POST:[NSString stringWithFormat:@"%@/ws/rest/v1/person/%@/address%@", [hostUrl absoluteString], patient.UUID, preferredAddressUUID] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
            //NSLog(@"%@", results);
            patient.preferredAddressUUID = results[@"uuid"];
            completion(nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Edit address... with Error: %@", error);
            completion(error);
        }];
    } else {
        completion(nil);
    }
}

#pragma mark - XForms APIs

+ (void)getXFormsList: (void (^)(NSArray *forms, NSError *error))completion {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    
    NSURL *hostUrl = [NSURL URLWithString:host];
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host andRequestSerializer:[AFXMLParserResponseSerializer new]] GET:[NSString stringWithFormat:@"%@/moduleServlet/xforms/xformDownload?target=xformslist&uname=%@&pw=%@", [hostUrl absoluteString], username, password] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        XMLDictionaryParser *parser  = [[XMLDictionaryParser alloc] init];
        NSDictionary *results = [parser dictionaryWithData:operation.responseData];
        NSMutableArray *forms = [[NSMutableArray alloc] init];
        
        if ([MRSHelperFunctions isNull:results[@"xform"]]) {
             completion(forms, nil);
        }
        /*
         * This is a check if the response contain only one object.
         * Because in this case the xforms element is a dictionary, but if
         * there is more than one the xforms element is an array.
         */
        else if ([results[@"xform"] isKindOfClass:[NSDictionary class]]) {
            XForms *xform = [[XForms alloc] init];
            xform.name = results[@"xform"][@"name"];
            xform.XFormsID = results[@"xform"][@"id"];
            [forms addObject:xform];
            completion(forms, nil);
        } else {
            for (NSDictionary *dict in results[@"xform"]) {
                XForms *xform = [[XForms alloc] init];
                xform.name = dict[@"name"];
                xform.XFormsID = dict[@"id"];
                [forms addObject:xform];
            }
            completion(forms, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

+ (void)getXformWithID:(NSString *)xformID andName:(NSString *)name Patient:(MRSPatient *)patient completion:(void (^)(XForms* form, NSError *error))completion {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    
    NSURL *hostUrl = [NSURL URLWithString:host];
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host andRequestSerializer:[AFXMLParserResponseSerializer new]]
     GET:[NSString stringWithFormat:@"%@/moduleServlet/xforms/xformDownload?target=xform&uname=%@&pw=%@&formId=%@&contentType=xml&excludeLayout=true", [hostUrl absoluteString], username, password, xformID]
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSError *error = nil;
         GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:operation.responseData error:&error];
         NSLog(@"%@", doc.rootElement);
         if (!error) {
             XForms *form = [XFormsParser parseXFormsXML:doc withID:xformID andName:name Patient:patient];
             completion(form, nil);
         } else {
             completion(nil, error);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         completion(nil, error);
     }];
}

+ (void)uploadXForms:(XForms *)form completion:(void (^)(NSError *error))completion {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];

    NSURL *hostUrl = [NSURL URLWithString:host];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/module/xforms/xformDataUpload.form?uname=%@&pw=%@", [hostUrl absoluteString], username, password]]];
    [request setHTTPBody:[form getModelFromDocument]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Accept"];

    NSOperation *operation = [[CredentialsLayer sharedManagerWithHost:hostUrl.host andRequestSerializer:[AFXMLParserResponseSerializer new]] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Upload XForms Sucess %@", operation.request.HTTPBody);
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"^%@", [error userInfo]);
        /* Yea that happens... */
        if (operation.response.statusCode == 201 ||
            operation.response.statusCode == 200) {
            completion(nil);
        }
        NSXMLParser *parser = operation.responseObject;
        [parser parse];
        NSLog(@"Upload XForm Failure %@.", operation.responseString);
        completion(error);
    }];

    [[[CredentialsLayer sharedManagerWithHost:hostUrl.host andRequestSerializer:[AFXMLParserResponseSerializer new]]
      operationQueue] addOperation:operation];
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
