//
//  GeKoSTests.m
//  GeKoSTests
//
//  Created by Alex Popadich on 11/30/21.
//

#import <XCTest/XCTest.h>
#import "GKSConstants.h"

@interface GeKoSTests : XCTestCase

@end

@implementation GeKoSTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testUserDefaults {

    NSNumber* lookAtFlag = [[NSUserDefaults standardUserDefaults] valueForKey:XSUseLookAtPoint];
    XCTAssertEqual([lookAtFlag boolValue], NO);
    
    NSNumber* perpectiveDistance = [[NSUserDefaults standardUserDefaults] valueForKey:GKSPerspectiveDistance];
    XCTAssertEqual([perpectiveDistance floatValue], 1.0);
    
    NSNumber* viewPortWidth = [[NSUserDefaults standardUserDefaults] valueForKey:GKSViewWidth];
    XCTAssertEqual([viewPortWidth floatValue], 400.0);
    
}

@end
