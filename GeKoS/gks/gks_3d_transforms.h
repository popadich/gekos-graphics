//
//  gks_3d_transforms.h
//  GeKoS
//
//  Created by Alex Popadich on 12/8/21.
//

#ifndef gks_3d_transforms_h
#define gks_3d_transforms_h

#include "gks_types.h"

#define GKS_MAX_VIEW_TRANSFORMS 10

void gks_trans_init(void);

GKSint gks_trans_get_curr_view_idx(void);
void gks_trans_set_curr_view_idx(GKSint view_num);

void gks_trans_set_world_volume(GKSlimits_3 *volume);
void gks_trans_set_device_viewport(GKSlimits_2 *device_limits);

// the heart of the matter
void gks_trans_compute_transforms(void);
void gks_trans_wc_to_nwc (GKSvector3d wc_pt, GKSvector3dPtr nwc_pt);
void gks_trans_nwc_3_to_dc_2 (GKSvector3d ndc_pt, GKSfloat *r, GKSfloat *s);

#endif /* gks_3d_transforms_h */
