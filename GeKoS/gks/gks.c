//
//  gks.c
//  GeKoS
//
//  Created by Alex Popadich on 1/2/22.
//

#include "gks.h"


void gks_init_3D(void)
{
    gks_trans_init();
    gks_init_projection();
    gks_init_world_model();
    gks_init_view_matrix();
}


void gks_init(void)
{
    gks_init_3D();    
}
