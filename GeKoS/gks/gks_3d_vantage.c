//
//  gks_3d_vantage.c
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

#include "gks_3d_vantage.h"
#include "gks_3d_normalization.h"
#include "gks_3d_view_orient.h"
#include "gks_3d_matrix.h"

#define GKS_MAX_VANTAGE_PTS 10
#define GKS_VOLUME_TYPES 2
#define GKS_TRANSFORM_TYPES 2

const GKSint kWorldVolumeSetup = 0;
const GKSint kViewVolumeSetup = 1;

const GKSint kViewMatrixSetup = 0;
const GKSint kProjectionMatrixSetup = 1;

//  P R O T O T Y P E S
void store_vantage(GKSint vantage_point);

// S T A T I C   G L O B A L S
static GKSint         g_curr_vantage_idx;

// Make room for 10 transforms, use only one for now
static GKSlimits_3 g_vantage_list[GKS_MAX_VANTAGE_PTS][GKS_VOLUME_TYPES];
static GKSmatrix_3 g_matrix_list[GKS_MAX_VANTAGE_PTS][GKS_TRANSFORM_TYPES];


//
// Initialize world, viewport, and device transformations
//
void gks_vantage_init(void)
{
    // set all vantage points to their default values
    for (GKSint vant_pt = 0; vant_pt < GKS_MAX_VANTAGE_PTS; vant_pt++) {
        store_vantage(vant_pt);
    }
    g_curr_vantage_idx = 0;
}


void store_vantage(GKSint vantage_point)
{
    GKSlimits_3 *world_volume = gks_trans_get_world_volume();
    g_vantage_list[vantage_point][kWorldVolumeSetup].xmin = world_volume->xmin;
    g_vantage_list[vantage_point][kWorldVolumeSetup].xmax = world_volume->xmax;
    g_vantage_list[vantage_point][kWorldVolumeSetup].ymin = world_volume->ymin;
    g_vantage_list[vantage_point][kWorldVolumeSetup].ymax = world_volume->ymax;
    g_vantage_list[vantage_point][kWorldVolumeSetup].zmin = world_volume->zmin;
    g_vantage_list[vantage_point][kWorldVolumeSetup].zmax = world_volume->zmax;
    
    GKSlimits_3 *view_volume = gks_trans_get_view_volume();
    g_vantage_list[vantage_point][kViewVolumeSetup].xmin = view_volume->xmin;
    g_vantage_list[vantage_point][kViewVolumeSetup].xmax = view_volume->xmax;
    g_vantage_list[vantage_point][kViewVolumeSetup].ymin = view_volume->ymin;
    g_vantage_list[vantage_point][kViewVolumeSetup].ymax = view_volume->ymax;
    g_vantage_list[vantage_point][kViewVolumeSetup].zmin = view_volume->zmin;
    g_vantage_list[vantage_point][kViewVolumeSetup].zmax = view_volume->zmax;
    
    GKSmatrix_3 *view_matrix = gks_view_matrix_get();
    
    gks_matrix_copy_3(*view_matrix, g_matrix_list[vantage_point][kViewMatrixSetup]);
    
}


void restore_vantage(GKSint vantage_point)
{
    GKSlimits_3 world_volume_rest = g_vantage_list[vantage_point][kWorldVolumeSetup];
    gks_trans_set_world_volume(&world_volume_rest);
    
    GKSmatrix_3 view_matrix_rest;
    gks_matrix_copy_3(g_matrix_list[vantage_point][kViewMatrixSetup], view_matrix_rest);
    
    gks_view_matrix_set(view_matrix_rest);
}

void gks_vantage_set_current_view(GKSint view_num)
{
    if (view_num > -1 && view_num < GKS_MAX_VANTAGE_PTS) {
        // store current here
        store_vantage(g_curr_vantage_idx);
        
        // restore view num
        restore_vantage(view_num);
        
        // compute new transforms here
        gks_trans_compute_transforms();
        g_curr_vantage_idx = view_num;
    }
}


GKSint gks_vantage_get_current_view(void)
{
    return g_curr_vantage_idx;
}


void gks_vantage_set_defaults(void)
{
    // set all vantage points to their default values
    for (GKSint vant_pt = 0; vant_pt < GKS_MAX_VANTAGE_PTS; vant_pt++) {
        store_vantage(vant_pt);
    }
}


