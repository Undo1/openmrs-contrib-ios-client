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
#import "SignInViewController.h"
#import "AppDelegate.h"
#import "KeychainItemWrapper.h"

@implementation OpenMRSAPIManager
+ (void)verifyCredentialsWithUsername:(NSString *)username password:(NSString *)password host:(NSString *)host completion:(void (^)(BOOL success))completion
{
    [[CredentialsLayer sharedManagerWithHost:host] setUsername:username andPassword:password];
    
    [[CredentialsLayer sharedManagerWithHost:host] GET:[NSString stringWithFormat:@"openmrs/ws/rest/v1/user"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completion(NO);
    }];
}
+ (void)getPatientListWithSearch:(NSString *)search completion:(void (^)(NSError *error, NSArray *patients))completion
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    NSString *host = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    
    [[CredentialsLayer sharedManagerWithHost:host] setUsername:username andPassword:password];
    
    [[CredentialsLayer sharedManagerWithHost:host] GET:[NSString stringWithFormat:@"openmrs/ws/rest/v1/patient?q=%@", search] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success, %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSLog(@"array: %@", results[@"results"]);
        
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
    NSString *username = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    
    [[CredentialsLayer sharedManagerWithHost:host] setUsername:username andPassword:password];
    
    [[CredentialsLayer sharedManagerWithHost:host] GET:[NSString stringWithFormat:@"openmrs/ws/rest/v1/patient/%@?v=full", patient.UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success, %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
        NSLog(@"results: %@", results);
        
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
@end
