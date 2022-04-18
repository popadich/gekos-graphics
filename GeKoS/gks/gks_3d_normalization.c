//
//  gks_3d_normalization.c
//  GeKoS
//
//  Created by Alex Popadich on 4/6/22.
//

#include "gks_3d_normalization.h"


// PROTOTYPE
void compute_transforms(GKScontext3DPtr context_ptr);
void norms_set_view_volume(GKScontext3DPtr context_ptr, GKSlimits_3 *view_volume);


void gks_norms_init(GKScontext3DPtr context)
{
    context->wrld_xscale = 0.0;
    context->wrld_xcoord = 0.0;
    context->wrld_yscale = 0.0;
    context->wrld_ycoord = 0.0;
    context->wrld_zscale = 0.0;
    context->wrld_zcoord = 0.0;

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
    context->port_rect.xmin = device_limits->xmin;
    context->port_rect.ymin = device_limits->ymin;
    context->port_rect.xmax = device_limits->xmax;
    context->port_rect.ymax = device_limits->ymax;
    
    compute_transforms(context);
    
}


void norms_set_view_volume(GKScontext3DPtr context, GKSlimits_3 *view_volume)
{
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
    
    context->volume_world.xmin = wrld_volume->xmin;
    context->volume_world.xmax = wrld_volume->xmax;
    context->volume_world.ymin = wrld_volume->ymin;
    context->volume_world.ymax = wrld_volume->ymax;
    context->volume_world.zmin = wrld_volume->zmin;
    context->volume_world.zmax = wrld_volume->zmax;
    
    compute_transforms(context);

}

// MARK: Computation
void setup_transform_world_view(GKScontext3DPtr context) {
    
    GKSfloat x_min = context->volume_world.xmin;
    GKSfloat x_max = context->volume_world.xmax;
    GKSfloat y_min = context->volume_world.ymin;
    GKSfloat y_max = context->volume_world.ymax;
    GKSfloat z_min = context->volume_world.zmin;
    GKSfloat z_max = context->volume_world.zmax;
    
    GKSfloat u_min = context->volume_view.xmin;
    GKSfloat u_max = context->volume_view.xmax;
    GKSfloat v_min = context->volume_view.ymin;
    GKSfloat v_max = context->volume_view.ymax;
    GKSfloat w_min = context->volume_view.zmin;
    GKSfloat w_max = context->volume_view.zmax;
    
    context->wrld_xscale = (u_max - u_min)/(x_max - x_min);
    
    context->wrld_xcoord = context->wrld_xscale*(-x_min) + u_min;
    
    context->wrld_yscale = (v_max - v_min)/(y_max - y_min);
    
    context->wrld_ycoord = context->wrld_yscale*(-y_min) + v_min;
    
    context->wrld_zscale = (w_max - w_min)/(z_max - z_min);
    
    context->wrld_zcoord = context->wrld_zscale*(-z_min) + w_min;;
    
}

void setup_transform_view_to_device(GKScontext3DPtr context)
{

    GKSfloat u_min = context->volume_view.xmin;
    GKSfloat u_max = context->volume_view.xmax;
    GKSfloat v_min = context->volume_view.ymin;
    GKSfloat v_max = context->volume_view.ymax;

    GKSfloat r_min3 = context->port_rect.xmin;
    GKSfloat r_max3 = context->port_rect.xmax;
    GKSfloat s_min3 = context->port_rect.ymin;
    GKSfloat s_max3 = context->port_rect.ymax;

    context->dev_xscale = (r_max3 - r_min3)/(u_max - u_min);
    
    context->dev_xcoord = context->dev_xscale*(-u_min) + r_min3;
    
    context->dev_yscale = (s_max3 - s_min3)/(v_max - v_min);
    
    context->dev_ycoord = context->dev_yscale*(-v_min) + s_min3;
    
}



// For now there is only one transform, so keeping
// it in an array of 10 seems weird and pointless.
//
// These are viewport and world volume transforms.
void compute_transforms(GKScontext3DPtr context)
{
    setup_transform_world_view(context);
    setup_transform_view_to_device(context);

}

// MARK: Transforms
// World coordinates (wc) to Normalized World Coordinates (nwc)
// World space -> Normalized World space
void gks_norms_wc_to_nwc(GKScontext3DPtr context, GKSvector3d wc_pt, GKSvector3dPtr nwc_pt)
{
    
    nwc_pt->crd.x = context->wrld_xscale * wc_pt.crd.x + context->wrld_xcoord;
    nwc_pt->crd.y = context->wrld_yscale * wc_pt.crd.y + context->wrld_ycoord;
    nwc_pt->crd.z = context->wrld_zscale * wc_pt.crd.z + context->wrld_zcoord;
    nwc_pt->crd.w = 1.0;    // TODO: verify if ok
}



// Normalized Device Coordinates (ndc) to Device Coordinates (dc) 2D
// If I were to build a 2D drawing library, this function would be
// part of that.
void gks_norms_nwc_3_to_dc_2(GKScontext3DPtr context, GKSvector3d ndc_pt, GKSfloat *r, GKSfloat *s)
{
    *r = context->dev_xscale * ndc_pt.crd.x + context->dev_xcoord;
    *s = context->dev_yscale * ndc_pt.crd.y + context->dev_ycoord;

}


