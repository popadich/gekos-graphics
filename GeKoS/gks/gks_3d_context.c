//
//  gks_3d_context.c
//  GeKoS
//
//  Created by Alex Popadich on 12/8/21.
//

/*
 Device independent coordinate transformations
 
 The device independence is brought to you by having a set of transforms which can
 be used to translate from normalized device coordinates, device coordinates and
 world coordinates.
 
 - World Coordinates: (WC) used by the application programmer to describe graphical information to GKS.
 - Normalized Device Coordinates: (NDC) used to define a uniform coordinate system for all workstations.
 - Device Coordinates: (DC), one coordinate system per workstation, representing its display surface coordinates. Input containing coordinates are expressed to GKS by the device using DC values.
 
 */

#include "gks_3d_context.h"
#include "gks_3d_normalization.h"
#include "gks_3d_view_orient.h"
#include "gks_3d_matrix.h"
#include "gks_3d_projection.h"


const GKSint kWorldVolumeSetup = 0;
const GKSint kViewVolumeSetup = 1;

const GKSint kViewMatrixSetup = 0;
const GKSint kProjectionMatrixSetup = 1;

//  P R O T O T Y P E S
void store_context(GKSint vantage_point);

// S T A T I C   G L O B A L S
static GKSint         g_curr_context_idx;

// Make room for 10 transforms, use only one for now
static GKSlimits_3 g_context_list[GKS_MAX_CONTEXT_PTS][GKS_VOLUME_TYPES];
static GKSmatrix_3 g_matrix_list[GKS_MAX_CONTEXT_PTS][GKS_TRANSFORM_TYPES];


//
// Initialize world, viewport, and device transformations
//
void gks_context_init(void)
{
    // set all vantage points to their default values
    for (GKSint ctx_idx = 0; ctx_idx < GKS_MAX_CONTEXT_PTS; ctx_idx++) {
        store_context(ctx_idx);
    }
    g_curr_context_idx = 0;
}


void store_context(GKSint ctx_idx)
{
    GKSlimits_3 *world_volume = gks_trans_get_world_volume();
    g_context_list[ctx_idx][kWorldVolumeSetup].xmin = world_volume->xmin;
    g_context_list[ctx_idx][kWorldVolumeSetup].xmax = world_volume->xmax;
    g_context_list[ctx_idx][kWorldVolumeSetup].ymin = world_volume->ymin;
    g_context_list[ctx_idx][kWorldVolumeSetup].ymax = world_volume->ymax;
    g_context_list[ctx_idx][kWorldVolumeSetup].zmin = world_volume->zmin;
    g_context_list[ctx_idx][kWorldVolumeSetup].zmax = world_volume->zmax;
    
    GKSlimits_3 *view_volume = gks_trans_get_view_volume();
    g_context_list[ctx_idx][kViewVolumeSetup].xmin = view_volume->xmin;
    g_context_list[ctx_idx][kViewVolumeSetup].xmax = view_volume->xmax;
    g_context_list[ctx_idx][kViewVolumeSetup].ymin = view_volume->ymin;
    g_context_list[ctx_idx][kViewVolumeSetup].ymax = view_volume->ymax;
    g_context_list[ctx_idx][kViewVolumeSetup].zmin = view_volume->zmin;
    g_context_list[ctx_idx][kViewVolumeSetup].zmax = view_volume->zmax;
    
    GKSmatrix_3 *view_matrix = gks_view_matrix_get();
    gks_matrix_copy_3(*view_matrix, g_matrix_list[ctx_idx][kViewMatrixSetup]);
    
    GKSmatrix_3 *projection = gks_projection_get_matrix();
    gks_matrix_copy_3(*projection, g_matrix_list[ctx_idx][kProjectionMatrixSetup]);

}


void restore_vantage(GKSint ctx_idx)
{
    GKSlimits_3 world_volume_rest = g_context_list[ctx_idx][kWorldVolumeSetup];
    gks_trans_set_world_volume(&world_volume_rest);
    
    GKSmatrix_3 view_matrix_rest;
    gks_matrix_copy_3(g_matrix_list[ctx_idx][kViewMatrixSetup], view_matrix_rest);
    gks_view_matrix_set(view_matrix_rest);
    
    GKSmatrix_3 projection_rest;
    gks_matrix_copy_3(g_matrix_list[ctx_idx][kProjectionMatrixSetup], projection_rest);
    gks_projection_set_matrix(projection_rest);
    

}

void gks_context_set_current_view(GKSint ctx_idx)
{
    if (ctx_idx > -1 && ctx_idx < GKS_MAX_CONTEXT_PTS) {
        // store current here
        store_context(g_curr_context_idx);
        
        // restore view num
//        restore_context(view_num);
        
        // compute new transforms here
//        gks_trans_compute_transforms();
        g_curr_context_idx = ctx_idx;
    }
}


GKSint gks_context_get_current_view(void)
{
    return g_curr_context_idx;
}


void gks_context_set_defaults(void)
{
    // set all vantage points to their default values
    for (GKSint vant_pt = 0; vant_pt < GKS_MAX_CONTEXT_PTS; vant_pt++) {
        store_context(vant_pt);
    }
}


