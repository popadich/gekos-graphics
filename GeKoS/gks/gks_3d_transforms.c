//
//  gks_3d_transforms.c
//  GeKoS
//
//  Created by Alex Popadich on 12/8/21.
//

#include "gks_3d_transforms.h"

static Gint         g_curr_transform_idx;           // More than one view possible

static Gfloat       g_wrld_xscale, g_wrld_xcoord;
static Gfloat       g_wrld_yscale, g_wrld_ycoord;
static Gfloat       g_wrld_zscale, g_wrld_zcoord;
static Gfloat       g_dev_xscale, g_dex_xcoord;
static Gfloat       g_dev_yscale, g_dev_ycoord;

void gks_trans_init_3(void)
{
    g_wrld_xscale = g_wrld_xcoord = 0.0;
    g_wrld_yscale = g_wrld_ycoord = 0.0;
    g_wrld_zscale = g_wrld_zcoord = 0.0;
    g_dev_xscale = g_dex_xcoord = 0.0;
    g_dev_yscale = g_dev_ycoord = 0.0;
    g_curr_transform_idx = -1;
   
}


Gint gks_trans_get_curr_view_idx(void)
{
    return g_curr_transform_idx;
}


void gks_trans_set_curr_view_idx(Gint view_num)
{
    if (view_num > -1 && view_num < GKS_MAX_VIEW_TRANSFORMS) {
        // TODO: compute the transform matrix for this view index
        
        g_curr_transform_idx = view_num;
    }
}


