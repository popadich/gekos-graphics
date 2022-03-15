//
//  gks_3d_view_orient.h
//  GeKoS
//
//  Created by Alex Popadich on 12/16/21.
//

#ifndef gks_3d_view_orient_h
#define gks_3d_view_orient_h

#include "gks_types.h"

GKSmatrix_3 *gks_get_view_matrix(void);
void gks_set_view_matrix(GKSmatrix_3 matrix);

void gks_init_view_matrix(void);
void gks_gen_view_matrix(GKSvector3d obs, GKSvector3d dir, GKSvector3d up, GKSmatrix_3 result);
void gks_gen_lookat_view_matrix(GKSvector3d obs, GKSvector3d look, GKSvector3d up, GKSmatrix_3 result);

void gks_gen_dir_vector(GKSvector3d location, GKSvector3d look, GKSvector3dPtr dir);

#endif /* gks_3d_view_orient_h */
