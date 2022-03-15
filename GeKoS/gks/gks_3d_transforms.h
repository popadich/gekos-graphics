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

void gks_trans_init_3(void);

GKSint gks_trans_get_curr_view_idx(void);
void gks_trans_set_curr_view_idx(GKSint view_num);

// Creates and sets view_num index as the current view index
void gks_trans_create_transform_at_idx(GKSint view_num, GKSfloat r_mini, GKSfloat r_maxi, GKSfloat s_mini, GKSfloat s_maxi, GKSlimits_3 world_volume_3);

GKSlimits_3 gks_trans_get_transform_at_idx(GKSint view_num, GKSint setup);



// TODO: these must both be called before compute can be called, bad design
void gks_trans_set_world_volume_3(GKSint view_num, GKSlimits_3 *wrld_volume);
void gks_trans_set_viewport_volume_3(GKSint view_num, GKSlimits_3 *viewport);


// 2D stuff related to device
void gks_trans_set_device_viewport(GKSint view_num, GKSlimits_2 dev_limits);
GKSlimits_2 gks_trans_get_device_viewport(void);
void gks_trans_adjust_device_viewport(GKSfloat r_mini, GKSfloat r_maxi, GKSfloat s_mini, GKSfloat s_maxi);

void gks_trans_wc_to_ndc_3 (GKSpoint_3 *wc_pt, GKSpoint_3 *ndc_pt);
void gks_trans_wc_to_ndc (GKSvector3d wc_pt, GKSvector3dPtr ndc_pt);
void gks_trans_ndc_3_to_dc_2 (GKSpoint_3 *ndc_pt, GKSint *r, GKSint *s);
void gks_trans_ndc_to_dc (GKSvector3d ndc_pt, GKSint *r, GKSint *s);

#endif /* gks_3d_transforms_h */
