//
//  gks_3d_model_world.h
//  GeKoS
//
//  Created by Alex Popadich on 12/15/21.
//

#ifndef gks_3d_model_world_h
#define gks_3d_model_world_h

#include "gks_types.h"

void gks_init_model_world(GKScontext3DPtr context);

void gks_set_model_world_matrix(GKScontext3DPtr context, GKSmatrix_3 trans_matrix);
GKSmatrix_3 *gks_get_model_world_matrix(GKScontext3DPtr context);


#endif /* gks_3d_model_world_h */
