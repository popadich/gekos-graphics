//
//  GKSMatrixTests.m
//  GeKoSTests
//
//  Created by Alex Popadich on 12/1/21.
//

#import <XCTest/XCTest.h>
#include "../GeKoS/gks/gks.h"

@interface GKSMatrixTests : XCTestCase

@end

@implementation GKSMatrixTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

bool isIdentity_2(Matrix_3 matrix)
{
    bool identityTrue = true;
    for (int i=0; i<3; i++) {
        for (int j=0; j<3; j++) {
            if (i==j) {
                if (matrix[i][j] != 1.0) {
                    identityTrue = false;
                }
            } else {
                if (matrix[i][j] != 0.0) {
                    identityTrue = false;
                }
            }
        }
    }
    return identityTrue;
}

bool isIdentity_3(Matrix_4 matrix)
{
    bool identityTrue = true;
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            if (i==j) {
                if (matrix[i][j] != 1.0) {
                    identityTrue = false;
                }
            } else {
                if (matrix[i][j] != 0.0) {
                    identityTrue = false;
                }
            }
        }
    }
    return identityTrue;
}

- (void)testIdentityMatrix2 {
    Matrix_3 im;
    
    gks_set_identity_matrix_2(im);
    XCTAssertEqual(im[0][0], 1.0, @"Not 1.0 on diagonal");
    XCTAssertEqual(im[0][1], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[0][2], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[1][0], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[1][1], 1.0, @"Not 1.0 on diagonal");
    XCTAssertEqual(im[1][2], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[2][0], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[2][1], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[2][2], 1.0, @"Not 1.0 on diagonal");
    
    bool is_identity = isIdentity_2(im);
    XCTAssertTrue(is_identity);
}

- (void)testIdentityMatrix3 {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    Matrix_4 im;
    
    gks_set_identity_matrix_3(im);
    XCTAssertEqual(im[0][0], 1.0, @"Not 1.0 on diagonal");
    XCTAssertEqual(im[0][1], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[0][2], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[0][3], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[1][0], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[1][1], 1.0, @"Not 1.0 on diagonal");
    XCTAssertEqual(im[1][2], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[1][3], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[2][0], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[2][1], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[2][2], 1.0, @"Not 1.0 on diagonal");
    XCTAssertEqual(im[2][3], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[3][0], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[3][1], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[3][2], 0.0, @"Not 0.0 off diagonal");
    XCTAssertEqual(im[3][3], 1.0, @"Not 1.0 on diagonal");
    
    bool is_identity = isIdentity_3(im);
    XCTAssertTrue(is_identity);
}

@end
