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

- (void)testMatrixTranslate3 {
    gks_create_translation_matrix_3(A, B, C, m);
    XCTAssertEqual(m[0][3], A);
    XCTAssertEqual(m[1][3], B);
    XCTAssertEqual(m[2][3], C);
    
    gks_create_translation_matrix_3(C, B, A, m);
    XCTAssertEqual(m[0][3], C);
    XCTAssertEqual(m[1][3], B);
    XCTAssertEqual(m[2][3], A);
}

- (void)testAccumulatedScale {

    gks_accumulate_scaling_matrix_3(2.0, 3.0, 4.0, m);
    XCTAssertEqualWithAccuracy(2.0, m[0][0], 0.001);
    XCTAssertEqualWithAccuracy(3.0, m[1][1], 0.001);
    XCTAssertEqualWithAccuracy(4.0, m[2][2], 0.001);
    
    gks_accumulate_scaling_matrix_3(1.5, 2.0, 2.5, m);
    XCTAssertEqualWithAccuracy(3.0, m[0][0], 0.001);
    XCTAssertEqualWithAccuracy(6.0, m[1][1], 0.001);
    XCTAssertEqualWithAccuracy(10.0, m[2][2], 0.001);

}

- (void)testAccumulatedRotateX {
    gks_accumulate_x_rotation_matrix_3(theta, m);

    XCTAssertEqualWithAccuracy(m[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(m[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(m[2][1], 0.259, 0.001);
    XCTAssertEqualWithAccuracy(m[1][2], -0.259, 0.001);
    XCTAssertEqualWithAccuracy(m[0][3], 0.0, 0.001);
    
    gks_accumulate_x_rotation_matrix_3(theta, m);
    XCTAssertEqualWithAccuracy(m[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(m[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(m[2][1], 0.5, 0.001);
    XCTAssertEqualWithAccuracy(m[1][2], -0.5, 0.001);
    XCTAssertEqualWithAccuracy(m[0][3], 0.0, 0.001);
    
    gks_accumulate_x_rotation_matrix_3(theta, m);
    XCTAssertEqualWithAccuracy(m[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 0.707, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 0.707, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(m[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(m[2][1], 0.707, 0.001);
    XCTAssertEqualWithAccuracy(m[1][2], -0.707, 0.001);
    XCTAssertEqualWithAccuracy(m[0][3], 0.0, 0.001);

    gks_accumulate_x_rotation_matrix_3(3*theta, m);
    XCTAssertEqualWithAccuracy(m[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(m[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(m[2][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[1][2], -1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[0][3], 0.0, 0.001);
    
}

- (void)testAccumulatedRotateY {
    gks_accumulate_y_rotation_matrix_3(theta, m);
    XCTAssertEqualWithAccuracy(m[0][0], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(m[2][0], -0.259, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[0][2], 0.259, 0.001);
    
    gks_accumulate_y_rotation_matrix_3(theta, m);
    XCTAssertEqualWithAccuracy(m[0][0], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(m[2][0], -0.5, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[0][2], 0.5, 0.001);

}

- (void)testAccumulatedRotateZ {
    gks_accumulate_z_rotation_matrix_3(theta, m);
    XCTAssertEqualWithAccuracy(m[0][0], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);
    
    XCTAssertEqualWithAccuracy(m[1][0], 0.259, 0.001);
    XCTAssertEqualWithAccuracy(m[0][1], -0.259, 0.001);
    
    gks_accumulate_z_rotation_matrix_3(theta, m);
    XCTAssertEqualWithAccuracy(m[0][0], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(m[1][1], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(m[2][2], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(m[3][3], 1.0, 0.001);
    
    XCTAssertEqualWithAccuracy(m[1][0], 0.5, 0.001);
    XCTAssertEqualWithAccuracy(m[0][1], -0.5, 0.001);

}

- (void)testAccumulateTranslate {
    gks_accumulate_translation_matrix_3(A, B, C, m);
    XCTAssertEqual(m[0][3], A);
    XCTAssertEqual(m[1][3], B);
    XCTAssertEqual(m[2][3], C);
    
    gks_accumulate_translation_matrix_3(C, B, A, m);
    XCTAssertEqual(m[0][3], A+C);
    XCTAssertEqual(m[1][3], B+B);
    XCTAssertEqual(m[2][3], C+A);
}

- (void)testCopyMatrix3 {
    Matrix_4 s;
    Matrix_4 M = {
        {1.0, 2.0,  3.0, -4.0},
        {2.0, 4.0,  6.0,  8.0},
        {3.0, 6.0, -2.0,  1.0},
        {0.0, 0.0,  0.0,  1.0}
    };
    
    gks_copy_matrix_3(m, s);
    XCTAssertEqual(s[0][0], 1.0, @"Identity 1.0 not in diagonal");
    XCTAssertEqual(s[1][1], 1.0, @"Identity 1.0 not in diagonal");
    XCTAssertEqual(s[2][2], 1.0, @"Identity 1.0 not in diagonal");
    XCTAssertEqual(s[3][3], 1.0, @"Identity 1.0 not in diagonal");
    
    bool is_identity = isIdentity_3(s);
    XCTAssertTrue(is_identity, @"Identity check failed");
    
    s[0][2] = 3.0;
    is_identity = isIdentity_3(s);
    XCTAssertFalse(is_identity, @"Identity check failed");

    gks_copy_matrix_3(M, m);
    XCTAssertEqualWithAccuracy(1.0, m[0][0], 0.001);
    XCTAssertEqualWithAccuracy(-2.0, m[2][2], 0.001);
    XCTAssertEqualWithAccuracy(3.0, m[0][2], 0.001);
}

- (void)testTransformPoint3 {
    Gpt_3 p0 = {1.0, 1.0, 1.0};
    Gpt_3 p1;
    
    gks_create_y_rotation_matrix_3(theta, m);
    gks_transform_point_3(m, &p0, &p1);

    XCTAssertEqualWithAccuracy(p1.x, 0.966 + 0.259, 0.001);
    XCTAssertEqualWithAccuracy(p1.y, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(p1.z, 0.966 - 0.259, 0.001);
    
    gks_accumulate_y_rotation_matrix_3(theta, m);
    gks_transform_point_3(m, &p0, &p1);

    XCTAssertEqualWithAccuracy(p1.x, 0.866 + 0.5, 0.001);
    XCTAssertEqualWithAccuracy(p1.y, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(p1.z, 0.866 - 0.5, 0.001);

    //ac_scale_3(2.0, 2.0, 2.0, m);

    XCTAssertEqualWithAccuracy(p0.x, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(p0.y, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(p0.z, 1.0, 0.001);
}

- (void)testTransformVector4 {
    Vector_4 v = {1.0, 1.0, 1.0, 1.0};
    Vector_4 vn;
    
    gks_create_y_rotation_matrix_3(theta, m);
    gks_transform_vector_4(m, v, vn);
    XCTAssertEqualWithAccuracy(vn[0], 0.966 - 0.259, 0.001);
    XCTAssertEqualWithAccuracy(vn[1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(vn[2], 0.966 + 0.259, 0.001);
    XCTAssertEqualWithAccuracy(vn[3], 1.0, 0.001);
}

- (void)testPlaneEquation {
    Gpt_3 p1 = {0.0, 0.0, 0.0};
    Gpt_3 p2 = {1.0, 0.0, 0.0};
    Gpt_3 p3 = {1.0, 1.0, 0.0};
    Gpt_3 p4 = {0.0, 1.0, 0.0};
    Gpt_3 p5 = {0.0, 0.0, 1.0};
    Gpt_3 p6 = {1.0, 0.0, 1.0};
    Gpt_3 p7 = {1.0, 1.0, 1.0};
    Gpt_3 p8 = {0.0, 1.0, 1.0};
    
    Gpt_3 testPlane = {0.0, 0.0, 0.0, 0.0};    // this is weird using a point type for a plane type.
    
    // polygon 4
    gks_plane_equation_3(p2, p3, p7, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.x, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.y, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.z, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.w, -1.0, 0.001);
    
    // polygon 1
    gks_plane_equation_3(p3, p2, p1, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.x, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.y, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.z, -1.0, 0.001);
    gks_plane_equation_3(p1, p4, p3, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.x, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.y, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.z, -1.0, 0.001);

    // polygon 6
    gks_plane_equation_3(p3, p4, p8, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.x, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.y, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.z, 0.0, 0.001);
    
    // polygon 3
    gks_plane_equation_3(p8, p4, p1, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.x, -1.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.y, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.z, 0.0, 0.001);
    
    // polygon 2
    gks_plane_equation_3(p5, p6, p7, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.x, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.y, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.z, 1.0, 0.001);
    
    // polygon 5
    gks_plane_equation_3(p1, p2, p6, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.x, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.y, -1.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.z, 0.0, 0.001);
    
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


// MARK: MESH

- (void)testMeshCube {
    Object_3 *cubeObj;
    
    cubeObj = CubeMesh();
    XCTAssert(cubeObj != NULL, @"Cube mesh does not exist");
    XCTAssertEqual(cubeObj->vertnum, 8);
    XCTAssertEqual(cubeObj->polynum, 6);
    
    // vertex 0
    XCTAssertEqual(cubeObj->vertices[0].x, 0.0);
    XCTAssertEqual(cubeObj->vertices[0].y, 0.0);
    XCTAssertEqual(cubeObj->vertices[0].z, 0.0);
    // vertex 3 {0.0, 1.0, 0.0},
    XCTAssertEqual(cubeObj->vertices[3].x, 0.0);
    XCTAssertEqual(cubeObj->vertices[3].y, 1.0);
    XCTAssertEqual(cubeObj->vertices[3].z, 0.0);
    // vertex 6 {1.0, 1.0, 1.0}
    XCTAssertEqual(cubeObj->vertices[6].x, 1.0);
    XCTAssertEqual(cubeObj->vertices[6].y, 1.0);
    XCTAssertEqual(cubeObj->vertices[6].z, 1.0);
    
}


@end
