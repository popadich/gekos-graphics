//
//  gks.c
//  GeKoS
//
//  Created by Alex Popadich on 1/2/22.
//

#include "gks.h"


void gks_init_3D(void)
{
    gks_trans_init_3();
    gks_init_projection();
    gks_init_world_model();
    gks_init_view_plane();
}


void gks_init(void)
{
    gks_init_3D();    
}
