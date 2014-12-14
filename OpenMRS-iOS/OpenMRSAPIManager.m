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
#import "MRSEncounter.h"
#import "SignInViewController.h"
#import "AppDelegate.h"
#import "MRSPatientIdentifierType.h"
#import "KeychainItemWrapper.h"
#import "SVProgressHUD.h"

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
//        NSLog(@"Error: %@", error);
        completion(NO);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"Login failed"];
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
    
    NSDictionary *parameters = @{@"names":@[@{@"givenName": person.name, @"familyName": person.familyName}],@"gender":person.gender,@"age":person.age};
    NSLog(@"Parameters: %@", parameters);
    
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
        NSLog(@"array: %@", results);
        
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
        completion(error, nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD popActivity];
        });
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
        completion(error, nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD popActivity];
        });
        NSLog(@"Failure, %@", error);
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
        completion(error, nil);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD popActivity];
//        });
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
        completion(error, nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD popActivity];
        });
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
