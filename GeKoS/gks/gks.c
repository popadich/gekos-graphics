//
//  gks.c
//  GeKoS
//
//  Created by Alex Popadich on 1/2/22.
//

#include "gks.h"


void gks_init_3D(void)
{
    gks_norms_init();
    gks_projection_init();
    gks_init_world_model();
    gks_view_matrix_init();
}


void gks_init(void)
{
    gks_init_3D();    
}
