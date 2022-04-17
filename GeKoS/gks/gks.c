//
//  gks.c
//  GeKoS
//
//  Created by Alex Popadich on 1/2/22.
//

#include "gks.h"


void gks_init_3D(GKScontext3DPtr context_ptr)
{
    gks_init_world_model();

    gks_norms_init(context_ptr);
    gks_projection_init(context_ptr);
    gks_view_matrix_init(context_ptr);
}


GKScontext3DPtr gks_init(void)
{
    GKScontext3DPtr context_ptr = gks_context_init();
    gks_init_3D(context_ptr);
    return context_ptr;
}
