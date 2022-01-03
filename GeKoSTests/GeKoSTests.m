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

    NSWindowController* controller = [controllerArr objectAtIndex:0];
    XCTAssertNotNil(controller.window);
    
    XCTAssertNotNil(aDoc.noContentLabel);
    
    NSColor* aColor = aDoc.backColor;
    XCTAssertEqual(aColor.redComponent, 0.066);
    XCTAssertEqual(aColor.greenComponent, 0.510);
    XCTAssertEqual(aColor.blueComponent, 0.910);
    
    aColor = aDoc.lineColor;
    XCTAssertEqual(aColor.redComponent, 0.9);
    XCTAssertEqual(aColor.greenComponent, 0.9);
    XCTAssertEqual(aColor.blueComponent, 0.9);
    
    aColor = aDoc.fillColor;
    XCTAssertEqual(aColor.redComponent, 1.0);
    XCTAssertEqual(aColor.greenComponent, 1.0);
    XCTAssertEqual(aColor.blueComponent, 0.8);

}

@end
