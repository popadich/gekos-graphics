//
//  gks_3d_matrix.c
//  gks-graphics
//
//  Created by Alex Popadich on 12/1/21.
//

#include <math.h>
#include "gks_3d_matrix.h"

void gks_set_identity_matrix_2(GKSmatrix_2 result)
{
    result[0][0] = result[1][1] = result[2][2] = 1.0;
    result[0][1] = result[1][0] = result[2][0] = 0.0;
    result[0][2] = result[1][2] = result[2][1] = 0.0;
}

void gks_set_identity_matrix_3(GKSmatrix_3 result)
{
    result[0][0] = result[1][1] = result[2][2] = result[3][3] = 1.0;
    result[0][1] = result[0][2] = result[0][3] = 0.0;
    result[1][0] = result[1][2] = result[1][3] = 0.0;
    result[2][0] = result[2][1] = result[2][3] = 0.0;
    result[3][0] = result[3][1] = result[3][2] = 0.0;
}

// Evaluates a scaling matrix with a fixed point at
//    the origin and scale factors sx, sy and sz.
void gks_create_scaling_matrix_3(GKSfloat sx, GKSfloat sy, GKSfloat sz, GKSmatrix_3 result)
{
    result[0][1] = result[0][2] = result[0][3]
        = result[1][0] = result[1][2] = result[1][3]
        = result[2][0] = result[2][1] = result[2][3]
        = result[3][0] = result[3][1] = result[3][2]= 0.0;
    result[0][0] = sx;
    result[1][1] = sy;
    result[2][2] = sz;
    result[3][3] = 1.0;
}

void gks_create_x_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 result)
{
    result[1][1] = result[2][2] = cos(theta);
    result[2][1] = sin(theta);
    result[0][0] = result[3][3] = 1;
    result[1][2] = -result[2][1];
    result[0][1] = result[0][2] = result[1][0] = result[2][0] = 0.0;
    result[3][0] = result[3][1] = result[3][2]
    = result[0][3] = result[1][3] = result[2][3] = 0.0;
}

void gks_create_y_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 result)
{
    result[0][0] = result[2][2] = cos(theta);
    result[0][2] = sin(theta);
    result[1][1] = result[3][3] = 1;
    result[2][0] = -result[0][2];
    result[0][1] = result[1][0] = result[1][2] = result[2][1] = 0.0;
    result[3][0] = result[3][1] = result[3][2]
    = result[0][3] = result[1][3] = result[2][3] = 0.0;
}

void gks_create_z_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 result)
{
    result[0][0] = result[1][1] = cos(theta);
    result[1][0] = sin(theta);
    result[2][2] = result[3][3] = 1;
    result[0][1] = -result[1][0];
    result[2][0] = result[2][1] = result[0][2] = result[1][2] = 0.0;
    result[3][0] = result[3][1] = result[3][2]
    = result[0][3] = result[1][3] = result[2][3] = 0.0;
}

void gks_create_translation_matrix_3(GKSfloat dx, GKSfloat dy, GKSfloat dz, GKSmatrix_3 result)
{
    result[0][0] = result[1][1] = result[2][2] = result[3][3] = 1.0;
    result[0][1] = result[0][2] = result[1][0] = result[1][2] = 0.0;
    result[2][0] = result[2][1] = result[3][0] = result[3][1] = result[3][2] = 0.0;
    result[0][3] = dx;
    result[1][3] = dy;
    result[2][3] = dz;
}


// Forms the matrix product result = A*B
void accumulate_matrices_3(GKSmatrix_3 matrix_a, GKSmatrix_3 matrix_b, GKSmatrix_3 result)
{
    int i,j,k;
    GKSmatrix_3    temp;
    
    for(i=0;i<4;i++) for(j=0;j<4;j++)
        {
            temp[i][j]=0.0;
            for(k=0;k<4;k++)
                temp[i][j] += matrix_a[i][k]*matrix_b[k][j];
        }
    for(i=0;i<4;i++) for(j=0;j<4;j++)
        result[i][j]=temp[i][j];
}

void gks_accumulate_scaling_matrix_3(GKSfloat sx, GKSfloat sy, GKSfloat sz, GKSmatrix_3 m)
{
    GKSmatrix_3 temp;
    gks_create_scaling_matrix_3(sx,sy,sz,temp);
    accumulate_matrices_3(temp,m,m);
}

void gks_accumulate_x_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 m)
{
    GKSmatrix_3 temp;
    gks_create_x_rotation_matrix_3(theta,temp);
    accumulate_matrices_3(temp,m,m);
}

void gks_accumulate_y_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 m)
{
    GKSmatrix_3 temp;
    gks_create_y_rotation_matrix_3(theta,temp);
    accumulate_matrices_3(temp,m,m);
}

void gks_accumulate_z_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 m)
{
    GKSmatrix_3 temp;
    gks_create_z_rotation_matrix_3(theta,temp);
    accumulate_matrices_3(temp,m,m);
}

void gks_accumulate_translation_matrix_3(GKSfloat dx, GKSfloat dy, GKSfloat dz, GKSmatrix_3 m)
{
    GKSmatrix_3 temp;
    gks_create_translation_matrix_3(dx,dy,dz,temp);
    accumulate_matrices_3(temp,m,m);
}

// Computes a new point using homogeneous coordinate transformation matrix
// it assumes the w component of the point is always 1.
// TODO: Test to confirm order of multiplication
// New point computed using homogenuous coordinates, but the order of multiplication
// is unclear.
// The textbook states that Matrix multiplies a vector to transform the vector.
// Like this, but I'm not convinced.
//
//    [m1 m2 m3 m4] [px]
//    [           ] [py]
//    [           ] [pz]
//    [           ] [1]
//
void gks_transform_point_3(GKSmatrix_3 tm, GKSpoint_3 *p1, GKSpoint_3 *result)
{
    result->x = tm[0][3] + tm[0][0]*p1->x + tm[0][1]*p1->y + tm[0][2]*p1->z;
    result->y = tm[1][3] + tm[1][0]*p1->x + tm[1][1]*p1->y + tm[1][2]*p1->z;
    result->z = tm[2][3] + tm[2][0]*p1->x + tm[2][1]*p1->y + tm[2][2]*p1->z;
}


// New vector computed using homogenuous coordinates, but the order of multiplication
// is different.
// I think that the book states that Matrix multiplies Vector to transform a vector.
// this, but Im not sure.
//
//   [v0]  [m1 m2 m3 m4]
//   [v1]  [           ]
//   [v2]  [           ]
//   [v3]  [           ]
//
void gks_transform_vector_4(GKSmatrix_3 tm, GKSvector_3 v, GKSvector_3 result)
{
    result[0] = tm[0][0]*v[0] + tm[1][0]*v[1] + tm[2][0]*v[2] + tm[3][0]*v[3];
    result[1] = tm[0][1]*v[0] + tm[1][1]*v[1] + tm[2][1]*v[2] + tm[3][1]*v[3];
    result[2] = tm[0][2]*v[0] + tm[1][2]*v[1] + tm[2][2]*v[2] + tm[3][2]*v[3];
    result[3] = tm[0][3]*v[0] + tm[1][3]*v[1] + tm[2][3]*v[2] + tm[3][3]*v[3];

}


void gks_plane_equation_3(GKSpoint_3 p1, GKSpoint_3 p2, GKSpoint_3 p3, GKSpoint_3 *overloadPlane) {
    double A, B, C, D;
    
    // compute the plane equation from 3 points on the plane
    // this will generate 4 double numbers A, B, C, D.
    // A, B, C are the normal vector and D is distance from
    // origin.
    A = p1.y*(p2.z - p3.z) + p2.y*(p3.z - p1.z) + p3.y*(p1.z - p2.z);
    B = p1.z*(p2.x - p3.x) + p2.z*(p3.x - p1.x) + p3.z*(p1.x - p2.x);
    C = p1.x*(p2.y - p3.y) + p2.x*(p3.y - p1.y) + p3.x*(p1.y - p2.y);
    D = -p1.x*(p2.y*p3.z - p3.y*p2.z)
        -p2.x*(p3.y*p1.z - p1.y*p3.z)
        -p3.x*(p1.y*p2.z - p2.y*p1.z);
    overloadPlane->x = A;
    overloadPlane->y = B;
    overloadPlane->z = C;
    overloadPlane->w = D;

}


// Copies matrix A -> B
void gks_copy_matrix_3(GKSmatrix_3 matrix_a, GKSmatrix_3 matrix_b)
{
    int i,j;
    for(i=0;i<4;i++)
        for(j=0;j<4;j++)
            matrix_b[i][j]=matrix_a[i][j];
}

// Transpose matrix
//  A -> AT
void gks_transpose_matrix_3(GKSmatrix_3 matrix_a, GKSmatrix_3 matrix_trans)
{
    int i,j;
    for(i=0;i<4;i++)
        for(j=0;j<4;j++)
            matrix_trans[i][j]=matrix_a[j][i];
}

// Multiply matrix A • B -> R
//
//    [a00  a01 a02 a03]    [b00  b01  ... ...]
//    [a10  ... ... ...]    [b10  ...  ... ...]
//    [...  ... ... ...]    [b20  ...  ... ...]
//    [...  ... ... ...]    [b30  ...  ... ...]
//
//
void gks_multiply_matrix_3(GKSmatrix_3 a, GKSmatrix_3 b, GKSmatrix_3 r)
{
    r[0][0] = a[0][0]*b[0][0] + a[0][1]*b[1][0] + a[0][2]*b[2][0] + a[0][3]*b[3][0];
    r[0][1] = a[0][0]*b[0][1] + a[0][1]*b[1][1] + a[0][2]*b[2][1] + a[0][3]*b[3][1];
    r[0][2] = a[0][0]*b[0][2] + a[0][1]*b[1][2] + a[0][2]*b[2][2] + a[0][3]*b[3][2];
    r[0][3] = a[0][0]*b[0][3] + a[0][1]*b[1][3] + a[0][2]*b[2][3] + a[0][3]*b[3][3];

    r[1][0] = a[1][0]*b[0][0] + a[1][1]*b[1][0] + a[1][2]*b[2][0] + a[1][3]*b[3][0];
    r[1][1] = a[1][0]*b[0][1] + a[1][1]*b[1][1] + a[1][2]*b[2][1] + a[1][3]*b[3][1];
    r[1][2] = a[1][0]*b[0][2] + a[1][1]*b[1][2] + a[1][2]*b[2][2] + a[1][3]*b[3][2];
    r[1][3] = a[1][0]*b[0][3] + a[1][1]*b[1][3] + a[1][2]*b[2][3] + a[1][3]*b[3][3];

    r[2][0] = a[2][0]*b[0][0] + a[2][1]*b[1][0] + a[2][2]*b[2][0] + a[2][3]*b[3][0];
    r[2][1] = a[2][0]*b[0][1] + a[2][1]*b[1][1] + a[2][2]*b[2][1] + a[2][3]*b[3][1];
    r[2][2] = a[2][0]*b[0][2] + a[2][1]*b[1][2] + a[2][2]*b[2][2] + a[2][3]*b[3][2];
    r[2][3] = a[2][0]*b[0][3] + a[2][1]*b[1][3] + a[2][2]*b[2][3] + a[2][3]*b[3][3];
    
    r[3][0] = a[3][0]*b[0][0] + a[3][1]*b[1][0] + a[3][2]*b[2][0] + a[3][3]*b[3][0];
    r[3][1] = a[3][0]*b[0][1] + a[3][1]*b[1][1] + a[3][2]*b[2][1] + a[3][3]*b[3][1];
    r[3][2] = a[3][0]*b[0][2] + a[3][1]*b[1][2] + a[3][2]*b[2][2] + a[3][3]*b[3][2];
    r[3][3] = a[3][0]*b[0][3] + a[3][1]*b[1][3] + a[3][2]*b[2][3] + a[3][3]*b[3][3];

}


void subMatrix(GKSint n, GKSfloat m[n][n], GKSint I, GKSint J, GKSfloat M[n-1][n-1])
{
    GKSint i, a = 0, b = 0;
    GKSint j;
    for (i = 0; i < n; i++)
    {
        if (i == I)
        {
            continue;
        }

        b = 0;//in-order to start fresh for new row
        for (j = 0; j < n; j++)
        {
            if (J == j)
            {
                continue;
            }
            M[a][b] = m[i][j];
            b++;
        }
        a++;
    }
}

//this recursive function calculates the determinant
GKSfloat determinant(GKSint n, GKSfloat M[n][n])
{
    double det = 0;
    //the functions continues to call its self until n=2
    if(n==1)
    {
        return M[0][0];
    }
    if (n == 2)
    {
        det = M[0][0] *M[1][1]-M[0][1]*M[1][0];
    }
    else
    {
        double subArray[n-1][n-1];
        for (GKSint i = 0; i < n; i++)
        {
            //subMatrix is filling the subArray
            subMatrix(n,M,0,i,subArray);
            det += M[0][i] * ((i&1)?-1:1)*determinant(n - 1,subArray);
        }
    }
    return det;
}

GKSfloat gks_determinant_matrix_3(GKSmatrix_3 M)
{
    return (determinant(4, M));
}




// Vector Operations
//
// Vector operations all use an in place technique
// where a result vector is always passed in to the
// function in order to populate it with teh results.
//

GKSfloat vecdot(GKSpoint_3_Ptr a, GKSpoint_3_Ptr b)
{
    return (a[0]*b[0] + a[1]*b[1] + a[2]*b[2]);
}

GKSfloat vectordotproduct(GKSvector3d a, GKSvector3d b)
{
    return (a.vec_pos.x*b.vec_pos.x + a.vec_pos.y*b.vec_pos.y + a.vec_pos.z*b.vec_pos.z);
}

void vecprod(GKSfloat *a, GKSfloat *b, GKSfloat *c)
{
    c[0]=a[1]*b[2]-b[1]*a[2];
    c[1]=b[0]*a[2]-b[2]*a[0];    // smart reverse for sign change
    c[2]=a[0]*b[1]-b[0]*a[1];
}

void vectorcrossproduct(GKSvector3d a, GKSvector3d b, GKSvector3dPtr c){
    c->vec_arr[0] = a.vec_arr[1]*b.vec_arr[2]-b.vec_arr[1]*a.vec_arr[2];
    c->vec_arr[1] = b.vec_arr[0]*a.vec_arr[2]-b.vec_arr[2]*a.vec_arr[0];  // clever reverse for sign change
    c->vec_arr[2] = a.vec_arr[0]*b.vec_arr[1]-b.vec_arr[0]*a.vec_arr[1];
}

void vecsub(GKSpoint_3_Ptr a, GKSpoint_3_Ptr b, GKSpoint_3_Ptr c)
{
    GKSint k;
    for (k=0; k<3; k++) c[k]=a[k]-b[k];
}

void vectorsubtract(GKSvector3d a, GKSvector3d b, GKSvector3dPtr c)
{
    GKSint k;
    for (k=0; k<3; k++) c->vec_arr[k]=a.vec_arr[k]-b.vec_arr[k];
}

void vectoradd(GKSvector3d a, GKSvector3d b, GKSvector3dPtr c)
{
    GKSint k;
    for (k=0; k<3; k++) {
        c->vec_arr[k] = a.vec_arr[k]+b.vec_arr[k];
    }
}

void vecscale(GKSfloat k, GKSpoint_3_Ptr a, GKSpoint_3_Ptr b)
{
    b[0]=a[0]*k;
    b[1]=a[1]*k;
    b[2]=a[2]*k;
}

void vectorscale(GKSfloat k, GKSvector3d a, GKSvector3dPtr result) {
    result->vec_arr[0] = a.vec_arr[0]*k;
    result->vec_arr[1] = a.vec_arr[1]*k;
    result->vec_arr[2] = a.vec_arr[2]*k;
}

void vecnormal(GKSpoint_3_Ptr vec, GKSpoint_3_Ptr normal)
{
    GKSfloat length = sqrt (vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2]);
    
    normal[0] = vec[0]/length;
    normal[1] = vec[1]/length;
    normal[2] = vec[2]/length;
    
}

void vectornormal(GKSvector3d vec, GKSvector3dPtr normal) {
    GKSfloat length = sqrt (vec.vec_arr[0]*vec.vec_arr[0]
                            + vec.vec_arr[1]*vec.vec_arr[1]
                            + vec.vec_arr[2]*vec.vec_arr[2]);

    normal->vec_pos.x = vec.vec_pos.x/length;
    normal->vec_pos.y = vec.vec_pos.y/length;
    normal->vec_pos.z = vec.vec_pos.z/length;

}

GKSfloat vecabsolutevalue(GKSvector3d vec)
{
    return sqrt (vec.vec_arr[0]*vec.vec_arr[0] + vec.vec_arr[1]*vec.vec_arr[1] + vec.vec_arr[2]*vec.vec_arr[2]);
}
