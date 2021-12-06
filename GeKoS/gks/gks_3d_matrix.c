//
//  gks_3d_matrix.c
//  gks-graphics
//
//  Created by Alex Popadich on 12/1/21.
//

#include <math.h>
#include "gks_3d_matrix.h"



void gks_set_identity_matrix_2(Matrix_3 result)
{
    result[0][0] = result[1][1] = result[2][2] = 1.0;
    result[0][1] = result[1][0] = result[2][0] = 0.0;
    result[0][2] = result[1][2] = result[2][1] = 0.0;
}

void gks_set_identity_matrix_3(Matrix_4 result)
{
    result[0][0] = result[1][1] = result[2][2] = result[3][3] = 1.0;
    result[0][1] = result[0][2] = result[0][3] = 0.0;
    result[1][0] = result[1][2] = result[1][3] = 0.0;
    result[2][0] = result[2][1] = result[2][3] = 0.0;
    result[3][0] = result[3][1] = result[3][2] = 0.0;
}

// Evaluates a scaling matrix with a fixed point at
//    the origin and scale factors sx, sy and sz.
void gks_create_scaling_matrix_3(Gfloat sx, Gfloat sy, Gfloat sz, Matrix_4 result)
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

void gks_create_x_rotation_matrix_3(Gfloat theta, Matrix_4 result)
{
    result[1][1] = result[2][2] = cos(theta);
    result[2][1] = sin(theta);
    result[0][0] = result[3][3] = 1;
    result[1][2] = -result[2][1];
    result[0][1] = result[0][2] = result[1][0] = result[2][0] = 0.0;
    result[3][0] = result[3][1] = result[3][2]
    = result[0][3] = result[1][3] = result[2][3] = 0.0;
}

void gks_create_y_rotation_matrix_3(Gfloat theta, Matrix_4 result)
{
    result[0][0] = result[2][2] = cos(theta);
    result[0][2] = sin(theta);
    result[1][1] = result[3][3] = 1;
    result[2][0] = -result[0][2];
    result[0][1] = result[1][0] = result[1][2] = result[2][1] = 0.0;
    result[3][0] = result[3][1] = result[3][2]
    = result[0][3] = result[1][3] = result[2][3] = 0.0;
}

void gks_create_z_rotation_matrix_3(Gfloat theta, Matrix_4 result)
{
    result[0][0] = result[1][1] = cos(theta);
    result[1][0] = sin(theta);
    result[2][2] = result[3][3] = 1;
    result[0][1] = -result[1][0];
    result[2][0] = result[2][1] = result[0][2] = result[1][2] = 0.0;
    result[3][0] = result[3][1] = result[3][2]
    = result[0][3] = result[1][3] = result[2][3] = 0.0;
}

void gks_create_translation_matrix_3(Gfloat dx, Gfloat dy, Gfloat dz, Matrix_4 result)
{
    result[0][0] = result[1][1] = result[2][2] = result[3][3] = 1.0;
    result[0][1] = result[0][2] = result[1][0] = result[1][2] = 0.0;
    result[2][0] = result[2][1] = result[3][0] = result[3][1] = result[3][2] = 0.0;
    result[0][3] = dx;
    result[1][3] = dy;
    result[2][3] = dz;
}


// Forms the matrix product result = A*B
void accumulate_matrices_3(Matrix_4 matrix_a, Matrix_4 matrix_b, Matrix_4 result)
{
    int i,j,k;
    Matrix_4    temp;
    
    for(i=0;i<4;i++) for(j=0;j<4;j++)
        {
            temp[i][j]=0.0;
            for(k=0;k<4;k++)
                temp[i][j] += matrix_a[i][k]*matrix_b[k][j];
        }
    for(i=0;i<4;i++) for(j=0;j<4;j++)
        result[i][j]=temp[i][j];
}

void gks_accumulate_scaling_matrix_3(Gfloat sx, Gfloat sy, Gfloat sz, Matrix_4 m)
{
    Matrix_4 temp;
    gks_create_scaling_matrix_3(sx,sy,sz,temp);
    accumulate_matrices_3(temp,m,m);
}

void gks_accumulate_x_rotation_matrix_3(Gfloat theta, Matrix_4 m)
{
    Matrix_4 temp;
    gks_create_x_rotation_matrix_3(theta,temp);
    accumulate_matrices_3(temp,m,m);
}

void gks_accumulate_y_rotation_matrix_3(Gfloat theta, Matrix_4 m)
{
    Matrix_4 temp;
    gks_create_y_rotation_matrix_3(theta,temp);
    accumulate_matrices_3(temp,m,m);
}

void gks_accumulate_z_rotation_matrix_3(Gfloat theta, Matrix_4 m)
{
    Matrix_4 temp;
    gks_create_z_rotation_matrix_3(theta,temp);
    accumulate_matrices_3(temp,m,m);
}

void gks_accumulate_translation_matrix_3(Gfloat dx, Gfloat dy, Gfloat dz, Matrix_4 m)
{
    Matrix_4 temp;
    gks_create_translation_matrix_3(dx,dy,dz,temp);
    accumulate_matrices_3(temp,m,m);
}

// Copies matrix A -> B
void gks_copy_matrix_3(Matrix_4 matrix_a, Matrix_4 matrix_b)
{
    int i,j;
    
    for(i=0;i<4;i++) for(j=0;j<4;j++)
            matrix_b[i][j]=matrix_a[i][j];
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
void gks_transform_point_3(Matrix_4 tm, Gpt_3 *p1, Gpt_3 *p2)
{
    p2->x = tm[0][3] + tm[0][0]*p1->x + tm[0][1]*p1->y + tm[0][2]*p1->z;
    p2->y = tm[1][3] + tm[1][0]*p1->x + tm[1][1]*p1->y + tm[1][2]*p1->z;
    p2->z = tm[2][3] + tm[2][0]*p1->x + tm[2][1]*p1->y + tm[2][2]*p1->z;
}


// New point computed using homogenuous coordinates, but the order of multiplication
// is different. To test the order of multiplication.
//
//   [v0]  [m1 m2 m3 m4]
//   [v1]  [           ]
//   [v2]  [           ]
//   [v3]  [           ]
//
void gks_transform_vector_4(Matrix_4 tm, Vector_4 v, Vector_4 result)
{
    result[0] = tm[0][0]*v[0] + tm[1][0]*v[1] + tm[2][0]*v[2] + tm[3][0]*v[3];
    result[1] = tm[0][1]*v[0] + tm[1][1]*v[1] + tm[2][1]*v[2] + tm[3][1]*v[3];
    result[2] = tm[0][2]*v[0] + tm[1][2]*v[1] + tm[2][2]*v[2] + tm[3][2]*v[3];
    result[3] = tm[0][3]*v[0] + tm[1][3]*v[1] + tm[2][3]*v[2] + tm[3][3]*v[3];

}

void gks_plane_equation_3(Gpt_3 p1, Gpt_3 p2, Gpt_3 p3, Gpt_3 *overloadPlane) {
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


// Vector Operations
//
// Vector operations all use an in place technique
// where a result vector is always passed in to the
// function in order to populate it with teh results.
//

Gfloat vecdot(Gpt_3_Ptr a, Gpt_3_Ptr b)
{
    return (a[0]*b[0] + a[1]*b[1] + a[2]*b[2]);
}

void vecprod(Gfloat *a, Gfloat *b, Gfloat *c)
{
    c[0]=a[1]*b[2]-b[1]*a[2];
    c[1]=b[0]*a[2]-b[2]*a[0];    // smart reverse for sign change
    c[2]=a[0]*b[1]-b[0]*a[1];
}

void vecsub(Gpt_3_Ptr a, Gpt_3_Ptr b, Gpt_3_Ptr c)
{
    Gint k;
    for (k=0; k<3; k++) c[k]=a[k]-b[k];
}

void vecadd(GVector a, GVector b, GVectorPtr c)
{
    Gint k;
    for (k=0; k<3; k++) {
        c->vec_arr[k] = a.vec_arr[k]+b.vec_arr[k];
    }
}

void vecscale(Gfloat k, Gpt_3_Ptr a, Gpt_3_Ptr b)
{
    b[0]=a[0]*k;
    b[1]=a[1]*k;
    b[2]=a[2]*k;
}

void vecnormal(Gpt_3_Ptr vec, Gpt_3_Ptr normal)
{
    Gfloat    length;
    
    length = sqrt (vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2]);
    
    normal[0] = vec[0]/length;
    normal[1] = vec[1]/length;
    normal[2] = vec[2]/length;
    
}
