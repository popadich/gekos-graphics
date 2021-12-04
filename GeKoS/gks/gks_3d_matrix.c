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
