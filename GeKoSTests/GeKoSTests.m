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


- (void)testPerformanceSceneCreation {
    // This is an example of a performance test case.
    GKSDocument* aDoc = [[GKSDocument alloc] init];
    XCTAssertNotNil(aDoc);

    [aDoc makeWindowControllers];
    NSArray* controllerArr = (NSArray *)[aDoc windowControllers];

    GKSWindowController* windowController = [controllerArr objectAtIndex:0];
    XCTAssertNotNil(windowController.window);
    
    XCTAssert(windowController.contentViewController);
    
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        GKSContent *content = windowController.contentViewController.representedObject;
        GKSScene *scene = content.theScene;
        for (int j=0; j<60; j++) {
            for (int i=-30; i<31; i++) {
                GKSmesh_3 *sphere = SphereMesh();
                GKSvector3d location = GKSMakeVector(2.0 * i, i%2, -2.0 * (1 + j));
                GKSvector3d rotation = GKSMakeVector(0.0, 0.0, 0.0);
                GKSvector3d scale = GKSMakeVector(1.0, 1.0, 1.0);
                
                GKS3DObject *object3D = [[GKS3DObject alloc] initWithMesh:sphere atLocation:location withRotation:rotation andScale:scale];
//                [object3D locateX:2.0 * i Y:i%2 Z: -2.0 * (1 + j)];

                [scene add3DObject:object3D];
            }
        }
        for (int j=0; j<60; j++) {
            for (int i=-30; i<31; i++) {
                [scene deleteLast3DObject];
            }
        }
    }];
}

- (void)testPerformanceSceneLookAt {
    // This is an example of a performance test case.
    GKSDocument* aDoc = [[GKSDocument alloc] init];
    XCTAssertNotNil(aDoc);

    [aDoc makeWindowControllers];
    NSArray* controllerArr = (NSArray *)[aDoc windowControllers];

    GKSWindowController* windowController = [controllerArr objectAtIndex:0];
    XCTAssertNotNil(windowController.window);
    
    GKSContentViewController *contentController = (GKSContentViewController *)windowController.contentViewController;
    XCTAssertNotNil(contentController);
    
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        GKSContent *content = windowController.contentViewController.representedObject;
        GKSScene *scene = content.theScene;
        GKSCameraRep *camera = content.theScene.camera;
        
        for (int j=0; j<60; j++) {
            for (int i=-30; i<31; i++) {
                GKSmesh_3 *sphere = SphereMesh();
                GKSvector3d location = GKSMakeVector(2.0 * i, i%2, -2.0 * (1 + j));
                GKSvector3d rotation = GKSMakeVector(0.0, 0.0, 0.0);
                GKSvector3d scale = GKSMakeVector(1.0, 1.0, 1.0);
                
                GKS3DObject *object3D = [[GKS3DObject alloc] initWithMesh:sphere atLocation:location withRotation:rotation andScale:scale];
                
                [scene add3DObject:object3D];
            }
        }
        
        GKSvector3d look = GKSMakeVector(1.0, 1.0, 0.0);
        [camera cameraSetLookAt:look];
      
        [contentController.cameraViewController cameraSetProjectionTypeG];
        [contentController.cameraViewController camerSetViewLookAtG];
        [scene transformAllObjects];
        
        for (int j=0; j<60; j++) {
            for (int i=-30; i<31; i++) {
                [scene deleteLast3DObject];
            }
        }
    }];
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
    GKSContent *content = windowController.contentViewController.representedObject;
    
    XCTAssertNotNil(content);

}

@end
