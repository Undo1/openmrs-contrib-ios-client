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

@interface OpenMRS_iOSTests : XCTestCase

@end

@implementation OpenMRS_iOSTests

- (void)setUp {
    [super setUp];
    
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
    [wrapper setObject:@"admin123" forKey:(__bridge id)(kSecValueData)];
    [wrapper setObject:@"admin" forKey:(__bridge id)(kSecAttrAccount)];
    [wrapper setObject:@"http://demo.openmrs.org/openmrs" forKey:(__bridge id)(kSecAttrService)];
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
@end
