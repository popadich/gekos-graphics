//
//  gks_3d_matrix.h
//  gks-graphics
//
//  Created by Alex Popadich on 12/1/21.
//


#ifndef gks_3d_matrix_h
#define gks_3d_matrix_h

# include "gks_types.h"

#define DEG_TO_RAD 0.0174533


void gks_set_identity_matrix_2(Matrix_3 result);
void gks_set_identity_matrix_3(Matrix_4 result);

void gks_create_scaling_matrix_3(Gfloat sx, Gfloat sy, Gfloat sz, Matrix_4 result);
void gks_create_x_rotation_matrix_3(Gfloat theta, Matrix_4 result);
void gks_create_y_rotation_matrix_3(Gfloat theta, Matrix_4 result);
void gks_create_z_rotation_matrix_3(Gfloat theta, Matrix_4 result);

// Vector Operations
Gfloat vecdot(Gpt_3_Ptr a, Gpt_3_Ptr b);
void vecprod(Gpt_3_Ptr a, Gpt_3_Ptr b, Gpt_3_Ptr c);
void vecsub(Gpt_3_Ptr a, Gpt_3_Ptr b, Gpt_3_Ptr c);
void vecadd(GVector a, GVector b, GVectorPtr c);
void vecscale(Gfloat k, Gpt_3_Ptr a, Gpt_3_Ptr b);
void vecnormal(Gpt_3_Ptr vec, Gpt_3_Ptr normal);

#endif /* gks_3d_matrix_h */
