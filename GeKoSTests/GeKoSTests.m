//
//  GeKoSTests.m
//  GeKoSTests
//
//  Created by Alex Popadich on 11/30/21.
//

#import <XCTest/XCTest.h>
#import "GKSConstants.h"
#import "GKSAppDelegate.h"
#import "GKSDocument.h"
#import "GKSWindowController.h"
#import "GKSContentViewController.h"


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

    NSNumber* lookAtFlag = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefLookAtPoint];
    XCTAssertEqual([lookAtFlag boolValue], NO);
    
    NSNumber* projectionType = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefProjectionType];
    XCTAssertEqual([projectionType integerValue], 1);
    
    NSNumber* perpectiveDistance = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefPerspectiveDistance];
    XCTAssertEqual([perpectiveDistance floatValue], 1.0);
    
    NSNumber* viewPortWidth = [[NSUserDefaults standardUserDefaults] valueForKey:gksPrefViewWidth];
    XCTAssertEqual([viewPortWidth floatValue], 400.0);
    
}

- (void)testAppDelegateInit {
    // get app delegate
    GKSAppDelegate* gksAppDelegate = NSApplication.sharedApplication.delegate;
    XCTAssertNotNil(gksAppDelegate);

}

- (void)testDocumentInit {
    GKSDocument* aDoc = [[GKSDocument alloc] init];
    XCTAssertNotNil(aDoc);

    [aDoc makeWindowControllers];
    NSArray* controllerArr = (NSArray *)[aDoc windowControllers];

    GKSWindowController* windowController = [controllerArr objectAtIndex:0];
    XCTAssertNotNil(windowController.window);
    
    XCTAssert(windowController.contentViewController);

}

@end
