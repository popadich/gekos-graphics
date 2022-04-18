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
static GKSfloat       g_dev_xscale, g_dev_xcoord;
static GKSfloat       g_dev_yscale, g_dev_ycoord;


// PROTOTYPE
void compute_transforms(GKScontext3DPtr context_ptr);
void norms_set_view_volume(GKScontext3DPtr context_ptr, GKSlimits_3 *view_volume);


void gks_norms_init(GKScontext3DPtr context)
{
    g_wrld_xscale = 0.0;
    g_wrld_xcoord = 0.0;
    g_wrld_yscale = 0.0;
    g_wrld_ycoord = 0.0;
    g_wrld_zscale = 0.0;
    g_wrld_zcoord = 0.0;
    
    context->wrld_xscale = 0.0;
    context->wrld_xcoord = 0.0;
    context->wrld_yscale = 0.0;
    context->wrld_ycoord = 0.0;
    context->wrld_zscale = 0.0;
    context->wrld_zcoord = 0.0;
    
    g_dev_xscale = 0.0;
    g_dev_xcoord = 0.0;
    g_dev_yscale = 0.0;
    g_dev_ycoord = 0.0;
    
    context->dev_xscale = 0.0;
    context->dev_xcoord = 0.0;
    context->dev_yscale = 0.0;
    context->dev_ycoord = 0.0;
    
    
    GKSvector3d min = GKSMakeVector(-1.0, -1.0, -1.0);
    GKSvector3d max = GKSMakeVector(1.0, 1.0, 1.0);
    
    // set the same "unit" volume for world and view
    GKSlimits_3 view_volume = GKSMakeVolume(min, max);
    GKSlimits_3 world_volume = GKSMakeVolume(min, max);
    
    // 3D World volume
    gks_norms_set_world_volume(context, &world_volume);
    // 3D View volume
    norms_set_view_volume(context, &view_volume);

    
}



// MARK: Setters
//
//  r and s are device coordinates, as in the ones you would plot to the screen in
//  a window's view.
//
//  r_min = WindowRect.left;    r_max = WindowRect.right;
//  s_min = WindowRect.bottom;  s_max = WindowRect.top;
//
void gks_norms_set_device_viewport(GKScontext3DPtr context, GKSlimits_2 *device_limits)
{

    g_device_port.xmin = device_limits->xmin;
    g_device_port.ymin = device_limits->ymin;
    g_device_port.xmax = device_limits->xmax;
    g_device_port.ymax = device_limits->ymax;

    context->port_rect.xmin = device_limits->xmin;
    context->port_rect.ymin = device_limits->ymin;
    context->port_rect.xmax = device_limits->xmax;
    context->port_rect.ymax = device_limits->ymax;
    
    compute_transforms(context);
    
}


void norms_set_view_volume(GKScontext3DPtr context, GKSlimits_3 *view_volume)
{
    g_view_volume.xmin = view_volume->xmin;
    g_view_volume.xmax = view_volume->xmax;
    g_view_volume.ymin = view_volume->ymin;
    g_view_volume.ymax = view_volume->ymax;
    g_view_volume.zmin = view_volume->zmin;
    g_view_volume.zmax = view_volume->zmax;
    
    context->volume_view.xmin = view_volume->xmin;
    context->volume_view.xmax = view_volume->xmax;
    context->volume_view.ymin = view_volume->ymin;
    context->volume_view.ymax = view_volume->ymax;
    context->volume_view.zmin = view_volume->zmin;
    context->volume_view.zmax = view_volume->zmax;

    compute_transforms(context);

}

void gks_norms_set_world_volume(GKScontext3DPtr context, GKSlimits_3 *wrld_volume)
{
    g_world_volume.xmin = wrld_volume->xmin;
    g_world_volume.xmax = wrld_volume->xmax;
    g_world_volume.ymin = wrld_volume->ymin;
    g_world_volume.ymax = wrld_volume->ymax;
    g_world_volume.zmin = wrld_volume->zmin;
    g_world_volume.zmax = wrld_volume->zmax;
    
    context->volume_world.xmin = wrld_volume->xmin;
    context->volume_world.xmax = wrld_volume->xmax;
    context->volume_world.ymin = wrld_volume->ymin;
    context->volume_world.ymax = wrld_volume->ymax;
    context->volume_world.zmin = wrld_volume->zmin;
    context->volume_world.zmax = wrld_volume->zmax;
    
    compute_transforms(context);

}

// MARK: Computation
void setup_transform_world_view(GKScontext3DPtr context, GKSlimits_3 world_volume, GKSlimits_3 view_volume) {
    
    GKSfloat x_min = world_volume.xmin;
    GKSfloat x_max = world_volume.xmax;
    GKSfloat y_min = world_volume.ymin;
    GKSfloat y_max = world_volume.ymax;
    GKSfloat z_min = world_volume.zmin;
    GKSfloat z_max = world_volume.zmax;
    
    GKSfloat u_min = view_volume.xmin;
    GKSfloat u_max = view_volume.xmax;
    GKSfloat v_min = view_volume.ymin;
    GKSfloat v_max = view_volume.ymax;
    GKSfloat w_min = view_volume.zmin;
    GKSfloat w_max = view_volume.zmax;
    
    g_wrld_xscale = (u_max - u_min)/(x_max - x_min);
    context->wrld_xscale = (u_max - u_min)/(x_max - x_min);
    
    g_wrld_xcoord = g_wrld_xscale*(-x_min) + u_min;
    context->wrld_xcoord = g_wrld_xscale*(-x_min) + u_min;
    
    g_wrld_yscale = (v_max - v_min)/(y_max - y_min);
    context->wrld_yscale = (v_max - v_min)/(y_max - y_min);
    
    g_wrld_ycoord = g_wrld_yscale*(-y_min) + v_min;
    context->wrld_ycoord = g_wrld_yscale*(-y_min) + v_min;
    
    g_wrld_zscale = (w_max - w_min)/(z_max - z_min);
    context->wrld_zscale = (w_max - w_min)/(z_max - z_min);
    
    g_wrld_zcoord = g_wrld_zscale*(-z_min) + w_min;
    context->wrld_zcoord = g_wrld_zscale*(-z_min) + w_min;;
    
}

void setup_transform_view_to_device(GKScontext3DPtr context, GKSlimits_3 view_limits)
{

    GKSfloat u_min = view_limits.xmin;
    GKSfloat u_max = view_limits.xmax;
    GKSfloat v_min = view_limits.ymin;
    GKSfloat v_max = view_limits.ymax;
    
    GKSfloat r_min3 = g_device_port.xmin;
    GKSfloat r_max3 = g_device_port.xmax;
    GKSfloat s_min3 = g_device_port.ymin;
    GKSfloat s_max3 = g_device_port.ymax;

    g_dev_xscale = (r_max3 - r_min3)/(u_max - u_min);
    context->dev_xscale = (r_max3 - r_min3)/(u_max - u_min);
    
    g_dev_xcoord = g_dev_xscale*(-u_min) + r_min3;
    context->dev_xcoord = g_dev_xscale*(-u_min) + r_min3;
    
    g_dev_yscale = (s_max3 - s_min3)/(v_max - v_min);
    context->dev_yscale = (s_max3 - s_min3)/(v_max - v_min);
    
    g_dev_ycoord = g_dev_yscale*(-v_min) + s_min3;
    context->dev_ycoord = g_dev_yscale*(-v_min) + s_min3;
    
}



// For now there is only one transform, so keeping
// it in an array of 10 seems weird and pointless.
//
// These are viewport and world volume transforms.
void compute_transforms(GKScontext3DPtr context)
{
    setup_transform_world_view(context, g_world_volume, g_view_volume); // volumes don't need to be passed
    setup_transform_view_to_device(context, g_view_volume); // no pass

}

// MARK: Transforms
// World coordinates (wc) to Normalized World Coordinates (nwc)
// World space -> Normalized World space
void gks_norms_wc_to_nwc (GKScontext3DPtr context_ptr, GKSvector3d wc_pt, GKSvector3dPtr nwc_pt)
{
    nwc_pt->crd.x = g_wrld_xscale * wc_pt.crd.x + g_wrld_xcoord;
    nwc_pt->crd.y = g_wrld_yscale * wc_pt.crd.y + g_wrld_ycoord;
    nwc_pt->crd.z = g_wrld_zscale * wc_pt.crd.z + g_wrld_zcoord;
    nwc_pt->crd.w = 1.0;    // TODO: verify if ok
}


// Normalized Device Coordinates (ndc) to Device Coordinates (dc) 2D
// If I were to build a 2D drawing library, this function would be
// part of that.
void gks_norms_nwc_3_to_dc_2 (GKScontext3DPtr context_ptr, GKSvector3d ndc_pt, GKSfloat *r, GKSfloat *s)
{
    *r = g_dev_xscale * ndc_pt.crd.x + g_dev_xcoord;
    *s = g_dev_yscale * ndc_pt.crd.y + g_dev_ycoord;
}

