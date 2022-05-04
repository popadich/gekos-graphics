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
#import "GKSContent.h"
#import "GKSCameraRep.h"


@interface GeKoSTests : XCTestCase

@end

@implementation GeKoSTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

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
    GKSContent *content = windowController.contentViewController.representedObject;
    
    XCTAssertNotNil(content);

}

@end
