//
//  gks_3d_matrix.c
//  gks-graphics
//
//  Created by Alex Popadich on 12/1/21.
//

#include <math.h>
#include "gks_3d_matrix.h"

void gks_create_identity_matrix_2(GKSmatrix_2 result)
{
    result[0][0] = result[1][1] = result[2][2] = 1.0;
    result[0][1] = result[1][0] = result[2][0] = 0.0;
    result[0][2] = result[1][2] = result[2][1] = 0.0;
}

void gks_create_identity_matrix_3(GKSmatrix_3 result)
{
    result[0][0] = result[1][1] = result[2][2] = result[3][3] = 1.0;
    result[0][1] = result[0][2] = result[0][3] = 0.0;
    result[1][0] = result[1][2] = result[1][3] = 0.0;
    result[2][0] = result[2][1] = result[2][3] = 0.0;
    result[3][0] = result[3][1] = result[3][2] = 0.0;
}

void gks_create_matrix_3(GKSvector3d v1, GKSvector3d v2, GKSvector3d v3, GKSvector3d v4, GKSmatrix_3 result)
{
    result[0][0] = v1.arr[0];
    result[0][1] = v1.arr[1];
    result[0][2] = v1.arr[2];
    result[0][3] = v1.arr[3];

    result[1][0] = v2.arr[0];
    result[1][1] = v2.arr[1];
    result[1][2] = v2.arr[2];
    result[1][3] = v2.arr[3];

    result[2][0] = v3.arr[0];
    result[2][1] = v3.arr[1];
    result[2][2] = v3.arr[2];
    result[2][3] = v3.arr[3];

    result[3][0] = v4.arr[0];
    result[3][1] = v4.arr[1];
    result[3][2] = v4.arr[2];
    result[3][3] = v4.arr[3];
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

void gks_matrix_copy_3(GKSmatrix_3 original, GKSmatrix_3 result)
{
    for(int i=0; i<4; i++)
        for (int j=0; j<4; j++)
            result[i][j] = original[i][j];

}

// Computes a new point using homogeneous coordinate transformation matrix
// it assumes the w component of the point is always 1.
// TODO: Test to confirm order of multiplication
// New point computed using homogenuous coordinates, but the order of multiplication
// is unclear.
// The textbook states that Matrix multiplies a vector to transform the vector.
// Like this, but I'm not convinced.
//
//    [m00 m01 m02 m03] [px]
//    [m10            ] [py]
//    [m20            ] [pz]
//    [m30            ] [1]
//
void gks_transform_point(GKSmatrix_3 tm, GKSvector3d p1, GKSvector3dPtr result)
{
    result->crd.x = tm[0][0]*p1.crd.x + tm[0][1]*p1.crd.y + tm[0][2]*p1.crd.z + tm[0][3];
    result->crd.y = tm[1][0]*p1.crd.x + tm[1][1]*p1.crd.y + tm[1][2]*p1.crd.z + tm[1][3];
    result->crd.z = tm[2][0]*p1.crd.x + tm[2][1]*p1.crd.y + tm[2][2]*p1.crd.z + tm[2][3];
    result->crd.w = 1.0;
}


// New vector computed using homogenuous coordinates, but the order of multiplication
// is different.
// I think that the book states that Matrix multiplies Vector to transform a vector.
// Like this:
//
//   [v0]  [m00 m01 m02 m03]
//   [v1]  [               ]
//   [v2]  [               ]
//   [v3]  [               ]
//
void gks_vector_transform_3(GKSvector3d v, GKSmatrix_3 tm,  GKSvector3dPtr result)
{
    result->arr[0] = tm[0][0]*v.arr[0] + tm[1][0]*v.arr[1] + tm[2][0]*v.arr[2] + tm[3][0]*v.arr[3];
    result->arr[1] = tm[0][1]*v.arr[0] + tm[1][1]*v.arr[1] + tm[2][1]*v.arr[2] + tm[3][1]*v.arr[3];
    result->arr[2] = tm[0][2]*v.arr[0] + tm[1][2]*v.arr[1] + tm[2][2]*v.arr[2] + tm[3][2]*v.arr[3];
    result->arr[3] = tm[0][3]*v.arr[0] + tm[1][3]*v.arr[1] + tm[2][3]*v.arr[2] + tm[3][3]*v.arr[3];

}

void gks_vector_transform_projection(GKSvector3d v, GKSmatrix_3 tm, GKSvector3dPtr result)
{
    result->arr[0] = tm[0][0]*v.arr[0] + tm[1][0]*v.arr[1] + tm[2][0]*v.arr[2] + tm[3][0]*v.arr[3];
    result->arr[1] = tm[0][1]*v.arr[0] + tm[1][1]*v.arr[1] + tm[2][1]*v.arr[2] + tm[3][1]*v.arr[3];
    result->arr[2] = tm[0][2]*v.arr[0] + tm[1][2]*v.arr[1] + tm[2][2]*v.arr[2] + tm[3][2]*v.arr[3];
    result->arr[3] = tm[0][3]*v.arr[0] + tm[1][3]*v.arr[1] + tm[2][3]*v.arr[2] + tm[3][3]*v.arr[3];
    
    if (result->crd.w != 1) {
        result->arr[0] = result->arr[0]/result->arr[3];
        result->arr[1] = result->arr[1]/result->arr[3];
        result->arr[2] = result->arr[2]/result->arr[3];
        result->crd.w = 1.0;
    }

}


//   [m00 m01 m02 m03]  [v0]
//   [               ]  [v1]
//   [               ]  [v2]
//   [               ]  [v3]
//
// NOTE: only called from drawing glue
void gks_transform_vector_3(GKSmatrix_3 tm, GKSvector3d v, GKSvector3dPtr result)
{
    result->crd.x = tm[0][0]*v.arr[0] + tm[0][1]*v.arr[1] + tm[0][2]*v.arr[2] + tm[0][3]*v.arr[3];
    result->crd.y = tm[1][0]*v.arr[0] + tm[1][1]*v.arr[1] + tm[1][2]*v.arr[2] + tm[1][3]*v.arr[3];
    result->crd.z = tm[2][0]*v.arr[0] + tm[2][1]*v.arr[1] + tm[2][2]*v.arr[2] + tm[2][3]*v.arr[3];
    result->crd.w = tm[3][0]*v.arr[0] + tm[3][1]*v.arr[1] + tm[3][2]*v.arr[2] + tm[3][3]*v.arr[3];

}


void gks_plane_equation_3(GKSvector3d p1, GKSvector3d p2, GKSvector3d p3, GKSvector3dPtr plane) {
    double A, B, C, D;
    
    // compute the plane equation from 3 points on the plane
    // this will generate 4 double numbers A, B, C, D.
    // A, B, C are the normal vector and D is distance from
    // origin.
    A = p1.crd.y*(p2.crd.z - p3.crd.z) + p2.crd.y*(p3.crd.z - p1.crd.z) + p3.crd.y*(p1.crd.z - p2.crd.z);
    B = p1.crd.z*(p2.crd.x - p3.crd.x) + p2.crd.z*(p3.crd.x - p1.crd.x) + p3.crd.z*(p1.crd.x - p2.crd.x);
    C = p1.crd.x*(p2.crd.y - p3.crd.y) + p2.crd.x*(p3.crd.y - p1.crd.y) + p3.crd.x*(p1.crd.y - p2.crd.y);
    D = -p1.crd.x*(p2.crd.y*p3.crd.z - p3.crd.y*p2.crd.z)
        -p2.crd.x*(p3.crd.y*p1.crd.z - p1.crd.y*p3.crd.z)
        -p3.crd.x*(p1.crd.y*p2.crd.z - p2.crd.y*p1.crd.z);
    plane->crd.x = A;
    plane->crd.y = B;
    plane->crd.z = C;
    plane->crd.w = D;

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
    return (a.crd.x*b.crd.x + a.crd.y*b.crd.y + a.crd.z*b.crd.z);
}

void vecprod(GKSfloat *a, GKSfloat *b, GKSfloat *c)
{
    c[0]=a[1]*b[2]-b[1]*a[2];
    c[1]=b[0]*a[2]-b[2]*a[0];    // smart reverse for sign change
    c[2]=a[0]*b[1]-b[0]*a[1];
}

void vectorcrossproduct(GKSvector3d a, GKSvector3d b, GKSvector3dPtr c){
    c->arr[0] = a.arr[1]*b.arr[2]-b.arr[1]*a.arr[2];
    c->arr[1] = b.arr[0]*a.arr[2]-b.arr[2]*a.arr[0];  // clever reverse for sign change
    c->arr[2] = a.arr[0]*b.arr[1]-b.arr[0]*a.arr[1];
}

void vectorsubtract(GKSvector3d a, GKSvector3d b, GKSvector3dPtr c)
{
    GKSint k;
    for (k=0; k<3; k++) c->arr[k]=a.arr[k]-b.arr[k];
}

void vectoradd(GKSvector3d a, GKSvector3d b, GKSvector3dPtr c)
{
    GKSint k;
    for (k=0; k<3; k++) {
        c->arr[k] = a.arr[k]+b.arr[k];
    }
}

void vecscale(GKSfloat k, GKSpoint_3_Ptr a, GKSpoint_3_Ptr b)
{
    b[0]=a[0]*k;
    b[1]=a[1]*k;
    b[2]=a[2]*k;
}

void vectorscale(GKSfloat k, GKSvector3d a, GKSvector3dPtr result) {
    result->arr[0] = a.arr[0]*k;
    result->arr[1] = a.arr[1]*k;
    result->arr[2] = a.arr[2]*k;
}

void vecnormal(GKSpoint_3_Ptr vec, GKSpoint_3_Ptr normal)
{
    GKSfloat length = sqrt (vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2]);
    
    normal[0] = vec[0]/length;
    normal[1] = vec[1]/length;
    normal[2] = vec[2]/length;
    
}

void vectornormal(GKSvector3d vec, GKSvector3dPtr normal) {
    GKSfloat length = sqrt (vec.arr[0]*vec.arr[0]
                            + vec.arr[1]*vec.arr[1]
                            + vec.arr[2]*vec.arr[2]);

    normal->crd.x = vec.crd.x/length;
    normal->crd.y = vec.crd.y/length;
    normal->crd.z = vec.crd.z/length;

}

GKSfloat vecabsolutevalue(GKSvector3d vec)
{
    return sqrt (vec.arr[0]*vec.arr[0] + vec.arr[1]*vec.arr[1] + vec.arr[2]*vec.arr[2]);
}
