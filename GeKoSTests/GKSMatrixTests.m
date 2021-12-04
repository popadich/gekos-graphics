//
//  GKSMatrixTests.m
//  GeKoSTests
//
//  Created by Alex Popadich on 12/1/21.
//

#import <XCTest/XCTest.h>
#include "../GeKoS/gks/gks.h"

@interface GKSMatrixTests : XCTestCase {
    Gfloat A;
    Gfloat B;
    Gfloat C;
    Gfloat theta;
    Matrix_4 m;
}
@end

@implementation GKSMatrixTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    A = 20.0;
    B = 10.0;
    C = 7.0;
    theta = DEG_TO_RAD * 15.0;

    m[0][0] = m[1][1] = m[2][2] = m[3][3] = 1.0;
    m[0][1] = m[0][2] = m[0][3] = 0.0;
    m[1][0] = m[1][2] = m[1][3] = 0.0;
    m[2][0] = m[2][1] = m[2][3] = 0.0;
    m[3][0] = m[3][1] = m[3][2] = 0.0;
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

- (void)testMatrixScale3 {
    gks_create_scaling_matrix_3(A, B, C, m);
    XCTAssertEqual(m[0][0], A, @"Scaled in X by 20.0");
    XCTAssertEqual(m[1][1], B, @"Scaled in Y by 10.0");
    XCTAssertEqual(m[2][2], C);
    XCTAssertEqual(m[3][3], 1.0);
    
    gks_create_scaling_matrix_3(C, B, A, m);
    XCTAssertEqual(m[0][0], C, @"Scaled in X by 5.0");
    XCTAssertEqual(m[1][1], B, @"Scaled in Y by 10.0");
    XCTAssertEqual(m[2][2], A);
    XCTAssertEqual(m[3][3], 1.0);
}


- (void)testCreateRotate3x {
    gks_create_x_rotation_matrix_3(theta, m);
    XCTAssertEqualWithAccuracy(m[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);
    
    XCTAssertEqualWithAccuracy(m[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(m[2][1], 0.259, 0.001);
    XCTAssertEqualWithAccuracy(m[1][2], -0.259, 0.001);
    XCTAssertEqualWithAccuracy(m[0][3], 0.0, 0.001);
    
    gks_create_x_rotation_matrix_3(theta, m);
    XCTAssertEqualWithAccuracy(m[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);
    
    XCTAssertEqualWithAccuracy(m[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(m[2][1], 0.259, 0.001);
    XCTAssertEqualWithAccuracy(m[1][2], -0.259, 0.001);
    XCTAssertEqualWithAccuracy(m[0][3], 0.0, 0.001);
}

- (void)testCreateRotate3y {
    gks_create_y_rotation_matrix_3(theta, m);
    XCTAssertEqualWithAccuracy(m[0][0], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);
}


- (void)testCreateRotate3z {
    gks_create_z_rotation_matrix_3(theta, m);
    XCTAssertEqualWithAccuracy(m[0][0], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);
}


// vector tests
- (void)testVecDotProduct {
    Gpt_3 A = {1.0, 2.0, 3.0, 0.0};
    Gpt_3 B = {2.0, 0.0, 1.0, 0.0};
    float scalar_value = 0.0;
    
    scalar_value = vecdot((Gpt_3_Ptr)&A, (Gpt_3_Ptr)&B);
    XCTAssertEqualWithAccuracy(scalar_value, 5.0, 0.001);
}

- (void)testVecSub {
    Gpt_3 va = {1.0, 2.0, 3.0, 1.0};
    Gpt_3 vb = {2.0, 0.0, 1.0, 0.0};
    Gpt_3 vc;
    
    vecsub((Gpt_3_Ptr)&va, (Gpt_3_Ptr)&vb, (Gpt_3_Ptr)&vc);
    XCTAssertEqualWithAccuracy(vc.x, -1.0, 0.001);
    XCTAssertEqualWithAccuracy(vc.y, 2.0, 0.001);
    XCTAssertEqualWithAccuracy(vc.z, 2.0, 0.001);
}

- (void)testVecAdd {
    GVector va = {1.0, 2.0, 3.0, 1.0};
    GVector vb = {2.0, 0.0, 1.0, 0.0};
    GVector vc = {0.0, 0.0, 0.0, 0.0};
    
    vecadd(va, vb, &vc);
    XCTAssertEqualWithAccuracy(vc.vecpos.x, 3.0, 0.001);
    XCTAssertEqualWithAccuracy(vc.vecpos.y, 2.0, 0.001);
    XCTAssertEqualWithAccuracy(vc.vecpos.z, 4.0, 0.001);
}

- (void)testVecScale {
    Gpt_3 va = {1.0, 2.0, 3.0, 0.0};
    Gpt_3 vc;
    
    vecscale(1.5, (Gpt_3_Ptr)&va, (Gpt_3_Ptr)&vc);
    XCTAssertEqualWithAccuracy(vc.x, 1.5, 0.001);
    XCTAssertEqualWithAccuracy(vc.y, 3.0, 0.001);
    XCTAssertEqualWithAccuracy(vc.z, 4.5, 0.001);
}

- (void)testVecProduct {
    Gpt_3 A = {1.0, 2.0, 3.0, 0.0};
    Gpt_3 B = {2.0, 0.0, 1.0, 0.0};
    Gpt_3 C = {0.0, 0.0, 0.0, 0.0};
    
    vecprod((Gpt_3_Ptr)&A, (Gpt_3_Ptr)&B, (Gpt_3_Ptr)&C);
    XCTAssertEqualWithAccuracy(C.x, 2.0, 0.001);
    XCTAssertEqualWithAccuracy(C.y, 5.0, 0.001);
    XCTAssertEqualWithAccuracy(C.z, -4.0, 0.001);
}

- (void)testVecNormal {
    Gpt_3 va = {1.0, 2.0, 3.0, 0.0};
    Gpt_3 vc;
    
    vecnormal((Gpt_3_Ptr)&va, (Gpt_3_Ptr)&vc);
    XCTAssertEqualWithAccuracy(vc.x, 0.267261241912424, 0.001, @"1/sqrt(14)");
    XCTAssertEqualWithAccuracy(vc.y, 0.534522483824849, 0.001);
    XCTAssertEqualWithAccuracy(vc.z, 0.801783725737273, 0.001);
}


@end
