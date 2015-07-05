//
//  OpenMRS_iOSTests.m
//  OpenMRS-iOSTests
//
//  Created by Parker Erway on 12/2/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OpenMRSAPIManager.h"
#import "KeychainItemWrapper.h"
#import "OHHTTPStubs.h"
#import "SyncingEngine.h"


@interface OpenMRS_iOSTests : XCTestCase

@property (nonatomic, strong) KeychainItemWrapper *wrapper;

@end

@implementation OpenMRS_iOSTests

- (void)setUp {
    [super setUp];
    
    self.wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    [self.wrapper setObject:@"Admin123" forKey:(__bridge id)(kSecValueData)];
    [self.wrapper setObject:@"admin" forKey:(__bridge id)(kSecAttrAccount)];
    [self.wrapper setObject:@"http://demo.openmrs.org/openmrs" forKey:(__bridge id)(kSecAttrService)];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)testSearchResults {
    XCTestExpectation *expectation = [self expectationWithDescription:@"login"];
    
    [OpenMRSAPIManager getPatientListWithSearch:@"Mark" online:YES completion:^(NSError *error, NSArray *patients) {
        XCTAssert(!error && patients.count > 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}
- (void)testAdminLogin {
    [OpenMRSAPIManager logout];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"login"];
    
    [OpenMRSAPIManager verifyCredentialsWithUsername:@"admin" password:@"Admin123" host:@"http://demo.openmrs.org/openmrs" completion:^(BOOL success) {
        XCTAssert(success);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}
- (void)testNurseLogin {
    [OpenMRSAPIManager logout];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"login"];
    
    [OpenMRSAPIManager verifyCredentialsWithUsername:@"nurse" password:@"Nurse123" host:@"http://demo.openmrs.org/openmrs" completion:^(BOOL success) {
        XCTAssert(success);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}
- (void)testClerkLogin {
    [OpenMRSAPIManager logout];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"login"];
    
    [OpenMRSAPIManager verifyCredentialsWithUsername:@"clerk" password:@"Clerk123" host:@"http://demo.openmrs.org/openmrs" completion:^(BOOL success) {
        XCTAssert(success);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}
- (void)testDoctorLogin {
    [OpenMRSAPIManager logout];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"login"];
    
    [OpenMRSAPIManager verifyCredentialsWithUsername:@"doctor" password:@"Doctor123" host:@"http://demo.openmrs.org/openmrs" completion:^(BOOL success) {
        XCTAssert(success);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}
- (void)testSyncingEngine {
    //given
    MRSPatient *patient = [[MRSPatient alloc] init];
    patient.UUID = @"uuid";
    patient.preferredNameUUID = @"nameuuid";
    patient.gender = @"M";
    patient.givenName = @"testG";
    patient.familyName = @"testF";
    patient.upToDate = NO;
    [patient saveToCoreData];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"demo.openmrs.org"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
        NSDictionary* obj = @{ @"stubbed": @"true"};
        return [OHHTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];
    
    //when
    XCTestExpectation *expectation = [self expectationWithDescription:@"syned"];
    [[SyncingEngine sharedEngine] updateExistingOutOfDatePatients:^(NSError *error) {
        XCTAssertTrue(error==nil);
        
        [expectation fulfill];
    }];
    
    //then
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        
        [patient updateFromCoreData];
        BOOL value = patient.upToDate;
        [patient cascadingDelete];
        XCTAssertTrue(value);
    }];
}
@end
