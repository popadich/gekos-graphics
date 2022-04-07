//
//  gks_3d_normalization.c
//  GeKoS
//
//  Created by Alex Popadich on 4/6/22.
//

#include "gks_3d_normalization.h"

// store
static GKSlimits_3 g_world_volume;
static GKSlimits_3 g_view_volume;
static GKSlimits_2 g_device_port;


// world volume globals
static GKSfloat       g_wrld_xscale, g_wrld_xcoord;
static GKSfloat       g_wrld_yscale, g_wrld_ycoord;
static GKSfloat       g_wrld_zscale, g_wrld_zcoord;

// device limits globals
static GKSfloat       g_r_min3, g_r_max3, g_s_min3, g_s_max3;
static GKSfloat       g_dev_xscale, g_dev_xcoord;
static GKSfloat       g_dev_yscale, g_dev_ycoord;


void gks_norms_init(void)
{
    g_wrld_xscale = g_wrld_xcoord = 0.0;
    g_wrld_yscale = g_wrld_ycoord = 0.0;
    g_wrld_zscale = g_wrld_zcoord = 0.0;
    
    g_dev_xscale = g_dev_xcoord = 0.0;
    g_dev_yscale = g_dev_ycoord = 0.0;
    
    GKSvector3d min = GKSMakeVector(-1.0, -1.0, -1.0);
    GKSvector3d max = GKSMakeVector(1.0, 1.0, 1.0);
    
    // set the same "unit" volume for world and view
    GKSlimits_3 viewport_volume = GKSMakeVolume(min, max);
    GKSlimits_3 world_volume = GKSMakeVolume(min, max);
    
    // 3D World volume
    gks_trans_set_world_volume(&world_volume);
    // 3D View volume
    gks_trans_set_view_volume(&viewport_volume);

    
}


GKSlimits_3 *gks_trans_get_world_volume(void)
{
    return &g_world_volume;
}


GKSlimits_3 *gks_trans_get_view_volume(void)
{
    return &g_view_volume;
}


GKSlimits_2 *gks_trans_get_device_port(void)
{
    return &g_device_port;
}


// MARK: Device Port
//
//  r and s are device coordinates, as in the ones you would plot to the screen in
//  a window's view.
//
//  r_min = WindowRect.left;    r_max = WindowRect.right;
//  s_min = WindowRect.bottom;  s_max = WindowRect.top;
//
void gks_trans_set_device_viewport(GKSlimits_2 *device_limits)
{
    g_r_min3 = device_limits->xmin;
    g_r_max3 = device_limits->xmax;
    g_s_min3 = device_limits->ymin;
    g_s_max3 = device_limits->ymax;
    
    g_device_port.xmin = device_limits->xmin;
    g_device_port.ymin = device_limits->ymin;
    g_device_port.xmax = device_limits->xmax;
    g_device_port.ymax = device_limits->ymax;

    gks_trans_compute_transforms();
    
}


// MARK: View Volume
void gks_trans_set_view_volume(GKSlimits_3 *view_volume)
{
    g_view_volume.xmin = view_volume->xmin;
    g_view_volume.xmax = view_volume->xmax;
    g_view_volume.ymin = view_volume->ymin;
    g_view_volume.ymax = view_volume->ymax;
    g_view_volume.zmin = view_volume->zmin;
    g_view_volume.zmax = view_volume->zmax;
        
}

// MARK: World Volume
void gks_trans_set_world_volume(GKSlimits_3 *wrld_volume)
{
    g_world_volume.xmin = wrld_volume->xmin;
    g_world_volume.xmax = wrld_volume->xmax;
    g_world_volume.ymin = wrld_volume->ymin;
    g_world_volume.ymax = wrld_volume->ymax;
    g_world_volume.zmin = wrld_volume->zmin;
    g_world_volume.zmax = wrld_volume->zmax;
    
    gks_trans_compute_transforms();

}

// MARK: Computation
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

void setup_transform_view_to_device(GKSlimits_3 view_limits)
{
    GKSfloat u_min, u_max, v_min, v_max;
    
    u_min = view_limits.xmin;
    u_max = view_limits.xmax;
    v_min = view_limits.ymin;
    v_max = view_limits.ymax;

    g_dev_xscale = (g_r_max3 - g_r_min3)/(u_max - u_min);
    g_dev_xcoord = g_dev_xscale*(-u_min) + g_r_min3;
    g_dev_yscale = (g_s_max3 - g_s_min3)/(v_max - v_min);
    g_dev_ycoord = g_dev_yscale*(-v_min) + g_s_min3;
}

// For now there is only one transform, so keeping
// it in an array of 10 seems weird and pointless.
//
// These are viewport and world volume transforms.
void gks_trans_compute_transforms(void)
{
    GKSlimits_3 wrld_volume;
    GKSlimits_3 vwp_lim;
        
    // world
    wrld_volume.xmin = g_world_volume.xmin;
    wrld_volume.ymin = g_world_volume.ymin;
    wrld_volume.zmin = g_world_volume.zmin;
    wrld_volume.xmax = g_world_volume.xmax;
    wrld_volume.ymax = g_world_volume.ymax;
    wrld_volume.zmax = g_world_volume.zmax;

    // view volume
    vwp_lim.xmin = g_view_volume.xmin;
    vwp_lim.ymin = g_view_volume.ymin;
    vwp_lim.zmin = g_view_volume.zmin;
    vwp_lim.xmax = g_view_volume.xmax;
    vwp_lim.ymax = g_view_volume.ymax;
    vwp_lim.zmax = g_view_volume.zmax;
    
    setup_transform_world_view(wrld_volume, vwp_lim);
    setup_transform_view_to_device(vwp_lim);

}

// MARK: Scalers
// World coordinates (wc) to Normalized World Coordinates (nwc)
// World space -> Normalized World space
void gks_trans_wc_to_nwc (GKSvector3d wc_pt, GKSvector3dPtr nwc_pt)
{
    nwc_pt->crd.x = g_wrld_xscale * wc_pt.crd.x + g_wrld_xcoord;
    nwc_pt->crd.y = g_wrld_yscale * wc_pt.crd.y + g_wrld_ycoord;
    nwc_pt->crd.z = g_wrld_zscale * wc_pt.crd.z + g_wrld_zcoord;
    nwc_pt->crd.w = 1.0;    // TODO: verify if ok
}


// Normalized Device Coordinates (ndc) to Device Coordinates (dc) 2D
// If I were to build a 2D drawing library, this function would be
// part of that.
void gks_trans_nwc_3_to_dc_2 (GKSvector3d ndc_pt, GKSfloat *r, GKSfloat *s)
{
    *r = g_dev_xscale * ndc_pt.crd.x + g_dev_xcoord;
    *s = g_dev_yscale * ndc_pt.crd.y + g_dev_ycoord;
}

