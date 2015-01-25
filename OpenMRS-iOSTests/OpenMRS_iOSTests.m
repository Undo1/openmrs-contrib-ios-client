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

@interface OpenMRS_iOSTests : XCTestCase

@end

@implementation OpenMRS_iOSTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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
