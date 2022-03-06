//
//  gks_3d_world.h
//  GeKoS
//
//  Created by Alex Popadich on 12/15/21.
//

#ifndef gks_3d_world_h
#define gks_3d_world_h

#include "gks_types.h"

void gks_init_world_model(void);

void gks_set_world_model_matrix(GKSmatrix_3 trans_matrix);
GKSmatrix_3 *gks_get_world_model_matrix(void);


#endif /* gks_3d_world_h */
