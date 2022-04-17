//
//  gks_3d_normalization.h
//  GeKoS
//
//  Created by Alex Popadich on 4/6/22.
//

#ifndef gks_3d_normalization_h
#define gks_3d_normalization_h

#include "gks_types.h"

void gks_norms_init(GKScontext3DPtr context_ptr);

GKSlimits_3 *gks_trans_get_world_volume(GKScontext3DPtr context_ptr);
GKSlimits_3 *gks_trans_get_view_volume(GKScontext3DPtr context_ptr);
GKSlimits_2 *gks_trans_get_device_port(GKScontext3DPtr context_ptr);

void gks_trans_set_world_volume(GKScontext3DPtr context_ptr, GKSlimits_3 *wrld_volume);
void gks_trans_set_view_volume(GKScontext3DPtr context_ptr, GKSlimits_3 *view_volume);
void gks_trans_set_device_viewport(GKScontext3DPtr context_ptr, GKSlimits_2 *device_limits);

// the heart of the matter
void gks_trans_compute_transforms(GKScontext3DPtr context_ptr);
void gks_trans_wc_to_nwc (GKScontext3DPtr context_ptr, GKSvector3d wc_pt, GKSvector3dPtr nwc_pt);
void gks_trans_nwc_3_to_dc_2 (GKScontext3DPtr context_ptr, GKSvector3d ndc_pt, GKSfloat *r, GKSfloat *s);

#endif /* gks_3d_normalization_h */
