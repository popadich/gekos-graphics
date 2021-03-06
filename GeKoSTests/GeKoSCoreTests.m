//
//  GKSMatrixTests.m
//  GeKoSTests
//
//  Created by Alex Popadich on 12/1/21.
//

#import <XCTest/XCTest.h>
#include "gks.h"

#define epsilon  0.001

@interface GeKoSCoreTests : XCTestCase {
    GKSfloat A;
    GKSfloat B;
    GKSfloat C;
    GKSfloat theta;
    GKSmatrix_3 im;
}
@end

@implementation GeKoSCoreTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    A = 20.0;
    B = 10.0;
    C = 7.0;
    theta = DEG_TO_RAD * 15.0;

    im[0][0] = im[1][1] = im[2][2] = im[3][3] = 1.0;
    im[0][1] = im[0][2] = im[0][3] = 0.0;
    im[1][0] = im[1][2] = im[1][3] = 0.0;
    im[2][0] = im[2][1] = im[2][3] = 0.0;
    im[3][0] = im[3][1] = im[3][2] = 0.0;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

bool isIdentity_2(GKSmatrix_2 matrix)
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

bool isIdentity_3(GKSmatrix_3 matrix)
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

bool isEqual_3(GKSmatrix_3 matrix, GKSmatrix_3 matrix_b)
{
    bool identical = true;
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            if (matrix[i][j] != matrix_b[i][j]) {
                identical = false;
                break;
            }
        }
    }
    return identical;
}


bool isSame_3(GKSmatrix_3 matrix, GKSmatrix_3 matrix_b)
{
    bool same = true;
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            if (!areSame(matrix[i][j], matrix_b[i][j])) {
                same = false;
                break;
            }
        }
    }
    return same;
}


- (void)testIdentityMatrix2 {
    GKSmatrix_2 im;
    
    gks_create_identity_matrix_2(im);
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
    GKSmatrix_3 im;
    
    gks_create_identity_matrix_3(im);
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

- (void)testCreateMatrix {
    GKSmatrix_3 M;
    GKSvector3d v1, v2, v3, v4;
    
    v1 = GKSMakeVector( 1.0,  2.0, -2.0);
    v2 = GKSMakeVector( 0.78, 0.0,  4.0);
    v3 = GKSMakeVector(-0.9,  5.0, -1.2);
    v4 = GKSMakeVector( 1.0, -3.0,  0.1);
    
    gks_create_matrix_3(v1, v2, v3, v4, M);
    XCTAssertEqualWithAccuracy(M[0][0], 1.0, epsilon);
    XCTAssertEqualWithAccuracy(M[0][2], -2.0, epsilon);
    XCTAssertEqualWithAccuracy(M[2][1], 5.0, epsilon);
    XCTAssertEqualWithAccuracy(M[2][2], -1.2, epsilon);
    XCTAssertEqualWithAccuracy(M[3][1], -3.0, epsilon);
    XCTAssertEqualWithAccuracy(M[3][2], 0.1, epsilon);
    XCTAssertEqualWithAccuracy(M[3][3], 1.0, epsilon);
}

- (void)testCopyMatrix {
    GKSmatrix_3 result;
    GKSmatrix_3 I;
    GKSmatrix_3 M = {
        { 1.0,  2.0, -2.0, 1.0},
        { 0.78, 0.0,  4.0, 1.0},
        {-0.9,  5.0, -2.0, 1.0},
        {1.0, -3.0,  0.1, 1.0}
    };


    gks_create_identity_matrix_3(I);
    gks_matrix_copy_3(I, result);
    XCTAssertTrue(isIdentity_3(result), @"Not identity");
    
    gks_matrix_copy_3(M, result);
    XCTAssertTrue(isSame_3(M, result), @"Not the same, not close");

}

- (void)testMatrixScale3 {
    gks_create_scaling_matrix_3(A, B, C, im);
    XCTAssertEqual(im[0][0], A, @"Scaled in X by 20.0");
    XCTAssertEqual(im[1][1], B, @"Scaled in Y by 10.0");
    XCTAssertEqual(im[2][2], C);
    XCTAssertEqual(im[3][3], 1.0);
    
    gks_create_scaling_matrix_3(C, B, A, im);
    XCTAssertEqual(im[0][0], C, @"Scaled in X by 5.0");
    XCTAssertEqual(im[1][1], B, @"Scaled in Y by 10.0");
    XCTAssertEqual(im[2][2], A);
    XCTAssertEqual(im[3][3], 1.0);
}


- (void)testCreateRotate3x {
    gks_create_x_rotation_matrix_3(theta, im);
    XCTAssertEqualWithAccuracy(im[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);
    
    XCTAssertEqualWithAccuracy(im[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(im[2][1], 0.259, 0.001);
    XCTAssertEqualWithAccuracy(im[1][2], -0.259, 0.001);
    XCTAssertEqualWithAccuracy(im[0][3], 0.0, 0.001);
    
    gks_create_x_rotation_matrix_3(theta, im);
    XCTAssertEqualWithAccuracy(im[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);
    
    XCTAssertEqualWithAccuracy(im[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(im[2][1], 0.259, 0.001);
    XCTAssertEqualWithAccuracy(im[1][2], -0.259, 0.001);
    XCTAssertEqualWithAccuracy(im[0][3], 0.0, 0.001);
}

- (void)testCreateRotate3y {
    gks_create_y_rotation_matrix_3(theta, im);
    XCTAssertEqualWithAccuracy(im[0][0], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);
}


- (void)testCreateRotate3z {
    gks_create_z_rotation_matrix_3(theta, im);
    XCTAssertEqualWithAccuracy(im[0][0], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);
}

- (void)testMatrixTranslate3 {
    gks_create_translation_matrix_3(A, B, C, im);
    XCTAssertEqual(im[0][3], A);
    XCTAssertEqual(im[1][3], B);
    XCTAssertEqual(im[2][3], C);
    
    gks_create_translation_matrix_3(C, B, A, im);
    XCTAssertEqual(im[0][3], C);
    XCTAssertEqual(im[1][3], B);
    XCTAssertEqual(im[2][3], A);
}

- (void)testAccumulatedScale {

    gks_accumulate_scaling_matrix_3(2.0, 3.0, 4.0, im);
    XCTAssertEqualWithAccuracy(2.0, im[0][0], 0.001);
    XCTAssertEqualWithAccuracy(3.0, im[1][1], 0.001);
    XCTAssertEqualWithAccuracy(4.0, im[2][2], 0.001);
    
    gks_accumulate_scaling_matrix_3(1.5, 2.0, 2.5, im);
    XCTAssertEqualWithAccuracy(3.0, im[0][0], 0.001);
    XCTAssertEqualWithAccuracy(6.0, im[1][1], 0.001);
    XCTAssertEqualWithAccuracy(10.0, im[2][2], 0.001);

}

- (void)testAccumulatedRotateX {
    gks_accumulate_x_rotation_matrix_3(theta, im);

    XCTAssertEqualWithAccuracy(im[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(im[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(im[2][1], 0.259, 0.001);
    XCTAssertEqualWithAccuracy(im[1][2], -0.259, 0.001);
    XCTAssertEqualWithAccuracy(im[0][3], 0.0, 0.001);
    
    gks_accumulate_x_rotation_matrix_3(theta, im);
    XCTAssertEqualWithAccuracy(im[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(im[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(im[2][1], 0.5, 0.001);
    XCTAssertEqualWithAccuracy(im[1][2], -0.5, 0.001);
    XCTAssertEqualWithAccuracy(im[0][3], 0.0, 0.001);
    
    gks_accumulate_x_rotation_matrix_3(theta, im);
    XCTAssertEqualWithAccuracy(im[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 0.707, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 0.707, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(im[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(im[2][1], 0.707, 0.001);
    XCTAssertEqualWithAccuracy(im[1][2], -0.707, 0.001);
    XCTAssertEqualWithAccuracy(im[0][3], 0.0, 0.001);

    gks_accumulate_x_rotation_matrix_3(3*theta, im);
    XCTAssertEqualWithAccuracy(im[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(im[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(im[2][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[1][2], -1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[0][3], 0.0, 0.001);
    
}

- (void)testAccumulatedRotateY {
    gks_accumulate_y_rotation_matrix_3(theta, im);
    XCTAssertEqualWithAccuracy(im[0][0], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(im[2][0], -0.259, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[0][2], 0.259, 0.001);
    
    gks_accumulate_y_rotation_matrix_3(theta, im);
    XCTAssertEqualWithAccuracy(im[0][0], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);

    XCTAssertEqualWithAccuracy(im[2][0], -0.5, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[0][2], 0.5, 0.001);

}

- (void)testAccumulatedRotateZ {
    gks_accumulate_z_rotation_matrix_3(theta, im);
    XCTAssertEqualWithAccuracy(im[0][0], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 0.966, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);
    
    XCTAssertEqualWithAccuracy(im[1][0], 0.259, 0.001);
    XCTAssertEqualWithAccuracy(im[0][1], -0.259, 0.001);
    
    gks_accumulate_z_rotation_matrix_3(theta, im);
    XCTAssertEqualWithAccuracy(im[0][0], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(im[1][1], 0.866, 0.001);
    XCTAssertEqualWithAccuracy(im[2][2], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(im[3][3], 1.0, 0.001);
    
    XCTAssertEqualWithAccuracy(im[1][0], 0.5, 0.001);
    XCTAssertEqualWithAccuracy(im[0][1], -0.5, 0.001);

}

- (void)testAccumulateTranslate {
    gks_accumulate_translation_matrix_3(A, B, C, im);
    XCTAssertEqual(im[0][3], A);
    XCTAssertEqual(im[1][3], B);
    XCTAssertEqual(im[2][3], C);
    
    gks_accumulate_translation_matrix_3(C, B, A, im);
    XCTAssertEqual(im[0][3], A+C);
    XCTAssertEqual(im[1][3], B+B);
    XCTAssertEqual(im[2][3], C+A);
}

- (void)testCopyMatrix3 {
    GKSmatrix_3 s;
    GKSmatrix_3 M = {
        {1.0, 2.0,  3.0, -4.0},
        {2.0, 4.0,  6.0,  8.0},
        {3.0, 6.0, -2.0,  1.0},
        {0.0, 0.0,  0.0,  1.0}
    };
    
    gks_matrix_copy_3(im, s);
    XCTAssertEqual(s[0][0], 1.0, @"Identity 1.0 not in diagonal");
    XCTAssertEqual(s[1][1], 1.0, @"Identity 1.0 not in diagonal");
    XCTAssertEqual(s[2][2], 1.0, @"Identity 1.0 not in diagonal");
    XCTAssertEqual(s[3][3], 1.0, @"Identity 1.0 not in diagonal");
    
    bool is_identity = isIdentity_3(s);
    XCTAssertTrue(is_identity, @"Identity check failed");
    
    s[0][2] = 3.0;
    is_identity = isIdentity_3(s);
    XCTAssertFalse(is_identity, @"Identity check failed");

    gks_matrix_copy_3(M, im);
    XCTAssertEqualWithAccuracy(1.0, im[0][0], 0.001);
    XCTAssertEqualWithAccuracy(-2.0, im[2][2], 0.001);
    XCTAssertEqualWithAccuracy(3.0, im[0][2], 0.001);
}

- (void)testTransformPoint3 {
    GKSvector3d p0 = {1.0, 1.0, 1.0};
    GKSvector3d p1;
    
    gks_create_y_rotation_matrix_3(theta, im);
    gks_transform_point(im, p0, &p1);

    XCTAssertEqualWithAccuracy(p1.crd.x, 0.966 + 0.259, 0.001);
    XCTAssertEqualWithAccuracy(p1.crd.y, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(p1.crd.z, 0.966 - 0.259, 0.001);
    
    gks_accumulate_y_rotation_matrix_3(theta, im);
    gks_transform_point(im, p0, &p1);

    XCTAssertEqualWithAccuracy(p1.crd.x, 0.866 + 0.5, 0.001);
    XCTAssertEqualWithAccuracy(p1.crd.y, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(p1.crd.z, 0.866 - 0.5, 0.001);

}

- (void)testTransposeMatrix3 {
    GKSmatrix_3 m = {
        { 1.0,  2.0,  3.0,  0.0},
        { 4.0,  5.0,  6.0,  0.0},
        { 7.0,  8.0,  9.0,  0.0},
        {-7.0, -8.0,  9.0,  1.0}
    };
    GKSmatrix_3 t, o;
    
    gks_matrix_transpose_3(m, t);
    
    XCTAssertEqualWithAccuracy(t[0][0], 1.0, 0.001);
    XCTAssertEqualWithAccuracy(t[0][1], 4.0, 0.001);
    XCTAssertEqualWithAccuracy(t[0][2], 7.0, 0.001);
    XCTAssertEqualWithAccuracy(t[0][3], -7.0, 0.001);
    XCTAssertEqualWithAccuracy(t[1][0], 2.0, 0.001);
    XCTAssertEqualWithAccuracy(t[1][1], 5.0, 0.001);
    XCTAssertEqualWithAccuracy(t[1][2], 8.0, 0.001);
    XCTAssertEqualWithAccuracy(t[1][3], -8.0, 0.001);
    XCTAssertEqualWithAccuracy(t[2][0], 3.0, 0.001);
    XCTAssertEqualWithAccuracy(t[2][1], 6.0, 0.001);
    XCTAssertEqualWithAccuracy(t[2][2], 9.0, 0.001);
    XCTAssertEqualWithAccuracy(t[2][3], 9.0, 0.001);
    XCTAssertEqualWithAccuracy(t[3][0], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(t[3][1], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(t[3][2], 0.0, 0.001);
    XCTAssertEqualWithAccuracy(t[3][3], 1.0, 0.001);
    
    gks_matrix_transpose_3(t, o);
    
    bool identical = isEqual_3(o, m);
    XCTAssertTrue(identical);

}

- (void)testMultiplyMatrix {
    GKSmatrix_3 m1 = {
        { 1.0,  2.0,  3.0,  0.0},
        { 4.0,  5.0,  6.0,  -1.0},
        { 7.0,  8.0,  9.0,  0.0},
        {-7.0, -8.0,  9.0,  1.0}
    };
    GKSmatrix_3 m2 = {
        { 1.0,  2.0,  3.0,  4.0},
        { 4.0,  5.0,  6.0,  0.0},
        { 7.0,  8.0,  9.0,  0.0},
        {-7.0, -8.0,  9.0,  1.0}
    };
    GKSmatrix_3 verify;
    GKSmatrix_3 result = {
        {30, 36, 42, 4},
        {73, 89, 87, 15},
        {102, 126, 150, 28},
        {17, 10, 21, -27}
    };
    
    gks_matrix_multiply_3(m1, m2, verify);
    
    XCTAssertTrue(isEqual_3(verify, result));

}

- (void)testMatrixMultiplyViewTranslation {
     GKSmatrix_3 euler_angles = {
    {0.770, 0.000, -0.638, 0.000},
    {0.000, 1.000, 0.000, 0.000},
    {-0.638, 0.000, -0.770, 0.000},
    {0.000, 0.000, 0.000, 1.000} };

     GKSmatrix_3 translation = {
    {1.000, 0.000, 0.000, -0.000},
    {0.000, 1.000, 0.000, -0.000},
    {0.000, 0.000, 1.000, -5.700},
    {0.000, 0.000, 0.000, 1.000} };
    
    GKSmatrix_3 result = {
    {0.770, 0.000, 0.638, -3.636},
    {0.000, 1.000, 0.000, 0.000},
    {-0.638, 0.000, 0.770, -4.390},
    {0.000, 0.000, 0.000, 1.000} };
    
    GKSmatrix_3 result2 = {
    {0.770, 0.000, -0.638, 3.636},
    {0.000, 1.000, 0.000, 0.000},
    {-0.638, 0.000, -0.770, 4.390},
    {0.000, 0.000, 0.000, 1.000} };
    
    GKSmatrix_3 verify;
    
    gks_matrix_multiply_3(euler_angles, translation, verify);
    
    XCTAssertEqualWithAccuracy(verify[0][0], result[0][0], 0.001);
    
    
    XCTAssertTrue(isSame_3(verify, result2));
//    XCTAssertTrue(isEqual_3(verify, result));

}


- (void)testDeterminantMatrix {
    GKSmatrix_3 m1 = {
        { 1.0,  2.0,  3.0,  0.0},
        { 4.0,  5.0,  6.0,  -1.0},
        { 7.0,  8.0,  9.0,  0.0},
        {-7.0, -8.0,  9.0,  1.0}
    };
    GKSmatrix_3 m2 = {
        { 1.0,  2.0,  3.0,  4.0},
        { 4.0,  5.0,  6.0,  0.0},
        { 7.0,  8.0,  9.0,  0.0},
        {-7.0, -8.0,  9.0,  1.0}
    };
    
    GKSfloat det = gks_determinant_matrix_3(m1);
    XCTAssertEqualWithAccuracy(det, 108.0, 0.001);

    det = gks_determinant_matrix_3(m2);
    XCTAssertEqualWithAccuracy(det, 216.0, 0.001);

}

- (void)testPlaneEquation {
    GKSvector3d p1 = {0.0, 0.0, 0.0, 1.0};
    GKSvector3d p2 = {1.0, 0.0, 0.0, 1.0};
    GKSvector3d p3 = {1.0, 1.0, 0.0, 1.0};
    GKSvector3d p4 = {0.0, 1.0, 0.0, 1.0};
    GKSvector3d p5 = {0.0, 0.0, 1.0, 1.0};
    GKSvector3d p6 = {1.0, 0.0, 1.0, 1.0};
    GKSvector3d p7 = {1.0, 1.0, 1.0, 1.0};
    GKSvector3d p8 = {0.0, 1.0, 1.0, 1.0};
    
    GKSvector3d testPlane = {0.0, 0.0, 0.0, 0.0};    // this is weird using a point type for a plane type.
    
    // polygon 4
    gks_plane_equation_3(p2, p3, p7, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.crd.x, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.y, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.z, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.w, -1.0, 0.001);
    
    // polygon 1
    gks_plane_equation_3(p3, p2, p1, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.crd.x, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.y, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.z, -1.0, 0.001);
    gks_plane_equation_3(p1, p4, p3, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.crd.x, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.y, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.z, -1.0, 0.001);

    // polygon 6
    gks_plane_equation_3(p3, p4, p8, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.crd.x, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.y, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.z, 0.0, 0.001);
    
    // polygon 3
    gks_plane_equation_3(p8, p4, p1, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.crd.x, -1.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.y, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.z, 0.0, 0.001);
    
    // polygon 2
    gks_plane_equation_3(p5, p6, p7, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.crd.x, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.y, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.z, 1.0, 0.001);
    
    // polygon 5
    gks_plane_equation_3(p1, p2, p6, &testPlane);
    XCTAssertEqualWithAccuracy(testPlane.crd.x, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.y, -1.0, 0.001);
    XCTAssertEqualWithAccuracy(testPlane.crd.z, 0.0, 0.001);
    
}

// vector tests

- (void)testVectorDotProduct {
    GKSvector3d A = {1.0, 2.0, 3.0, 0.0};
    GKSvector3d B = {2.0, 0.0, 1.0, 0.0};
    float scalar_value = 0.0;
    
    scalar_value = vectordotproduct(A, B);
    XCTAssertEqualWithAccuracy(scalar_value, 5.0, 0.001);
}

- (void)testVectorSubtract {
    GKSvector3d va = {1.0, 2.0, 3.0, 1.0};
    GKSvector3d vb = {2.0, 0.0, 1.0, 0.0};
    GKSvector3d vc;
    
    vectorsubtract(va, vb, &vc);
    XCTAssertEqualWithAccuracy(vc.crd.x, -1.0, 0.001);
    XCTAssertEqualWithAccuracy(vc.crd.y, 2.0, 0.001);
    XCTAssertEqualWithAccuracy(vc.crd.z, 2.0, 0.001);
}

- (void)testVectorAdd {
    GKSvector3d va = {1.0, 2.0, 3.0, 1.0};
    GKSvector3d vb = {2.0, 0.0, 1.0, 0.0};
    GKSvector3d vc = {0.0, 0.0, 0.0, 0.0};
    
    vectoradd(va, vb, &vc);
    XCTAssertEqualWithAccuracy(vc.crd.x, 3.0, 0.001);
    XCTAssertEqualWithAccuracy(vc.crd.y, 2.0, 0.001);
    XCTAssertEqualWithAccuracy(vc.crd.z, 4.0, 0.001);
}

- (void)testVectorScale {
    GKSvector3d va = {1.0, 2.0, 3.0, 0.0};
    GKSvector3d vc;
    
    vectorscale(1.5, va, &vc);
    XCTAssertEqualWithAccuracy(vc.crd.x, 1.5, 0.001);
    XCTAssertEqualWithAccuracy(vc.crd.y, 3.0, 0.001);
    XCTAssertEqualWithAccuracy(vc.crd.z, 4.5, 0.001);
}

- (void)testVectorCrossProduct {
    GKSvector3d A  = {1.0, 2.0, 3.0, 0.0};
    GKSvector3d B = {2.0, 0.0, 1.0, 0.0};
    GKSvector3d C = {0.0, 0.0, 0.0, 0.0};
    
    vectorcrossproduct(A, B, &C);
    
    XCTAssertEqualWithAccuracy(C.crd.x, 2.0, 0.001);
    XCTAssertEqualWithAccuracy(C.crd.y, 5.0, 0.001);
    XCTAssertEqualWithAccuracy(C.crd.z, -4.0, 0.001);
}

- (void)testVectorNormal {
    GKSvector3d va = {1.0, 2.0, 3.0, 0.0};
    GKSvector3d vc;
    
    vectornormal(va, &vc);
    XCTAssertEqualWithAccuracy(vc.crd.x, 0.267261241912424, 0.001, @"1/sqrt(14)");
    XCTAssertEqualWithAccuracy(vc.crd.y, 0.534522483824849, 0.001);
    XCTAssertEqualWithAccuracy(vc.crd.z, 0.801783725737273, 0.001);
}

- (void)testVectorAbsoluteValue {
    GKSvector3d va = {1.0, 2.0, 3.0, 0.0};
    GKSvector3d vb = {1.0, -2.0, -3.0, 0.0};
    GKSfloat sqrtof14 = 3.74165;
    
    GKSfloat av = vectorabsolute(va);
    XCTAssertEqualWithAccuracy(av, sqrtof14, 0.001);
    av = vectorabsolute(vb);
    XCTAssertEqualWithAccuracy(av, sqrtof14, 0.001);
}

- (void)testVectorCopy {
    GKSvector3d va = {1.0, 2.0, 3.0, 1.0};
    GKSvector3d vb = {1.0, -2.0, -3.0, -1.0};
    
    GKSvector3d result = {0.0, 0.0, 0.0, 0.0};
    
    vectorcopy(va, &result);
    XCTAssertEqualWithAccuracy(result.crd.x, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(result.crd.y, 2.0, 0.001);
    XCTAssertEqualWithAccuracy(result.crd.z, 3.0, 0.001);
    XCTAssertEqualWithAccuracy(result.crd.w, 1.0, 0.001);
    vectorcopy(vb, &result);
    XCTAssertEqualWithAccuracy(result.crd.x, 1.0, 0.001);
    XCTAssertEqualWithAccuracy(result.crd.y, -2.0, 0.001);
    XCTAssertEqualWithAccuracy(result.crd.z, -3.0, 0.001);
    XCTAssertEqualWithAccuracy(result.crd.w, -1.0, 0.001);

}

// MARK: MESH

- (void)testMeshCube {
    GKSmesh_3 *cubeObj;
    setMeshCenteredFlag(false);
    
    cubeObj = CubeMesh();
    XCTAssert(cubeObj != NULL, @"Cube mesh does not exist");
    XCTAssertEqual(cubeObj->vertnum, 8);
    XCTAssertEqual(cubeObj->polynum, 6);
    
    // vertex 0 {0.0, 0.0, 0.0}
    XCTAssertEqual(cubeObj->vertices[0].crd.x, 0.0);
    XCTAssertEqual(cubeObj->vertices[0].crd.y, 0.0);
    XCTAssertEqual(cubeObj->vertices[0].crd.z, 0.0);
    // vertex 3 {0.0, 1.0, 0.0}
    XCTAssertEqual(cubeObj->vertices[3].crd.x, 0.0);
    XCTAssertEqual(cubeObj->vertices[3].crd.y, 1.0);
    XCTAssertEqual(cubeObj->vertices[3].crd.z, 0.0);
    // vertex 6 {1.0, 1.0, 1.0}
    XCTAssertEqual(cubeObj->vertices[6].crd.x, 1.0);
    XCTAssertEqual(cubeObj->vertices[6].crd.y, 1.0);
    XCTAssertEqual(cubeObj->vertices[6].crd.z, 1.0);
    
}

- (void)testMeshPyramid {
    GKSmesh_3 *pyramidObj;
    setMeshCenteredFlag(false);
    
    pyramidObj = PyramidMesh();
    XCTAssert(pyramidObj != NULL, @"Pyramid mesh not exists");
    XCTAssertEqual(pyramidObj->vertnum, 5, @"Pyramid should have 5 vertices");
    XCTAssertEqual(pyramidObj->polynum, 5, @"Pyramid should have 5 polygons");
    
    // vertex 0 {0.0, 0.0, 0.0}
    XCTAssertEqual(pyramidObj->vertices[0].crd.x, 0.0);
    XCTAssertEqual(pyramidObj->vertices[0].crd.y, 0.0);
    XCTAssertEqual(pyramidObj->vertices[0].crd.z, 0.0);
    // vertex 2 {1.0, 0.0, 1.0}
    XCTAssertEqual(pyramidObj->vertices[2].crd.x, 1.0);
    XCTAssertEqual(pyramidObj->vertices[2].crd.y, 0.0);
    XCTAssertEqual(pyramidObj->vertices[2].crd.z, 1.0);
    // vertuex 4 {0.5, 0.6636661, 0.5}
    XCTAssertEqual(pyramidObj->vertices[4].crd.x, 0.5);
    XCTAssertEqual(pyramidObj->vertices[4].crd.y, 0.6636661);
    XCTAssertEqual(pyramidObj->vertices[4].crd.z, 0.5);

}

- (void)testMeshHouse {
    GKSmesh_3 *houseObj;
    setMeshCenteredFlag(false);
    
    houseObj = HouseMesh();
    XCTAssert(houseObj != NULL, @"House mesh not exists");
    XCTAssertEqual(houseObj->vertnum, 10, @"House should have 10 vertices");
    XCTAssertEqual(houseObj->polynum, 7, @"House should have 7 polygons");

    // vertex 0 {0, 0, 30}
    XCTAssertEqual(houseObj->vertices[0].crd.x, 0.0);
    XCTAssertEqual(houseObj->vertices[0].crd.y, 0.0);
    XCTAssertEqual(houseObj->vertices[0].crd.z, 30.0);
    // vertex 6 {16, 0, 54},
    XCTAssertEqual(houseObj->vertices[6].crd.x, 16.0);
    XCTAssertEqual(houseObj->vertices[6].crd.y, 0.0);
    XCTAssertEqual(houseObj->vertices[6].crd.z, 54.0);
    // vertuex 9 {0, 10, 54}
    XCTAssertEqual(houseObj->vertices[9].crd.x, 0.0);
    XCTAssertEqual(houseObj->vertices[9].crd.y, 10.0);
    XCTAssertEqual(houseObj->vertices[9].crd.z, 54.0);
    
}

// MARK: PROJECTION
- (void)testProjectionInit {
    GKSmatrix_3 *projMatrix;
    
    GKScontext3DPtr context = gks_init();
    
//    gks_projection_init(context);
    projMatrix = gks_projection_get_matrix(context);
    XCTAssertEqual((*projMatrix)[0][0], 1.0);
    XCTAssertEqual((*projMatrix)[1][1], 1.0);
    XCTAssertEqual((*projMatrix)[2][2], 0.0);
    XCTAssertEqual((*projMatrix)[2][3], 0.0);
    XCTAssertEqual((*projMatrix)[3][3], 1.0);
}

- (void)testProjectionOrthogonalEnable {
    GKSmatrix_3 *projMatrix;
    
    GKScontext3DPtr context = gks_init();

    gks_projection_set_orthogonal(context);
    projMatrix = gks_projection_get_matrix(context);
    XCTAssertEqual((*projMatrix)[0][0], 1.0);
    XCTAssertEqual((*projMatrix)[1][1], 1.0);
    XCTAssertEqual((*projMatrix)[2][2], 0.0);
    XCTAssertEqual((*projMatrix)[2][3], 0.0);
    XCTAssertEqual((*projMatrix)[3][3], 1.0);
    
}

- (void)testProjectionPerspectiveEnable {
    GKSmatrix_3 *projMatrix;

    GKScontext3DPtr context = gks_init();

    gks_projection_set_simple(context, 1.0);
    projMatrix = gks_projection_get_matrix(context);
    XCTAssertEqual((*projMatrix)[0][0], 1.0);
    XCTAssertEqual((*projMatrix)[1][1], 1.0);
    XCTAssertEqual((*projMatrix)[2][2], 0.0);
    XCTAssertEqual((*projMatrix)[2][3], 1.0);   // TODO: watch sign should be positive 1
    XCTAssertEqual((*projMatrix)[3][3], 1.0);
    

}

// MARK: WORLD VOLUME

- (void)testVolumeMake {
    GKSvector3d min = GKSMakeVector(-1.1, -2.2, -3.3);
    GKSvector3d max = GKSMakeVector(3.3, 2.2, 1.1);
    GKSlimits_3 volume = GKSMakeVolume(min, max);
    
    XCTAssertEqualWithAccuracy(volume.xmin, -1.1, epsilon);
    XCTAssertEqualWithAccuracy(volume.xmax, 3.3, epsilon);
    XCTAssertEqualWithAccuracy(volume.ymin, -2.2, epsilon);
    XCTAssertEqualWithAccuracy(volume.ymax, 2.2, epsilon);
    XCTAssertEqualWithAccuracy(volume.zmin, -3.3, epsilon);
    XCTAssertEqualWithAccuracy(volume.zmax, 1.1, epsilon);

}

// MARK: TRANSFORM
- (void)testTransformInit {
    GKScontext3DPtr ctx = NULL;

    ctx = gks_init();
    
    XCTAssertNotEqual(ctx, NULL);
    
}


- (void)testTransformWCToNWC3 {
    GKSlimits_3 wrldlims = {-1.0, 1.0, -1.0, 1.0, -1.0, 1.0 };
    GKSvector3d p1 = {1.0, 1.0, 1.0, 1.0};
    GKSvector3d p2 = {0.0, 0.0, 0.0, 0.0};
    GKSlimits_2 portlims = { 0.0, 400.0, 0.0, 400.0 };
    
    GKScontext3DPtr ctx = gks_init();
    
    gks_norms_set_device_viewport(ctx, &portlims);
    gks_norms_set_world_volume(ctx, &wrldlims);

    
    // not a verified test, try some different values for p1 and limits
    gks_norms_wc_to_nwc(ctx, p1, &p2);
    
    XCTAssertEqual(p1.crd.x, 1.0);
    XCTAssertEqual(p1.crd.y, 1.0);
    XCTAssertEqual(p1.crd.z, 1.0);
    
}

- (void)testTransformNWCToDC3 {
    GKSlimits_3 wrldlims = {-1.0, 1.0, -1.0, 1.0, -1.0, 1.0 };
    GKSlimits_2 portlims = { 0.0, 400.0, 0.0, 400.0 };
    GKSvector3d p1 = {1.0, 1.0, 1.0, 1.0};
    GKSvector3d p2 = {0.5, 0.5, 0.0, 1.0};
    GKSfloat u, v;
        
    GKScontext3DPtr context = gks_init();
    
    gks_norms_set_world_volume(context, &wrldlims);
    gks_norms_set_device_viewport(context, &portlims);

    
    // TODO: verify, with different values for p1 and limits
    gks_norms_nwc_3_to_dc_2(context, p1, &u, &v);
    
    XCTAssertEqual(p1.crd.x, 1.0);
    XCTAssertEqual(p1.crd.y, 1.0);
    XCTAssertEqual(p1.crd.z, 1.0);
    
    XCTAssertEqual(u, 400.0);
    XCTAssertEqual(v, 400.0);
    
    gks_norms_nwc_3_to_dc_2(context, p2, &u, &v);
    XCTAssertEqual(u, 300.0);
    XCTAssertEqual(v, 300.0);
    
}
 

// MARK: MODEL
//- (void)testModelWorldInit {
//    GKSmatrix_3 *model_matrix;
//
//    gks_init_model_world(NULL);
//    model_matrix = gks_get_model_world_matrix(NULL);
//    GKSfloat avalue = (*model_matrix)[0][0];
//    GKSfloat bvalue = (*model_matrix)[1][1];
//    GKSfloat evalue = (*model_matrix)[2][1];
//    XCTAssertEqual(avalue, 1.0);
//    XCTAssertEqual(bvalue, 1.0);
//    XCTAssertEqual(evalue, 0.0);
//}
//
//- (void)testModelWorldGetMatrix {
//    GKSmatrix_3 *model_matrix;
//
//    gks_init_model_world(NULL);
//    model_matrix = gks_get_model_world_matrix(NULL);
//    GKSfloat avalue = (*model_matrix)[0][0];
//    GKSfloat bvalue = (*model_matrix)[1][1];
//    GKSfloat cvalue = (*model_matrix)[2][2];
//    GKSfloat dvalue = (*model_matrix)[3][3];
//    XCTAssertEqual(avalue, 1.0);
//    XCTAssertEqual(bvalue, 1.0);
//    XCTAssertEqual(cvalue, 1.0);
//    XCTAssertEqual(dvalue, 1.0);
//}


// MARK: VIEW ORIENT
- (void)testViewOrientInit {
    GKSmatrix_3 *theViewMatrixPtr;
    GKScontext3DPtr context = gks_init();

    gks_view_matrix_init(context);
    
    theViewMatrixPtr = gks_view_matrix_get(context);
    XCTAssertEqual((*theViewMatrixPtr)[0][0], 1.0);
    XCTAssertEqual((*theViewMatrixPtr)[1][2], 0.0);
    XCTAssertEqual((*theViewMatrixPtr)[2][2], -1.0);
}

- (void)testViewOrientSetMatrix {
    
    GKSmatrix_3 *theViewMatrixPtr;
    
    GKScontext3DPtr context = gks_init();
    
    gks_view_matrix_init(context);
    gks_view_matrix_set(context, im);

    theViewMatrixPtr = gks_view_matrix_get(context);
    XCTAssertEqual((*theViewMatrixPtr)[0][0], 1.0);
    XCTAssertEqual((*theViewMatrixPtr)[1][2], 0.0);     // non-diagonal
    XCTAssertEqual((*theViewMatrixPtr)[1][1], 1.0);
    XCTAssertEqual((*theViewMatrixPtr)[2][2], 1.0);
    XCTAssertEqual((*theViewMatrixPtr)[3][3], 1.0);
}

- (void)testViewOrientCreateViewMatrix {
    GKSmatrix_3 result_matrix;
    GKSvector3d loc, dir, up;
    
    GKScontext3DPtr context = gks_init();

    
    loc.crd.x = 0.0;
    loc.crd.y = 0.0;
    loc.crd.z = 3.0;
    loc.crd.w = 1.0;
    
    dir.crd.x = 0.0;
    dir.crd.y = 0.0;
    dir.crd.z = -1.0;
    dir.crd.w = 1.0;
    
    up.crd.x = 0.0;
    up.crd.y = 1.0;
    up.crd.z = 0.0;
    up.crd.w = 1.0;
    
    gks_view_matrix_init(context);
    gks_view_matrix_compute(context, loc, dir, up, result_matrix);
    
    XCTAssertEqualWithAccuracy(result_matrix[0][0], 1.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[0][1], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[0][2], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[0][3], 0.0, epsilon);
    
    XCTAssertEqualWithAccuracy(result_matrix[1][0], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[1][1], 1.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[1][2], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[1][3], 0.0, epsilon);

    XCTAssertEqualWithAccuracy(result_matrix[2][0], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[2][1], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[2][2], -1.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[2][3], 3.0, epsilon);

    XCTAssertEqualWithAccuracy(result_matrix[3][0], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[3][1], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[3][2], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[3][3], 1.0, epsilon);

}

- (void)testViewOrientCreateCameraViewMatrix {

    GKSmatrix_3 result_matrix;
    GKSvector3d loc, dir, up;

    loc.crd.x = 0.0;
    loc.crd.y = 0.0;
    loc.crd.z = 3.0;
    loc.crd.w = 1.0;
    
    dir.crd.x = 0.0;
    dir.crd.y = 0.0;
    dir.crd.z = -1.0;
    dir.crd.w = 1.0;
    
    up.crd.x = 0.0;
    up.crd.y = 1.0;
    up.crd.z = 0.0;
    up.crd.w = 1.0;
    
    GKScontext3DPtr context = gks_init();

    gks_view_matrix_init(context);

    gks_view_matrix_compute(context, loc, dir, up, result_matrix);

    XCTAssertEqualWithAccuracy(result_matrix[0][0], 1.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[0][1], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[0][2], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[0][3], 0.0, epsilon);
    
    XCTAssertEqualWithAccuracy(result_matrix[1][0], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[1][1], 1.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[1][2], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[1][3], 0.0, epsilon);

    XCTAssertEqualWithAccuracy(result_matrix[2][0], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[2][1], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[2][2], -1.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[2][3], 3.0, epsilon);

    XCTAssertEqualWithAccuracy(result_matrix[3][0], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[3][1], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[3][2], 0.0, epsilon);
    XCTAssertEqualWithAccuracy(result_matrix[3][3], 1.0, epsilon);
}

- (void)testViewOrientLookAtZero {
    GKSmatrix_3 theResultMatrix;
    GKSpoint_3 observer;
    GKSpoint_3 look_at;
    GKSpoint_3 v;
    GKSvector3d obs, look, up;

    observer.x = 0.0;
    observer.y = 0.0;
    observer.z = 4.0;
    obs.crd = observer;
    
    look_at.x = 0.0;
    look_at.y = 0.0;
    look_at.z = 0.0;
    look.crd = look_at;
    
    v.x = 0.0;
    v.y = 1.0;
    v.z = 0.0;
    up.crd = v;
    
    GKScontext3DPtr context = gks_init();

    gks_view_matrix_init(context);
    
//    gks_compute_camera_look_at_matrix(observer.x, observer.y, observer.z, look_at.x, look_at.y, look_at.z, v.x, v.y, v.z, theResultMatrix);
    gks_view_matrix_lookat_compute(context, obs, look, up, theResultMatrix);
    
    XCTAssertEqual(theResultMatrix[0][0], 1.0);
    XCTAssertEqual(theResultMatrix[1][1], 1.0);
    XCTAssertEqual(theResultMatrix[2][2], -1.0);
    XCTAssertEqual(theResultMatrix[2][3], 4.0);
    XCTAssertEqual(theResultMatrix[3][3], 1.0);

}

- (void)testViewOrientLookAtZ2 {
    GKSmatrix_3 theResultMatrix;
    GKSpoint_3 observer;
    GKSpoint_3 look_at;
    GKSpoint_3 v;
    GKSvector3d obs, look, up;

    observer.x = 0.0;
    observer.y = 0.0;
    observer.z = 4.0;
    obs.crd = observer;

    look_at.x = 0.0;
    look_at.y = 0.0;
    look_at.z = 2.0;
    look.crd = look_at;

    v.x = 0.0;
    v.y = 1.0;
    v.z = 0.0;
    up.crd = v;

    GKScontext3DPtr context = gks_init();

    gks_view_matrix_init(context);
    
//    gks_compute_camera_look_at_matrix(observer.x, observer.y, observer.z, look_at.x, look_at.y, look_at.z, v.x, v.y, v.z, theResultMatrix);
    gks_view_matrix_lookat_compute(context, obs, look, up, theResultMatrix);
    
    XCTAssertEqual(theResultMatrix[0][0], 1.0);
    XCTAssertEqual(theResultMatrix[1][1], 1.0);
    XCTAssertEqual(theResultMatrix[2][2], -1.0);
    XCTAssertEqual(theResultMatrix[2][3], 4.0);
    XCTAssertEqual(theResultMatrix[3][3], 1.0);

}

- (void)testViewOrientLookAtX4 {
    GKSmatrix_3 theResultMatrix;
    GKSpoint_3 observer;
    GKSpoint_3 look_at;
    GKSpoint_3 v;
    GKSvector3d obs, look, up;

    observer.x = 0.0;
    observer.y = 0.0;
    observer.z = 4.0;
    obs.crd = observer;
    
    look_at.x = 4.0;
    look_at.y = 0.0;
    look_at.z = 0.0;
    look.crd = look_at;
    
    v.x = 0.0;
    v.y = 1.0;
    v.z = 0.0;
    up.crd = v;

    GKScontext3DPtr context = gks_init();

    gks_view_matrix_init(context);
    
//    gks_compute_camera_look_at_matrix(observer.x, observer.y, observer.z, look_at.x, look_at.y, look_at.z, v.x, v.y, v.z, theResultMatrix);
    gks_view_matrix_lookat_compute(context, obs, look, up, theResultMatrix);
    
    XCTAssertEqualWithAccuracy(theResultMatrix[0][0], 0.7071, epsilon);
    XCTAssertEqual(theResultMatrix[0][1], 0.0);
    XCTAssertEqualWithAccuracy(theResultMatrix[0][2], 0.7071, epsilon);
    XCTAssertEqualWithAccuracy(theResultMatrix[0][3], -2.828, epsilon);
    XCTAssertEqual(theResultMatrix[1][0], 0.0);
    XCTAssertEqualWithAccuracy(theResultMatrix[1][1], 1.0, epsilon);
    XCTAssertEqual(theResultMatrix[1][2], 0.0);
    XCTAssertEqual(theResultMatrix[1][3], 0.0);
    XCTAssertEqualWithAccuracy(theResultMatrix[2][0], 0.7071, epsilon);
    XCTAssertEqual(theResultMatrix[2][1], 0.0);
    XCTAssertEqualWithAccuracy(theResultMatrix[2][2], -0.7071, epsilon);
    XCTAssertEqualWithAccuracy(theResultMatrix[2][3], 2.828, epsilon);
    XCTAssertEqual(theResultMatrix[3][0], 0.0);
    XCTAssertEqual(theResultMatrix[3][1], 0.0);
    XCTAssertEqual(theResultMatrix[3][2], 0.0);
    XCTAssertEqual(theResultMatrix[3][3], 1.0);

}

- (void)testViewOrientLookAtY4 {
    GKSmatrix_3 theResultMatrix;
    GKSpoint_3 observer;
    GKSpoint_3 look_at;
    GKSpoint_3 v;
    GKSvector3d obs, look, up;

    observer.x = 0.0;
    observer.y = 0.0;
    observer.z = 4.0;
    obs.crd = observer;
    
    look_at.x = 0.0;
    look_at.y = 4.0;
    look_at.z = 0.0;
    look.crd = look_at;
    
    v.x = 0.0;
    v.y = 1.0;
    v.z = 0.0;
    up.crd = v;

    GKScontext3DPtr context = gks_init();

    gks_view_matrix_init(context);
    
//    gks_compute_camera_look_at_matrix(observer.x, observer.y, observer.z, look_at.x, look_at.y, look_at.z, v.x, v.y, v.z, theResultMatrix);
    gks_view_matrix_lookat_compute(context, obs, look, up, theResultMatrix);
    
    XCTAssertEqualWithAccuracy(theResultMatrix[0][0], 1.0, epsilon);
    XCTAssertEqual(theResultMatrix[0][1], 0.0);
    XCTAssertEqual(theResultMatrix[0][2], 0.0);
    XCTAssertEqual(theResultMatrix[0][3], 0.0);
    XCTAssertEqual(theResultMatrix[1][0], 0.0);
    XCTAssertEqualWithAccuracy(theResultMatrix[1][1], 0.7071, epsilon);
    XCTAssertEqualWithAccuracy(theResultMatrix[1][2], 0.7071, epsilon);
    XCTAssertEqualWithAccuracy(theResultMatrix[1][3], -2.828 , epsilon);
    XCTAssertEqual(theResultMatrix[2][0], 0.0);
    XCTAssertEqualWithAccuracy(theResultMatrix[2][1], 0.7071, epsilon);
    XCTAssertEqualWithAccuracy(theResultMatrix[2][2], -0.7071, epsilon);
    XCTAssertEqualWithAccuracy(theResultMatrix[2][3], 2.828, epsilon);
    XCTAssertEqual(theResultMatrix[3][0], 0.0);
    XCTAssertEqual(theResultMatrix[3][1], 0.0);
    XCTAssertEqual(theResultMatrix[3][2], 0.0);
    XCTAssertEqual(theResultMatrix[3][3], 1.0);

}



@end
