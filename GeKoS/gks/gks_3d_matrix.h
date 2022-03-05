//
//  gks_3d_matrix.h
//  gks-graphics
//
//  Created by Alex Popadich on 12/1/21.
//


#ifndef gks_3d_matrix_h
#define gks_3d_matrix_h

# include "gks_types.h"

#define DEG_TO_RAD 0.01745329252


void gks_set_identity_matrix_2(Matrix_2 result);
void gks_set_identity_matrix_3(Matrix_3 result);

void gks_create_scaling_matrix_3(Gfloat sx, Gfloat sy, Gfloat sz, Matrix_3 result);
void gks_create_x_rotation_matrix_3(Gfloat theta, Matrix_3 result);
void gks_create_y_rotation_matrix_3(Gfloat theta, Matrix_3 result);
void gks_create_z_rotation_matrix_3(Gfloat theta, Matrix_3 result);
void gks_create_translation_matrix_3(Gfloat dx, Gfloat dy, Gfloat dz, Matrix_3 result);

void gks_accumulate_scaling_matrix_3(Gfloat sx, Gfloat sy, Gfloat sz, Matrix_3 m);
void gks_accumulate_x_rotation_matrix_3(Gfloat theta, Matrix_3 m);
void gks_accumulate_y_rotation_matrix_3(Gfloat theta, Matrix_3 m);
void gks_accumulate_z_rotation_matrix_3(Gfloat theta, Matrix_3 m);
void gks_accumulate_translation_matrix_3(Gfloat dx, Gfloat dy, Gfloat dz, Matrix_3 m);

void gks_copy_matrix_3(Matrix_3 matrix_a, Matrix_3 matrix_b);

void gks_transform_point_3(Matrix_3 trans_matrix, Gpt_3 *old_point, Gpt_3 *new_point);

void gks_plane_equation_3(Gpt_3 p1, Gpt_3 p2, Gpt_3 p3, Gpt_3 *overloadPlane);


// Vector Operations
Gfloat vecdot(Gpt_3_Ptr a, Gpt_3_Ptr b);
void vecprod(Gpt_3_Ptr a, Gpt_3_Ptr b, Gpt_3_Ptr c);
void vecsub(Gpt_3_Ptr a, Gpt_3_Ptr b, Gpt_3_Ptr c);
void vecadd(GVector a, GVector b, GVectorPtr c);
void vecscale(Gfloat k, Gpt_3_Ptr a, Gpt_3_Ptr b);
void vecnormal(Gpt_3_Ptr vec, Gpt_3_Ptr normal);

#endif /* gks_3d_matrix_h */
