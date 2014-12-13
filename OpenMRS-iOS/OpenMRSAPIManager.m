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
#import "MRSLocation.h"
#import "MRSEncounter.h"
#import "SignInViewController.h"
#import "AppDelegate.h"
#import "KeychainItemWrapper.h"

@implementation OpenMRSAPIManager
+ (void)verifyCredentialsWithUsername:(NSString *)username password:(NSString *)password host:(NSString *)host completion:(void (^)(BOOL success))completion
{
    NSURL *hostUrl = [NSURL URLWithString:host];
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/user", host] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
        completion(NO);
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
+ (void)getEncountersForPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, NSArray *encounters))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSURL *hostUrl = [NSURL URLWithString:host];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] setUsername:username andPassword:password];
    
    [[CredentialsLayer sharedManagerWithHost:hostUrl.host] GET:[NSString stringWithFormat:@"%@/ws/rest/v1/encounter?patient=%@", host, patient.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSLog(@"array: %@", results);
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (NSDictionary *visitDict in results[@"results"]) {
            MRSEncounter *visit = [[MRSEncounter alloc] init];
            visit.UUID = visitDict[@"uuid"];
            visit.displayName = visitDict[@"display"];
            [array addObject:visit];
        }
        completion(nil, array);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error, nil);
        NSLog(@"Failure, %@", error);
    }];
}
+ (void)getVisitsForPatient:(MRSPatient *)patient completion:(void (^)(NSError *error, NSArray *visits))completion
{
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error, nil);
        NSLog(@"Failure, %@", error);
    }];
}
+ (void)getLocationsWithCompletion:(void (^)(NSError *error, NSArray *locations))completion
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure, %@", error);
        if (error.code == -1011 || error.code == -1002)
        {
            [OpenMRSAPIManager presentLoginController];
        }
        completion(error, nil);
    }];
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure, %@", error);
        if (error.code == -1011 || error.code == -1002)
        {
            [OpenMRSAPIManager presentLoginController];
        }
        completion(error, nil);
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
