//
//  gks_3d_transforms.c
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

#include <stdbool.h>
#include "gks_3d_transforms.h"

#define GKS_MAX_VIEW_TRANSFORMS 10
#define GKS_TRANSFORM_TYPES 2

const GKSint kWorldVolumeSetup = 0;
const GKSint kViewPortVolumeSetup = 1;

//  P R O T O T Y P E S
void gks_trans_set_world_volume(GKSint view_num, GKSlimits_3 *wrld_volume);
void gks_trans_set_viewport_volume_3(GKSint view_num, GKSlimits_3 *viewport);
void gks_vantage_defaults(void);
void gks_trans_compute_transforms(GKSint view_num);


// S T A T I C   G L O B A L S
static GKSint         g_curr_vantage_idx;

// Make room for 10 transforms, use only one for now
static GKSlimits_3    g_tranform_list[GKS_MAX_VIEW_TRANSFORMS][GKS_TRANSFORM_TYPES];

// world volume globals
static GKSfloat       g_wrld_xscale, g_wrld_xcoord;
static GKSfloat       g_wrld_yscale, g_wrld_ycoord;
static GKSfloat       g_wrld_zscale, g_wrld_zcoord;

// device limits globals
static GKSfloat       g_r_min3, g_r_max3, g_s_min3, g_s_max3;
static GKSfloat       g_dev_xscale, g_dev_xcoord;
static GKSfloat       g_dev_yscale, g_dev_ycoord;

//
// Initialize world, viewport, and device transformations
//
void gks_trans_init(void)
{
    g_wrld_xscale = g_wrld_xcoord = 0.0;
    g_wrld_yscale = g_wrld_ycoord = 0.0;
    g_wrld_zscale = g_wrld_zcoord = 0.0;
    
    g_dev_xscale = g_dev_xcoord = 0.0;
    g_dev_yscale = g_dev_ycoord = 0.0;
    
    gks_vantage_defaults();
    gks_trans_set_curr_view_idx(0);
}

GKSint gks_trans_get_curr_view_idx(void)
{
    return g_curr_vantage_idx;
}

void gks_trans_set_curr_view_idx(GKSint view_num)
{
    if (view_num > -1 && view_num < GKS_MAX_VIEW_TRANSFORMS) {
        gks_trans_compute_transforms(view_num);
        g_curr_vantage_idx = view_num;
    }
}

void gks_vantage_defaults(void)
{
    // set all vantage points to their default values
    for (GKSint view_num=0; view_num<GKS_MAX_VIEW_TRANSFORMS; view_num++) {
        GKSvector3d min = GKSMakeVector(-1.0, -1.0, -1.0);
        GKSvector3d max = GKSMakeVector(1.0, 1.0, 1.0);
        GKSlimits_3 viewport_volume = GKSMakeVolume(min, max);
        GKSlimits_3 world_volume = GKSMakeVolume(min, max);
        
        // 3D_World
        gks_trans_set_world_volume(view_num, &world_volume);
        // 3D_ViewPort
        gks_trans_set_viewport_volume_3(view_num, &viewport_volume);

        gks_trans_compute_transforms(view_num);

    }
}


// MARK: World Volume
void gks_trans_set_world_volume(GKSint view_num, GKSlimits_3 *wrld_volume)
{
    g_tranform_list[view_num][kWorldVolumeSetup].xmin = wrld_volume->xmin;
    g_tranform_list[view_num][kWorldVolumeSetup].xmax = wrld_volume->xmax;
    g_tranform_list[view_num][kWorldVolumeSetup].ymin = wrld_volume->ymin;
    g_tranform_list[view_num][kWorldVolumeSetup].ymax = wrld_volume->ymax;
    g_tranform_list[view_num][kWorldVolumeSetup].zmin = wrld_volume->zmin;
    g_tranform_list[view_num][kWorldVolumeSetup].zmax = wrld_volume->zmax;
    
}

void gks_trans_adjust_world_volume(GKSint view_num, GKSlimits_3 *newVolume)
{
    gks_trans_set_world_volume(view_num, newVolume);
    
    // 3D_World volume adjustment
    gks_trans_set_world_volume(view_num, newVolume);
    gks_trans_compute_transforms(view_num);

}

void gks_trans_set_current_world_volume(GKSlimits_3 *volume)
{
    GKSint view_num = gks_trans_get_curr_view_idx();
    gks_trans_set_world_volume(view_num, volume);
}

void gks_trans_adjust_current_world_volume(GKSlimits_3 *newVolume)
{
    GKSint view_num = gks_trans_get_curr_view_idx();
    gks_trans_adjust_world_volume(view_num, newVolume);
}



// MARK: Device Port
//
//  r and s are device coordinates, as in the ones you would plot to the screen in
//  a window's view.
//
//  r_min = WindowRect.left;    r_max = WindowRect.right;
//  s_min = WindowRect.bottom;  s_max = WindowRect.top;
//
void gks_trans_set_device_viewport(GKSint view_num, GKSlimits_2 *device_limits)
{
    g_r_min3 = device_limits->xmin;
    g_r_max3 = device_limits->xmax;
    g_s_min3 = device_limits->ymin;
    g_s_max3 = device_limits->ymax;
}


void gks_trans_adjust_device_viewport(GKSint view_num, GKSlimits_2 *dev_port)
{
    gks_trans_set_device_viewport(view_num, dev_port);
    
    // These are viewport and world volume transforms only
    // what about the others, camera view and projection?
    gks_trans_compute_transforms(view_num);
    
}

void gks_trans_set_current_device_viewport(GKSlimits_2 *dev_port)
{
    GKSint view_num = gks_trans_get_curr_view_idx();
    gks_trans_set_device_viewport(view_num, dev_port);
}

void gks_trans_adjust_current_device_viewport(GKSlimits_2 *dev_port)
{
    GKSint view_num = gks_trans_get_curr_view_idx();
    gks_trans_adjust_device_viewport(view_num, dev_port);
}


// MARK: View Volume
void gks_trans_set_viewport_volume_3(GKSint view_num, GKSlimits_3 *viewport)
{

    g_tranform_list[view_num][kViewPortVolumeSetup].xmin = viewport->xmin;
    g_tranform_list[view_num][kViewPortVolumeSetup].xmax = viewport->xmax;
    g_tranform_list[view_num][kViewPortVolumeSetup].ymin = viewport->ymin;
    g_tranform_list[view_num][kViewPortVolumeSetup].ymax = viewport->ymax;
    g_tranform_list[view_num][kViewPortVolumeSetup].zmin = viewport->zmin;
    g_tranform_list[view_num][kViewPortVolumeSetup].zmax = viewport->zmax;
        
}



// MARK: Transforms
void setup_transform_world_view(GKSlimits_3 winlim, GKSlimits_3 vwplim) {
    GKSfloat        x_min,x_max,y_min,y_max,z_min,z_max;
    GKSfloat        u_min,u_max,v_min,v_max,w_min,w_max;
    
    x_min = winlim.xmin;
    x_max = winlim.xmax;
    y_min = winlim.ymin;
    y_max = winlim.ymax;
    z_min = winlim.zmin;
    z_max = winlim.zmax;
    u_min = vwplim.xmin;
    u_max = vwplim.xmax;
    v_min = vwplim.ymin;
    v_max = vwplim.ymax;
    w_min = vwplim.zmin;
    w_max = vwplim.zmax;
    
    g_wrld_xscale = (u_max - u_min)/(x_max - x_min);
    g_wrld_xcoord = g_wrld_xscale*(-x_min) + u_min;
    g_wrld_yscale = (v_max - v_min)/(y_max - y_min);
    g_wrld_ycoord = g_wrld_yscale*(-y_min) + v_min;
    g_wrld_zscale = (w_max - w_min)/(z_max - z_min);
    g_wrld_zcoord = g_wrld_zscale*(-z_min) + w_min;
}

void setup_transform_viewport_to_device(GKSlimits_3 viewport_limits)
{
    GKSfloat u_min, u_max, v_min, v_max;
    
    u_min = viewport_limits.xmin;
    u_max = viewport_limits.xmax;
    v_min = viewport_limits.ymin;
    v_max = viewport_limits.ymax;

    g_dev_xscale = (g_r_max3 - g_r_min3)/(u_max - u_min);
    g_dev_xcoord = g_dev_xscale*(-u_min) + g_r_min3;
    g_dev_yscale = (g_s_max3 - g_s_min3)/(v_max - v_min);
    g_dev_ycoord = g_dev_yscale*(-v_min) + g_s_min3;
}

// For now there is only one transform, so keeping
// it in an array of 10 seems weird and pointless.
//
// These are viewport and world volume transforms.
void gks_trans_compute_transforms(GKSint view_num)
{
    GKSlimits_3 wrld_volume;
    GKSlimits_3 vwp_lim;
        
    // world
    wrld_volume.xmin = g_tranform_list[view_num][kWorldVolumeSetup].xmin;
    wrld_volume.xmax = g_tranform_list[view_num][kWorldVolumeSetup].xmax;
    wrld_volume.ymin = g_tranform_list[view_num][kWorldVolumeSetup].ymin;
    wrld_volume.ymax = g_tranform_list[view_num][kWorldVolumeSetup].ymax;
    wrld_volume.zmin = g_tranform_list[view_num][kWorldVolumeSetup].zmin;
    wrld_volume.zmax = g_tranform_list[view_num][kWorldVolumeSetup].zmax;

    // viewport
    vwp_lim.xmin = g_tranform_list[view_num][kViewPortVolumeSetup].xmin;
    vwp_lim.xmax = g_tranform_list[view_num][kViewPortVolumeSetup].xmax;
    vwp_lim.ymin = g_tranform_list[view_num][kViewPortVolumeSetup].ymin;
    vwp_lim.ymax = g_tranform_list[view_num][kViewPortVolumeSetup].ymax;
    vwp_lim.zmin = g_tranform_list[view_num][kViewPortVolumeSetup].zmin;
    vwp_lim.zmax = g_tranform_list[view_num][kViewPortVolumeSetup].zmax;

    setup_transform_world_view(wrld_volume, vwp_lim);
    setup_transform_viewport_to_device(vwp_lim);

}


// World coordinates (wc) to Normalized Device Coordinates (ndc)
// World space -> Normalized World space
void gks_trans_wc_to_nwc (GKSvector3d wc_pt, GKSvector3dPtr ndc_pt)
{
    ndc_pt->crd.x = g_wrld_xscale * wc_pt.crd.x + g_wrld_xcoord;
    ndc_pt->crd.y = g_wrld_yscale * wc_pt.crd.y + g_wrld_ycoord;
    ndc_pt->crd.z = g_wrld_zscale * wc_pt.crd.z + g_wrld_zcoord;
    ndc_pt->crd.w = 1.0;
}


// Normalized Device Coordinates (ndc) to Device Coordinates (dc) 2D
// If I were to build a 2D drawing library, this function would be
// part of that.
void gks_trans_ndc_3_to_dc_2 (GKSvector3d ndc_pt, GKSfloat *r, GKSfloat *s)
{
    *r = g_dev_xscale * ndc_pt.crd.x + g_dev_xcoord;
    *s = g_dev_yscale * ndc_pt.crd.y + g_dev_ycoord;
}


