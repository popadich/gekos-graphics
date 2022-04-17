//
//  gks_3d_view_orient.h
//  GeKoS
//
//  Created by Alex Popadich on 12/16/21.
//

#ifndef gks_3d_view_orient_h
#define gks_3d_view_orient_h

#include "gks_types.h"

void gks_view_matrix_init(GKScontext3DPtr context_ptr);

GKSmatrix_3 *gks_view_matrix_get(void);
void gks_view_matrix_set(GKSmatrix_3 matrix);

void gks_view_matrix_compute(GKSvector3d obs, GKSvector3d dir, GKSvector3d up, GKSmatrix_3 result);
void gks_view_matrix_lookat_compute(GKSvector3d obs, GKSvector3d look, GKSvector3d up, GKSmatrix_3 result);

void gks_view_matrix_dir_vector_calc(GKSvector3d location, GKSvector3d look, GKSvector3dPtr dir);

void gks_view_matrix_w_get(GKSvector3dPtr w_dir);
void gks_view_matrix_p_get(GKSvector3dPtr p_loc);

#endif /* gks_3d_view_orient_h */
