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


void gks_create_identity_matrix_2(GKSmatrix_2 result);
void gks_create_identity_matrix_3(GKSmatrix_3 result);
void gks_create_matrix_3(GKSvector3d v1, GKSvector3d v2, GKSvector3d v3, GKSvector3d v4, GKSmatrix_3 result);

// TODO: scaling matrix not needed
void gks_create_scaling_matrix_3(GKSfloat sx, GKSfloat sy, GKSfloat sz, GKSmatrix_3 result);
void gks_create_x_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 result);
void gks_create_y_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 result);
void gks_create_z_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 result);
void gks_create_translation_matrix_3(GKSfloat dx, GKSfloat dy, GKSfloat dz, GKSmatrix_3 result);

void gks_accumulate_scaling_matrix_3(GKSfloat sx, GKSfloat sy, GKSfloat sz, GKSmatrix_3 m);
void gks_accumulate_x_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 m);
void gks_accumulate_y_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 m);
void gks_accumulate_z_rotation_matrix_3(GKSfloat theta, GKSmatrix_3 m);
void gks_accumulate_translation_matrix_3(GKSfloat dx, GKSfloat dy, GKSfloat dz, GKSmatrix_3 m);



void gks_transform_point(GKSmatrix_3 tm, GKSvector3d v, GKSvector3dPtr result);
void gks_vector_transform_projection(GKSvector3d v, GKSmatrix_3 tm, GKSvector3dPtr result);
void gks_vector_transform_3(GKSvector3d v, GKSmatrix_3 tm,  GKSvector3dPtr result);
void gks_transform_vector_3(GKSmatrix_3 tm, GKSvector3d v, GKSvector3dPtr result);

// Matrix Operations
void gks_matrix_copy_3(GKSmatrix_3 original, GKSmatrix_3 result);

void gks_matrix_transpose_3(GKSmatrix_3 original, GKSmatrix_3 result);
void gks_matrix_multiply_3(GKSmatrix_3 a, GKSmatrix_3 b, GKSmatrix_3 matrix_result);
GKSfloat gks_determinant_matrix_3(GKSmatrix_3 M);

void gks_plane_equation_3(GKSvector3d p1, GKSvector3d p2, GKSvector3d p3, GKSvector3dPtr plane);

// Vector Operations
GKSfloat vectordotproduct(GKSvector3d a, GKSvector3d b);
void vectorcrossproduct(GKSvector3d a, GKSvector3d b, GKSvector3dPtr result);
void vectorsubtract(GKSvector3d a, GKSvector3d b, GKSvector3dPtr result);
void vectoradd(GKSvector3d a, GKSvector3d b, GKSvector3dPtr c);
void vectorscale(GKSfloat k, GKSvector3d a, GKSvector3dPtr result);
void vectornormal(GKSvector3d vec, GKSvector3dPtr normal);
GKSfloat vectorabsolute(GKSvector3d vec);
void vectorcopy(GKSvector3d vec, GKSvector3dPtr result);

#endif /* gks_3d_matrix_h */

