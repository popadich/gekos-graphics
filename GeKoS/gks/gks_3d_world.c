//
//  gks_3d_world.c
//  GeKoS
//
//  Created by Alex Popadich on 12/15/21.
//

#include "gks_3d_world.h"

static GKSmatrix_3      gWorldModelMatrix_3;          // World Modeling Matrix

void gks_init_world_model(void) {
    GKSmatrix_3 identity_matrix = {
        {1.0, 0.0, 0.0, 0.0},
        {0.0, 1.0, 0.0, 0.0},
        {0.0, 0.0, 1.0, 0.0},
        {0.0, 0.0, 0.0, 1.0}
    };
    gks_set_world_model_matrix(identity_matrix);
}

void gks_set_world_model_matrix(GKSmatrix_3 trans_matrix)
{
    for(int i=0; i<4; i++) {
        for(int j=0; j<4; j++) {
            gWorldModelMatrix_3[i][j] = trans_matrix[i][j];
        }
    }
}

GKSmatrix_3 *gks_get_world_model_matrix(void)
{
    return &gWorldModelMatrix_3;
}
