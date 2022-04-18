//
//  gks_3d_model_world.c
//  GeKoS
//
//  Created by Alex Popadich on 12/15/21.
//

#include "gks_3d_world.h"

static GKSmatrix_3      gWorldModelMatrix_3;          // World Modeling Matrix

void gks_init_model_world(GKScontext3DPtr context) {
    GKSmatrix_3 identity_matrix = {
        {1.0, 0.0, 0.0, 0.0},
        {0.0, 1.0, 0.0, 0.0},
        {0.0, 0.0, 1.0, 0.0},
        {0.0, 0.0, 0.0, 1.0}
    };
    gks_set_model_world_matrix(context, identity_matrix);
}

// sets up the matrix used to place and orient a 3D object into the 3D world
// this needs to be called before the object instance is going to compute
// device coordinates
// TODO: make this simpler get the transform from the object instead
void gks_set_model_world_matrix(GKScontext3DPtr context, GKSmatrix_3 trans_matrix)
{
    for(int i=0; i<4; i++) {
        for(int j=0; j<4; j++) {
            gWorldModelMatrix_3[i][j] = trans_matrix[i][j];
        }
    }
}

GKSmatrix_3 *gks_get_model_world_matrix(GKScontext3DPtr context)
{
    return &gWorldModelMatrix_3;
}
