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

#define GKS_MAX_VANTAGE_PTS 10
#define GKS_TRANSFORM_TYPES 2

const GKSint kWorldVolumeSetup = 0;
const GKSint kViewVolumeSetup = 1;

//  P R O T O T Y P E S
void gks_vantage_set_vantage_defaults(void);


// S T A T I C   G L O B A L S
static GKSint         g_curr_vantage_idx;

// Make room for 10 transforms, use only one for now
static GKSlimits_3 g_vantage_list[GKS_MAX_VANTAGE_PTS][GKS_TRANSFORM_TYPES];


//
// Initialize world, viewport, and device transformations
//
void gks_vantage_init(void)
{
    gks_norms_init();
    
    gks_vantage_set_vantage_defaults();
    g_curr_vantage_idx = 0;
}


void store_vantage(GKSint vantage_point)
{
    GKSlimits_3 *world = gks_trans_get_world_volume();
    g_vantage_list[vantage_point][kWorldVolumeSetup].xmin = world->xmin;
    g_vantage_list[vantage_point][kWorldVolumeSetup].xmax = world->xmax;
    g_vantage_list[vantage_point][kWorldVolumeSetup].ymin = world->ymin;
    g_vantage_list[vantage_point][kWorldVolumeSetup].ymax = world->ymax;
    g_vantage_list[vantage_point][kWorldVolumeSetup].zmin = world->zmin;
    g_vantage_list[vantage_point][kWorldVolumeSetup].zmax = world->zmax;
    
    GKSlimits_3 *view = gks_trans_get_view_volume();
    g_vantage_list[vantage_point][kViewVolumeSetup].xmin = view->xmin;
    g_vantage_list[vantage_point][kViewVolumeSetup].xmax = view->xmax;
    g_vantage_list[vantage_point][kViewVolumeSetup].ymin = view->ymin;
    g_vantage_list[vantage_point][kViewVolumeSetup].ymax = view->ymax;
    g_vantage_list[vantage_point][kViewVolumeSetup].zmin = view->zmin;
    g_vantage_list[vantage_point][kViewVolumeSetup].zmax = view->zmax;
}


void restore_vantage(GKSint vantage_point)
{
    GKSlimits_3 restored_volume = g_vantage_list[vantage_point][kWorldVolumeSetup];
    gks_trans_set_world_volume(&restored_volume);

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


void gks_vantage_set_vantage_defaults(void)
{
    // set all vantage points to their default values
    for (GKSint vant_pt = 0; vant_pt < GKS_MAX_VANTAGE_PTS; vant_pt++) {
        GKSvector3d min = GKSMakeVector(-1.0, -1.0, -1.0);
        GKSvector3d max = GKSMakeVector(1.0, 1.0, 1.0);
        GKSlimits_3 viewport_volume = GKSMakeVolume(min, max);
        GKSlimits_3 world_volume = GKSMakeVolume(min, max);
        
        // 3D_World
        gks_trans_set_world_volume(&world_volume);
        // 3D_ViewPort
        gks_trans_set_view_volume(&viewport_volume);
        
        store_vantage(vant_pt);
    }
}


