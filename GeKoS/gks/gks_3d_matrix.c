//
//  gks_3d_matrix.c
//  gks-graphics
//
//  Created by Alex Popadich on 12/1/21.
//

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

void vecscale(Gfloat k, Gfloat *a, Gfloat *b)
{
    b[0]=a[0]*k;
    b[1]=a[1]*k;
    b[2]=a[2]*k;
}


