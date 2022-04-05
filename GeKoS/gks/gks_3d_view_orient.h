//
//  gks_3d_view_orient.h
//  GeKoS
//
//  Created by Alex Popadich on 12/16/21.
//

#ifndef gks_3d_view_orient_h
#define gks_3d_view_orient_h

#include "gks_types.h"

GKSmatrix_3 *gks_view_matrix_get(void);
void gks_view_matrix_set(GKSmatrix_3 matrix);

void gks_view_matrix_init(void);
void gks_view_matrix_gen(GKSvector3d obs, GKSvector3d dir, GKSvector3d up, GKSmatrix_3 result);
void gks_view_matrix_gen_lookat(GKSvector3d obs, GKSvector3d look, GKSvector3d up, GKSmatrix_3 result);

void gks_view_matrix_calc_dir_vector(GKSvector3d location, GKSvector3d look, GKSvector3dPtr dir);

#endif /* gks_3d_view_orient_h */
